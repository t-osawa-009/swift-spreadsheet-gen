import Foundation

final class SpreadsheetClient {
    private let id: String
    private let sheet_number: Int
    private let outputs: [YamlStringsParser.Output]
    init(id: String, sheet_number: Int, outputs: [YamlStringsParser.Output]) {
        self.id = id
        self.sheet_number = sheet_number
        self.outputs = outputs
    }
    
    private let client = APIClient()
    func execute(completion:  @escaping (Result<Void, Error>) -> Void) {
        let request = SpreadsheetRequest(id: id, sheetNumber: sheet_number)
        client.send(request) { [weak self] (result) in
            guard let _self = self else { return }
            switch result {
            case .success(let value):
                _self.outputs.forEach { (output) in
                    let objects = value.map({ EntryObject(json: $0, keys: output.keys)})
                    switch output.format {
                    case nil:
                        print("Error: no support format")
                    case .xml:
                        let creator = LocalizableFileCreatorForXML(entryObjects: objects,
                                                                   key: output.key,
                                                                   valuekey: output.valueKey,
                                                                   outputPath: output.output)
                        do {
                            try creator.write()
                        } catch let _error {
                            print("Error: \(_error.localizedDescription)")
                            completion(.failure(_error))
                        }
                    case .strings:
                        let creator = LocalizableFileCreatorForStrings(entryObjects: objects,
                                                                       key: output.key,
                                                                       valuekey: output.valueKey,
                                                                       outputPath: output.output)
                        do {
                            try creator.write()
                        } catch let _error {
                            print("Error: \(_error.localizedDescription)")
                            completion(.failure(_error))
                        }
                    }
                }
                completion(.success(()))
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
}

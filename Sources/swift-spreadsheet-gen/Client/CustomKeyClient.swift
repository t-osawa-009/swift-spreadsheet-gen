import Foundation

final class CustomKeyClient {
    private let id: String
    private let sheet_number: Int
    private let outputs: [YamlCustomKeyParser.Output]
    init(id: String, sheet_number: Int, outputs: [YamlCustomKeyParser.Output]) {
        self.id = id
        self.sheet_number = sheet_number
        self.outputs = outputs
    }
    
    private let client = APIClient()
    func execute(completion:  @escaping (Result<Void, Error>) -> Void) {
        let _outputs = self.outputs
        let request = SpreadsheetRequest(id: id, sheetNumber: sheet_number)
        client.send(request) { (result) in
            switch result {
            case .success(let value):
                _outputs.forEach { (output) in
                    let objects = value.map({ EntryObject(json: $0, keys: output.keys)})
                    switch output.format {
                    case nil:
                        print("Error: no support format")
                    case .swift:
                        let creator = CustomKeyFileCreator(entryObjects: objects,
                                                           key: output.key,
                                                           valuekey: output.valueKey,
                                                           enumName: output.enumName,
                                                           publicAccess: output.publicAccess,
                                                           outputPath: output.output,
                                                           isCamelized: output.isCamelized)
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

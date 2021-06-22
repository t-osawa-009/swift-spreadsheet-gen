import Foundation

final class SpreadsheetClient {

    struct LocalizedFileCreationData {
        var allObjects = [EntryObject]()
        var outputPath = ""
        var outputKey = ""
        var outputValuekey = ""
    }

    private let id: String
    private let sheet_numbers: [Int]
    private let outputs: [YamlStringsParser.Output]

    init(id: String, sheet_numbers: [Int], outputs: [YamlStringsParser.Output]) {
        self.id = id
        self.sheet_numbers = sheet_numbers
        self.outputs = outputs
    }

    private let client = APIClient()
    func execute(completion:  @escaping (Result<Void, Error>) -> Void) {
        let _outputs = self.outputs
        var requests = [SpreadsheetRequest]()
        var format: YamlStringsParser.Format = .strings
        var filesCreationData = [LocalizedFileCreationData]()
        let requestsGroup = DispatchGroup()

        for request in requests {
            requestsGroup.enter()
            client.send(request) { result in
                switch result {
                case .success(let value):
                    _outputs.forEach { output in
                        format = output.format ?? .strings
                        var objects = value.map { EntryObject(json: $0, keys: output.keys)}
                        objects = objects.filter { !($0.dic[output.valueKey]?.stringValue ?? "").isEmpty }
                        if let i = filesCreationData.firstIndex(where: { $0.outputPath == output.output }) {
                            filesCreationData[i].allObjects.append(contentsOf: objects)
                        } else {
                            let fileData = LocalizedFileCreationData(allObjects: objects, outputPath: output.output, outputKey: output.key, outputValuekey: output.valueKey)
                            filesCreationData.append(fileData)
                        }

                    }

                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
                requestsGroup.leave()
            }
        }
        
        requestsGroup.notify(queue: .main) {
            self.writeFiles(filesCreationData: filesCreationData, format: format, completion: completion)
        }
    }

    private func writeFiles(filesCreationData: [LocalizedFileCreationData], format: YamlStringsParser.Format, completion: @escaping (Result<Void, Error>) -> Void) {

        let completionGroup = DispatchGroup()
        filesCreationData.forEach { _ in
            completionGroup.enter()
        }

        completionGroup.notify(queue: .main) {
            completion(.success(()))
        }

        switch format {
        case .xml:
            filesCreationData.forEach { data in
                let creator = LocalizableFileCreatorForXML(entryObjects: data.allObjects, key: data.outputKey, valuekey: data.outputValuekey, outputPath: data.outputPath)
                do {
                    try creator.write()
                } catch let _error {
                    print("Error: \(_error.localizedDescription)")
                    completion(.failure(_error))
                }
                completionGroup.leave()
            }
        case .strings:
            filesCreationData.forEach { data in
                let creator = LocalizableFileCreatorForStrings(entryObjects: data.allObjects, key: data.outputKey, valuekey: data.outputValuekey, outputPath: data.outputPath)
                do {
                    try creator.write()
                } catch let _error {
                    print("Error: \(_error.localizedDescription)")
                    completion(.failure(_error))
                }
                completionGroup.leave()
            }
        }
    }
}

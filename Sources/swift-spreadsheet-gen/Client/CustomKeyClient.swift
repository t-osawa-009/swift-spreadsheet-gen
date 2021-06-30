import Foundation

final class CustomKeyClient {
    private let id: String
    private let sheet_numbers: [Int]
    private let outputs: [YamlCustomKeyParser.Output]
    init(id: String, sheet_numbers: [Int], outputs: [YamlCustomKeyParser.Output]) {
        self.id = id
        self.sheet_numbers = sheet_numbers
        self.outputs = outputs
    }
    
    private let client = APIClient()
    func execute(completion:  @escaping (Result<Void, Error>) -> Void) {
        let _outputs = self.outputs
        let requests = self.sheet_numbers.map({ SpreadsheetRequest(id: id, sheetNumber: $0) })
        var filesCreationData = [CustomKeyFileCreator]()
        let requestsGroup = DispatchGroup()
        
        requests.forEach { request in
            requestsGroup.enter()
            client.send(request) { (result) in
                switch result {
                case .success(let value):
                    _outputs.forEach { (output) in
                        var objects = value.map({ EntryObject(json: $0, keys: output.keys)})
                        switch output.format {
                        case nil:
                            print("Error: no support format")
                        case .swift:
                            objects = objects.filter { !($0.dic[output.valueKey]?.stringValue ?? "").isEmpty }
                            if let i = filesCreationData.firstIndex(where: { $0.outputPath == output.output }) {
                                filesCreationData[i].entryObjects.append(contentsOf: objects)
                            } else {
                                let fileData = CustomKeyFileCreator(entryObjects: objects,
                                                                    key: output.key,
                                                                    valuekey: output.valueKey,
                                                                    enumName: output.enumName,
                                                                    publicAccess: output.publicAccess,
                                                                    outputPath: output.output,
                                                                    isCamelized: output.isCamelized)
                                filesCreationData.append(fileData)
                            }
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
                requestsGroup.leave()
            }
        }
        
        requestsGroup.notify(queue: .main) {
            self.writeFiles(filesCreationData: filesCreationData, completion: completion)
        }
    }
    
    private func writeFiles(filesCreationData: [CustomKeyFileCreator], completion: @escaping (Result<Void, Error>) -> Void) {
        let completionGroup = DispatchGroup()
        filesCreationData.forEach { _ in
            completionGroup.enter()
        }

        completionGroup.notify(queue: .main) {
            completion(.success(()))
        }

        filesCreationData.forEach { data in
            do {
                try data.write()
            } catch let _error {
                print("Swift File write Error: \(_error.localizedDescription)")
                completion(.failure(_error))
            }
            completionGroup.leave()
        }
    }
}

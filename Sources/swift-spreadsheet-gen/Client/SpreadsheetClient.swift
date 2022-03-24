import Foundation
import SwiftCSV

final class SpreadsheetClient {
    
    private let url: String
    private let sheet_numbers: [Int]
    private let key: String
    private let outputs: [YamlStringsParser.Output]
    private let languages: [String]
    private let client = APIClient()
    
    init(url: String, sheet_numbers: [Int], key: String, languages: [String], outputs: [YamlStringsParser.Output]) {
        self.url = url
        self.sheet_numbers = sheet_numbers
        self.key = key
        self.languages = languages
        self.outputs = outputs
    }
    
    func execute(completion: @escaping (Result<Void, Error>) -> Void) {
        let requests = self.sheet_numbers.map({ SpreadsheetRequest(url: url, sheetNumber: $0) })
        var objects: [CSV] = []
        let requestsGroup = DispatchGroup()
        print("[INFO] - Starting to send a request")
        for request in requests {
            requestsGroup.enter()
            client.send(request) { result in
                switch result {
                case .success(let value):
                    objects.append(value)
                    requestsGroup.leave()
                case .failure(let error):
                    print("Network Error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        requestsGroup.notify(queue: .main) {
            self.createLanguageData(objects: objects, completion: completion)
        }
    }
    
    private func createLanguageData(objects: [CSV], completion: @escaping (Result<Void, Error>) -> Void) {
        print("[INFO] - Starting for creating the LanguageDatas")
        var filesCreationData = [LanguageData]()
        for lang in languages {
            var allKeys: [String] = []
            var allValues: [String] = []
            for object in objects {
                guard
                    let keys = object.namedColumns[key],
                    let values = object.namedColumns[lang]
                else {
                    struct KeyValuesError: LocalizedError {
                        var errorDescription: String? = "[ERROR]- Keys or values not found!"
                    }
                    let error = KeyValuesError()
                    completion(.failure(error))
                    return
                }
                allKeys += keys
                allValues += values
            }
            print("[INFO] - Read all keys and values for \(lang)")
            filesCreationData.append(LanguageData(keys: allKeys, values: allValues, language: lang))
        }
        self.writeFiles(sheetsCreationData: filesCreationData, completion: completion)
    }

    private func writeFiles(sheetsCreationData: [LanguageData], completion: @escaping (Result<Void, Error>) -> Void) {
        print("[INFO] - Preparing for writing to file")
        var creators: [FileCreatable] = []
        sheetsCreationData.forEach { data in
            outputs.forEach { output in
                switch output.format {
                case .strings:
                    creators.append(
                        LocalizableFileCreatorForStrings(languageData: data, outputPath: output.path)
                    )
                case .xml:
                    creators.append(
                        LocalizableFileCreatorForXML(languageData: data, outputPath: output.path)
                    )
                }
            }
        }
        let completionGroup = DispatchGroup()
        creators.forEach {
            completionGroup.enter()
            do {
                try $0.write()
                completionGroup.leave()
            } catch let error {
                completion(.failure(error))
            }
        }
        completionGroup.notify(queue: .main) {
            completion(.success(()))
        }
    }
}

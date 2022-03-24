import Foundation
import Yams
import Files
import SwiftyJSON

struct Yaml {
    let jsons: [JSON]
    init(path: String) throws {
        let folder = try Folder(path: path)
        let file = try folder.file(named: "swift_spreadsheet_gen.yml")
        let string = try file.readAsString()
        var items = try Yams.load_all(yaml: string)
        var _result: [JSON] = []
        while let item = items.next() {
            _result.append(JSON(item))
        }
        self.jsons = _result
    }
}

struct YamlStringsParser {
    struct Output {
        let path: String
        let format: Format
    }
    
    enum Format: String {
        case xml
        case strings
    }
    
    let url: String
    let sheet_numbers: [Int]
    let languages: [String]
    let key: String
    let outputs: [Output]
    
    init?(jsons: [JSON]) {
        var _url: String?
        var _sheet_numbers: [Int]?
        var _languages: [String]?
        var _key: String?
        var _outputs: [Output]?
        
        jsons.forEach { (json) in
            let strings = json["strings"]["outputs"].arrayValue
            _url = json["strings"]["url"].string
            _sheet_numbers = json["strings"]["sheet_numbers"].arrayValue.map { $0.intValue }
            _languages = json["strings"]["languages"].arrayValue.map { $0.stringValue }
            _key = json["strings"]["key"].string
            _outputs = strings.map {
                return Output(
                    path: $0["path"].stringValue,
                    format: Format(rawValue: $0["format"].stringValue) ?? .strings
                )
            }
        }
        
        guard
            let url = _url,
            let sheet_numbers = _sheet_numbers,
            let languages = _languages,
            let key = _key,
            let outputs = _outputs
        else {
            return nil
        }
        self.url = url
        self.sheet_numbers = sheet_numbers
        self.languages = languages
        self.key = key
        self.outputs = outputs
    }
}

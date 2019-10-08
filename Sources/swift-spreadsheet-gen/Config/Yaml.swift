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

struct YamlCommonParser {
    let id: String
    let sheet_number: Int
    init(jsons: [JSON]) {
        var _id: String = ""
        var _sheet_number = 0
        jsons.forEach { (json) in
            _id = json["id"].stringValue
            _sheet_number = json["sheet_number"].intValue
        }
        
        self.id = _id
        self.sheet_number = _sheet_number
    }
}

struct YamlStringsParser {
    struct Output {
        let key: String
        let valueKey: String
        let output: String
        let format: Format?
        
        var keys: [String] {
            return [key, valueKey]
        }
    }
    
    enum Format: String {
        case xml
        case strings
    }
    
    var outputs: [Output]
    init(jsons: [JSON]) {
        var _outputs: [Output] = []
        jsons.forEach { (json) in
            let strings = json["strings"]["outputs"].arrayValue
            _outputs = strings.map({ (_json: JSON) in
                return Output(key: _json["key"].stringValue.lowercased(),
                              valueKey: _json["value_key"].stringValue.lowercased(),
                              output: _json["output"].stringValue,
                              format: Format(rawValue: _json["format"].stringValue))
            })
        }
        
        self.outputs = _outputs
    }
}

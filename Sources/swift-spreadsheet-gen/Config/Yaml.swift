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
    let id: String
    let sheet_numbers: [Int]
    init?(jsons: [JSON]) {
        var _outputs: [Output] = []
        var _id: String?
        var _sheet_numbers: [Int]?
        
        jsons.forEach { (json) in
            let strings = json["strings"]["outputs"].arrayValue
            _id = json["strings"]["id"].string
            _sheet_numbers = json["strings"]["sheet_numbers"].arrayValue.map { $0.intValue }
            _outputs = strings.map { (_json: JSON) in
                return Output(key: _json["key"].stringValue.lowercased(),
                              valueKey: _json["value_key"].stringValue.lowercased(),
                              output: _json["output"].stringValue,
                              format: Format(rawValue: _json["format"].stringValue))
            }
        }
        guard let id = _id, let sheet_numbers = _sheet_numbers else {
            return nil
        }
        self.id = id
        self.sheet_numbers = sheet_numbers
        self.outputs = _outputs
    }
}

struct YamlCustomKeyParser {
    struct Output {
        let key: String
        let valueKey: String
        let output: String
        let format: Format?
        let enumName: String
        let publicAccess: Bool
        let isCamelized: Bool
        
        var keys: [String] {
            return [key, valueKey]
        }
    }
    
    enum Format: String {
        case swift
    }
    
    var outputs: [Output]
    let id: String
    let sheet_numbers: [Int]
    init?(jsons: [JSON]) {
        var _outputs: [Output] = []
        var _id: String?
        var _sheet_numbers: [Int]?
        
        jsons.forEach { (json) in
            let strings = json["customKey"]["outputs"].arrayValue
            _id = json["customKey"]["id"].string
            _sheet_numbers = json["customKey"]["sheet_numbers"].arrayValue.map({ $0.intValue })
            _outputs = strings.map({ (_json: JSON) in
                return Output(key: _json["key"].stringValue.lowercased(),
                              valueKey: _json["value_key"].stringValue.lowercased(),
                              output: _json["output"].stringValue,
                              format: Format(rawValue: _json["format"].string ?? Format.swift.rawValue),
                              enumName: _json["enumName"].string ?? "CustomKey",
                              publicAccess: _json["publicAccess"].bool ?? false,
                              isCamelized: _json["is_camelized"].bool ?? false)
            })
        }
        guard let id = _id, let _sheet_numbers = _sheet_numbers else {
            return nil
        }
        self.id = id
        self.sheet_numbers = _sheet_numbers
        self.outputs = _outputs
    }
}

import Foundation
import Files

struct LocalizableFileCreatorForXML: FileCreatable {
    private let entryObjects: [EntryObject]
    private let key: String
    private let valuekey: String
    private let outputPath: String
    
    init(entryObjects: [EntryObject], key: String, valuekey: String, outputPath: String) {
        self.entryObjects = entryObjects
        self.key = key
        self.valuekey = valuekey
        self.outputPath = outputPath
    }
    
    func write() throws {
        let urlPath = URL(fileURLWithPath: outputPath)
        let path = urlPath.deletingLastPathComponent().absoluteString
        let _path = path.replacingOccurrences(of: "file://", with: "")
        let folder = try Folder(path: _path)
        let fileName = urlPath.lastPathComponent
        let file = try folder.createFileIfNeeded(at: fileName.replacingOccurrences(of: "file://", with: ""))
        let pathExtension = urlPath.pathExtension
        guard pathExtension == "xml" else {
            print("format is not xml")
            return
        }
        var strings = entryObjects.map({ value -> String in
            let _key = value.dic[key]?.stringValue ?? ""
            let _value = value.dic[valuekey]?.stringValue ?? ""
            return """
            <string name="\(_key)">"\(_value)"</string>
            """
        })
        strings.insert("""
<?xml version="1.0" encoding="utf-8"?>
<resources>
""",
                       at: 0)
        strings.append("</resources>")
        
        let results = strings.joined(separator: "\n")
        let oldData = try file.readAsString()
        if oldData == results {
            print("Not writing the file as content is unchanged")
        } else {
            try file.write(results)
        }
    }
}

struct LocalizableFileCreatorForStrings: FileCreatable {
    private let entryObjects: [EntryObject]
    private let key: String
    private let valuekey: String
    private let outputPath: String
    
    init(entryObjects: [EntryObject], key: String, valuekey: String, outputPath: String) {
        self.entryObjects = entryObjects
        self.key = key
        self.valuekey = valuekey
        self.outputPath = outputPath
    }
    
    func write() throws {
        let urlPath = URL(fileURLWithPath: outputPath)
        let path = urlPath.deletingLastPathComponent().absoluteString
        let _path = path.replacingOccurrences(of: "file://", with: "")
        let folder = try Folder(path: _path)
        let fileName = urlPath.lastPathComponent
        let file = try folder.createFileIfNeeded(at: fileName.replacingOccurrences(of: "file://", with: ""))
        let pathExtension = urlPath.pathExtension
        guard pathExtension == "strings" else {
            print("format is not strings")
            return
        }
        
        let strings = entryObjects.map({ value -> String in
            let _key = value.dic[key]?.stringValue ?? ""
            let _value = value.dic[valuekey]?.stringValue ?? ""
            return """
            "\(_key)" = "\(_value)"
            """
        })
        let results = strings.joined(separator: "\n")
        if try file.readAsString() == results {
            print("Not writing the file as content is unchanged")
        } else {
            try file.write(results)
        }
    }
}

import Foundation
import Files

struct CustomKeyFileCreator: FileCreatable {
    func write() throws {
        let urlPath = URL(fileURLWithPath: outputPath)
        let path = urlPath.deletingLastPathComponent().absoluteString
        let _path = path.replacingOccurrences(of: "file://", with: "")
        let folder = try Folder(path: _path)
        let fileName = urlPath.lastPathComponent
        let file = try folder.createFileIfNeeded(at: fileName.replacingOccurrences(of: "file://", with: ""))
        
        var strings: [String] = []
        let access: String = {
            if publicAccess {
                return "public"
            } else {
                return "internal"
            }
        }()
        let header = """
        \(access) enum \(enumName): String {
        """
        strings.append(header)
        strings.append(contentsOf: entryObjects.map({ value -> String in
            let _value = value.dic[valuekey]?.stringValue ?? ""
            let _key: String = {
                if isCamelized {
                    return (value.dic[key]?.stringValue ?? "").camelized()
                } else {
                    return value.dic[key]?.stringValue ?? ""
                }
            }()
            return """
                case \(_key) = "\(_value)"
            """
        }))
        
        let footer = """
        }
        """
        strings.append(footer)
        let results = strings.joined(separator: "\n")
        if try file.readAsString() == results {
            print("Not writing the file as content is unchanged")
        } else {
            try file.write(results)
        }
    }
    
    var entryObjects: [EntryObject]
    private let key: String
    private let valuekey: String
    let outputPath: String
    private let enumName: String
    private let publicAccess: Bool
    private let isCamelized: Bool
    
    init(entryObjects: [EntryObject], key: String, valuekey: String, enumName: String, publicAccess: Bool, outputPath: String, isCamelized: Bool) {
        self.entryObjects = entryObjects
        self.key = key
        self.valuekey = valuekey
        self.enumName = enumName
        self.publicAccess = publicAccess
        self.outputPath = outputPath
        self.isCamelized = isCamelized
    }
}

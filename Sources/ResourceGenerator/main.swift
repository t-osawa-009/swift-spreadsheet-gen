import Foundation
import Dispatch

do {
    let cwd = FileManager.default.currentDirectoryPath
    let script = CommandLine.arguments[0];
    var path = ""
    if script.hasPrefix("/") {
        path = (script as NSString).deletingLastPathComponent
    } else {
        let urlCwd = URL(fileURLWithPath: cwd)
        if let _path = URL(string: script, relativeTo: urlCwd)?.path {
            path = (_path as NSString).deletingLastPathComponent
        }
    }
    let yaml = try Yaml(path: path)
    let dispatchGroup = DispatchGroup()
    let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
    
    dispatchGroup.enter()
    if let strings = YamlStringsParser(jsons: yaml.jsons) {
        print("[INFO] - Reading YML file")
        let spreadsheetClient = SpreadsheetClient(
            url: strings.url,
            sheet_numbers: strings.sheet_numbers,
            key: strings.key,
            languages: strings.languages,
            outputs: strings.outputs
        )
                                                  
        dispatchQueue.async(group: dispatchGroup) {
            spreadsheetClient.execute { (result) in
                switch result {
                case .success(_):
                    print("[INFO] - All languages have been generated!!!")
                case .failure(let error):
                    print(error.localizedDescription)
                    exit(1)
                }
            dispatchGroup.leave()
            }
        }
    } else {
        dispatchGroup.leave()
    }
    dispatchGroup.notify(queue: .main) {
        print("[INFO] - All Process Done!")
        exit(0)
    }
    dispatchMain()
} catch let _error {
    print("Error: \(_error.localizedDescription)")
}

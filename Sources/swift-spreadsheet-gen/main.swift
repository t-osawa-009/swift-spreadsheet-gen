import Foundation
import Commander
import Dispatch

let main = command(
    Option<String>("config_path", default: ".", description: "Manage and run configuration files")
) { (config_path) in
    do {
        let yaml = try Yaml(path: config_path)
        let strings = YamlStringsParser(jsons: yaml.jsons)
        let request = SpreadsheetRequest(id: strings.id, sheetNumber: strings.sheet_number)
        let client = APIClient()
        client.send(request) { (result) in
            switch result {
            case .success(let value):
                strings.outputs.forEach { (output) in
                    let objects = value.map({ EntryObject(json: $0, keys: output.keys)})
                    switch output.format {
                    case nil:
                        print("Error: no support format")
                    case .xml:
                        let creator = LocalizableFileCreatorForXML(entryObjects: objects,
                                                                   key: output.key,
                                                                   valuekey: output.valueKey,
                                                                   outputPath: output.output)
                        do {
                            try creator.write()
                        } catch let _error {
                            print("Error: \(_error.localizedDescription)")
                        }
                    case .strings:
                        let creator = LocalizableFileCreatorForStrings(entryObjects: objects,
                                                                       key: output.key,
                                                                       valuekey: output.valueKey,
                                                                       outputPath: output.output)
                        do {
                            try creator.write()
                        } catch let _error {
                            print("Error: \(_error.localizedDescription)")
                        }
                    }
                }
                exit(0)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                exit(1)
            }
        }
        dispatchMain()
    } catch let _error {
        print("Error: \(_error.localizedDescription)")
    }
}
main.run("0.0.1")

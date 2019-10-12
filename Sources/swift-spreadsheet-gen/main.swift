import Foundation
import Commander
import Dispatch

let main = command(
    Option<String>("config_path", default: ".", description: "Manage and run configuration files")
) { (config_path) in
    do {
        let yaml = try Yaml(path: config_path)
        let strings = YamlStringsParser(jsons: yaml.jsons)
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        let spreadsheetClient = SpreadsheetClient(id: strings.id,
                                                  sheet_number: strings.sheet_number,
                                                  outputs: strings.outputs)
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
            spreadsheetClient.execute { (result) in
                switch result {
                case .success(_):
                    break
                case .failure(let error):
                    print(error.localizedDescription)
                    exit(1)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All Process Done!")
            exit(0)
        }
        dispatchMain()
    } catch let _error {
        print("Error: \(_error.localizedDescription)")
    }
}
main.run("0.0.1")

import Foundation
import Commander
import Dispatch

let main = command(
    Option<String>("config_path", default: ".", description: "Manage and run configuration files")
) { (config_path) in
    do {
        let yaml = try Yaml(path: config_path)
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        dispatchGroup.enter()
        if let strings = YamlStringsParser(jsons: yaml.jsons) {
            print("start strings generate")
            let spreadsheetClient = SpreadsheetClient(id: strings.id,
                                                      sheet_numbers: strings.sheet_numbers,
                                                      outputs: strings.outputs)
            dispatchQueue.async(group: dispatchGroup) {
                spreadsheetClient.execute { (result) in
                    switch result {
                    case .success(_):
                        print("success strings !!")
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
        
        dispatchGroup.enter()
        if let customKey = YamlCustomKeyParser(jsons: yaml.jsons) {
            print("start customKey generate")
            let customKeyClient = CustomKeyClient(id: customKey.id,
                                                  sheet_number: customKey.sheet_number,
                                                  outputs: customKey.outputs)
            
            dispatchQueue.async(group: dispatchGroup) {
                customKeyClient.execute { (result) in
                    switch result {
                    case .success(_):
                        print("success customKey !!")
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
            print("All Process Done!")
            exit(0)
        }
        dispatchMain()
    } catch let _error {
        print("Error: \(_error.localizedDescription)")
    }
}
main.run("0.0.4")

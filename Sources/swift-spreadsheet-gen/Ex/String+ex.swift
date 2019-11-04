//
//  String+ex.swift
//  CYaml
//
//  Created by Takuya Ohsawa on 2019/11/03.
//

import Foundation

public extension String {
    // set `lower = false` in case you want "UpperCamel" output.
    func camelized(lower: Bool = true) -> String {
        guard self != "" else { return self }

        let words = lowercased().split(separator: "_").map({ String($0) })
        let firstWord: String = words.first ?? ""

        let camel: String = lower ? firstWord : String(firstWord.prefix(1).capitalized) + String(firstWord.suffix(from: index(after: startIndex)))
        return words.dropFirst().reduce(into: camel, { camel, word in
            camel.append(String(word.prefix(1).capitalized) + String(word.suffix(from: index(after: startIndex))))
        })
    }
}

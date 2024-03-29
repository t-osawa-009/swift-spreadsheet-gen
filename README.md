# swift-spreadsheet-gen

Convert a Google Spreadsheet to a file. This project is heavily inspired by the [xvrh/localize-with-spreadsheet](https://github.com/xvrh/localize-with-spreadsheet), [SwiftGen/SwiftGen](https://github.com/SwiftGen/SwiftGen)

## Installation
### Makefile
```sh
$ git clone git@github.com:t-osawa-009/swift-spreadsheet-gen.git
$ cd swift-spreadsheet-gen
$ make install
```
### [Mint](https://github.com/yonaskolb/Mint)
```sh
$ mint install t-osawa-009/swift-spreadsheet-gen
```

## Usage
Given a Google Spreadsheet like this:
[Spreadsheet](https://docs.google.com/spreadsheets/d/1zVw1G2LvoJOnnaez3Tuf2Kxqt7S8-zATNazY14FgBwI/edit?usp=sharing)

To use swift-spreadsheet-gen, simply create a `swift_spreadsheet_gen.yml` YAML file to list all the subcommands to invoke, and for each subcommand, the list of arguments to pass to it. For example:
```
strings:
  id: "your Google Spreadsheet id"
  sheet_number: your Google Spreadsheet number
  outputs:
    - key: KEY
      value_key: ja
      output: ./ja.lproj/Localizable.strings
      format: strings
    - key: KEY
      value_key: en
      output: ./en.lproj/Localizable.xml
      format: xml
customKey:
  id: "your Google Spreadsheet id"
  sheet_number: your Google Spreadsheet number
  outputs:
    - key: KEY
      value_key: KEY
      output: ./Localizable.swift
      enumName: Strigs
      is_camelized: true
```
Then you just have to invoke `swift-spreadsheet-gen` and it will execute what's described in the configuration file.

## Notes
- Your spreadsheet should be "Published" for this to work

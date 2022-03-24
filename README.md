
# swift-spreadsheet-gen

Convert a Google Spreadsheet to a file. This project is heavily inspired by the [xvrh/localize-with-spreadsheet](https://github.com/xvrh/localize-with-spreadsheet), [SwiftGen/SwiftGen](https://github.com/SwiftGen/SwiftGen)
In this project, we use CSV format to generate files.
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
You should publish the sheet as a CSV.

![enter image description here](https://d33v4339jhl8k0.cloudfront.net/docs/assets/5915e1a02c7d3a057f890932/images/618d2e7012c07c18afde6edc/file-D8dJEYqihf.gif)

To use swift-spreadsheet-gen, simply create a `swift_spreadsheet_gen.yml` YAML file to list all the subcommands to invoke, and for each subcommand, the list of arguments to pass to it. For example:
```
strings:
  # To find your sheet next time just save it
  id: "your Google Spreadsheet id"
  # "A part of the published URL"
  url: "e/{PUBLISHED ID}/pub"
  # you can find the sheet number in the URL part
  sheet_numbers: [your Google Spreadsheet numbers]
  # The column titles and languages must be the same like "en", "de"
  languages: [your languages that you want to generate]
  key: "Key column title"
  outputs:
      # iOS
    - format: strings
      path: /swift_spreadsheet_gen-sample/Resources/
      # Android
    - format: xml
      path: /swift_spreadsheet_gen-sample/Strings/
```
Then you just have to invoke `swift-spreadsheet-gen` and it will execute what's described in the configuration file.

## Notes
- You should put the YAML file beside the execute file.
- All paths defined in the YAML file are related to the path of the execute file.
- You can put the execute file and YAML at the root of the project for more convenience.
- All values are case-sensitive. Maybe, this should be considered a TODO. 😅😅😅
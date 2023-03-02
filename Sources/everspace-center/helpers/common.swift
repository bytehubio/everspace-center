//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.09.2021.
//

import Foundation

var pathToRootDirectory: String {
    /// Please, set custom working directory to project folder for your xcode scheme. This is necessary for the relative path "./" to the project folders to work.
    /// You may change it with the xcode edit scheme menu.
    /// Or inside file path_to_ton_sdk/.swiftpm/xcode/xcshareddata/xcschemes/TonSDK.xcscheme
    /// set to tag "LaunchAction" absolute path to this library with options:
    /// useCustomWorkingDirectory = "YES"
    /// customWorkingDirectory = "/path_to_ton_sdk"
    let workingDirectory: String = "./"
    if !FileManager.default.fileExists(atPath: workingDirectory) {
        fatalError("\(workingDirectory) directory is not exist")
    }
    return workingDirectory
}

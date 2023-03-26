//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.09.2021.
//

import Foundation
import Vapor

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

/// asdf print
public func pe(_ line: Any...) {
    #if DEBUG
    let content: [Any] = ["asdf"] + line
    print(content.map{"\($0)"}.join(" "))
    #endif
}

public func encodeResponse(for request: Vapor.Request, html: String) async throws -> Vapor.Response {
    let res = Response()
    res.headers.add(name: "Content-Type", value: "text/html")
    res.body = Response.Body(string: html)
    return res
}

public func encodeResponse(for request: Vapor.Request, json: String) async throws -> Vapor.Response {
    let res = Response()
    res.headers.add(name: "Content-Type", value: "application/json")
    res.body = Response.Body(string: json)
    return res
}

//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.09.2021.
//

import Foundation
import Vapor
//import SwiftExtensionsPack

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


extension Process: @unchecked Sendable {}

@discardableResult
func systemCommand(_ command: String, _ user: String? = nil, timeOutNanoseconds: UInt32 = 0) async throws -> String {
    var result: String = .init()
    let process: Process = .init()
    let pipe: Pipe = .init()
    process.executableURL = .init(fileURLWithPath: "/usr/bin/env")
    process.standardOutput = pipe
    process.standardError = pipe
    if user != nil {
        process.arguments = ["sudo", "-H", "-u", user!, "bash", "-lc", "\(command)"]
    } else {
        process.arguments = ["bash", "-c", "\(command)"]
    }
    if timeOutNanoseconds > 0 {
        Task {
            usleep(timeOutNanoseconds)
            try await forceKillProcess(process)
        }
    }
    try process.run()
    process.waitUntilExit()
    let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
    if let output = String(data: data, encoding: .utf8) {
        result = output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    if process.isRunning { try await forceKillProcess(process) }
    return result
}


actor ForceKillProcessActor {
    private var _flag: Bool = true
    public func setFlag(_ value: Bool) { _flag = value }
    public func flag() -> Bool { _flag }
}

func forceKillProcess(_ process: Process) async throws {
    process.terminate()
    usleep(1000)
    if process.isRunning { process.interrupt() }
    usleep(1000)
    if process.isRunning { try await systemCommand("kill -9 \(process.processIdentifier)") }
    let waitForShutdown: UInt32 = 3 * 1_000_000
    let flag: ForceKillProcessActor = .init()
    Task.detached { usleep(waitForShutdown); await flag.setFlag(false) }
    while process.isRunning {
        if await flag.flag() { break }
        try await systemCommand("kill -9 \(process.processIdentifier)")
        usleep(1000)
    }
}

@discardableResult
func systemCommand(_ command: String) async throws -> String {
    try await systemCommand(command, nil, timeOutNanoseconds: 0)
}


@discardableResult
func systemCommand(_ command: String, _ user: String? = nil, timeOutSec: UInt32 = 0) async throws -> String {
    try await systemCommand(command, user, timeOutNanoseconds: timeOutSec * 1000000)
}

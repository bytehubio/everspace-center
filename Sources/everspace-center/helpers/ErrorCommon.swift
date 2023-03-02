//
//  ErrorCommon.swift
//  Oberton
//
//  Created by Oleh Hudeichuk on 24.09.2021.
//

import Foundation
import EverscaleClientSwift

public protocol ErrorCommon: ErrorCommonMessage {
    var title: String { get set }
    var reason: String { get set }
    
    init()
    init(reason: String)
    init(_ reason: String)
    init(_ error: Error)
}

public protocol ErrorCommonMessage: LocalizedError, Error, Decodable {
    init(_ reason: String)
    static func mess(_ reason: String) -> Self
}

public extension ErrorCommonMessage {
    static func mess(_ reason: String) -> Self {
        Self(reason)
    }
}

public extension ErrorCommon {
    var title: String { "" }
    var reason: String { "" }
    var description: String { "[\(title)] \(reason)" }
    var errorDescription: String? { self.description }
    var failureReason: String? { self.description }
    var recoverySuggestion: String? { self.description }
    var helpAnchor: String? { self.description }
    
    init(_ reason: String) {
        self.init()
        self.reason = reason
    }
    
    init(reason: String) {
        self.init()
        self.reason = reason
    }
    
    init(_ error: Error) {
        self.init()
        self.reason = error.localizedDescription
    }
    
}

public func makeError<T: ErrorCommonMessage>(_ error: T, _ funcName: String = #function, _ line: Int = #line) -> T {
    let message: String = "\(funcName) line: \(line), error: \(error.localizedDescription)"
    return T.mess(message)
}


extension TSDKClientError: ErrorCommonMessage {}

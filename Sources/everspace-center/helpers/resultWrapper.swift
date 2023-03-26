//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import EverscaleClientSwift
import BigInt
import SwiftExtensionsPack


//MARK: TSDKBindingResponse
public func resultWrapper<T, T2, T3: ErrorCommonMessage>(_ response: TSDKBindingResponse<T, T3>,
                                                         _ function: @escaping (Result<T2, T3>) throws -> Void,
                                                         _ funcName: String = #function,
                                                         _ line: Int = #line,
                                                         _ handler: @escaping (T,
                                                                               @escaping (Result<T2, T3>) throws -> Void
                                                         ) throws -> Void
) throws {
    if let error = response.error {
        try? function(.failure(makeError(error, funcName, line)))
    } else if let result = response.result {
        try handler(result, function)
    } else {
        try? function(.failure(makeError(T3.mess("\(#function) line: \(#line) No response \(response.rawResponse)"), funcName, line)))
    }
}

public func resultWrapper<T, T2: ErrorCommonMessage>(_ response: TSDKBindingResponse<T, T2>,
                                                     _ funcName: String = #function,
                                                     _ line: Int = #line,
                                                     _ handler: @escaping (T) throws -> Void
) throws {
    if let error = response.error {
        throw makeError(error, funcName, line)
    } else if let result = response.result {
        try handler(result)
    } else {
        throw makeError(TSDKClientError.mess("\(#function) line: \(#line) No response \(response.rawResponse)"), funcName, line)
    }
}

public func resultWrapperToModel<T, T2: Decodable, T3: ErrorCommonMessage>(_ response: TSDKBindingResponse<T, T3>,
                                                                           _ function: @escaping (Result<T2, T3>) throws -> Void,
                                                                           _ funcName: String = #function,
                                                                           _ line: Int = #line,
                                                                           _ handler: @escaping (T2,
                                                                                                 @escaping (Result<T2, T3>) throws -> Void
                                                                           ) throws -> Void
) throws {
    if let error = response.error {
        try? function(.failure(makeError(error, funcName, line)))
    } else if let result = response.result {
        if let model = result.toJson()?.toModel(T2.self) {
            try function(.success(model))
        } else {
            try function(.failure(makeError(T3.mess("\(#function) line: \(#line) Can not decode model"))))
        }
    } else {
        try? function(.failure(makeError(T3.mess("\(#function) line: \(#line) No response \(response.rawResponse)"), funcName, line)))
    }
}

public func resultWrapperToModel<T, T2, T3: Decodable, T4: ErrorCommonMessage>(_ response: TSDKBindingResponse<T, T4>,
                                                                               _ function: @escaping (Result<T2, T4>) throws -> Void,
                                                                               _ funcName: String = #function,
                                                                               _ line: Int = #line,
                                                                               _ handler: @escaping (T3,
                                                                                                     @escaping (Result<T2, T4>) throws -> Void
                                                                               ) throws -> Void
) throws {
    if let error = response.error {
        try? function(.failure(makeError(error, funcName, line)))
    } else if let result = response.result {
        if let model = result.toJson()?.toModel(T3.self) {
            try handler(model, function)
        } else {
            try function(.failure(makeError(T4.mess("\(#function) line: \(#line) Can not decode model"))))
        }
    } else {
        try? function(.failure(makeError(T4.mess("\(#function) line: \(#line) No response \(response.rawResponse)"), funcName, line)))
    }
}


//MARK: RESULT

public func resultWrapper<T, T2, T3: ErrorCommonMessage>(_ result: Result<T, T3>,
                                                         _ function: @escaping (Result<T2, T3>) throws -> Void,
                                                         _ funcName: String = #function,
                                                         _ line: Int = #line,
                                                         _ handler: @escaping (T,
                                                                               @escaping (Result<T2, T3>) throws -> Void
                                                         ) throws -> Void
) throws {
    switch result {
    case let .success(value):
        try handler(value, function)
    case let .failure(error):
        try? function(.failure(makeError(error, funcName, line)))
    }
}

public extension StringProtocol {
    func toModel<T>(_ model: T.Type) throws -> T where T : Decodable {
        guard let data = self.data(using: String.Encoding.utf8) else { throw makeError(AppError.mess("Get data from string error")) }
        return try JSONDecoder().decode(model, from: data)
    }
}

public func resultWrapperToModel<T: StringProtocol, T2: Decodable, T3: ErrorCommonMessage>(_ result: Result<T, T3>,
                                                                                           _ function: @escaping (Result<T2, T3>) throws -> Void,
                                                                                           _ funcName: String = #function,
                                                                                           _ line: Int = #line,
                                                                                           _ handler: @escaping (T2,
                                                                                                                 @escaping (Result<T2, T3>) throws -> Void
                                                                                           ) throws -> Void
) throws {
    switch result {
    case let .success(value):
        try handler(try value.toModel(T2.self), function)
    case let .failure(error):
        try? function(.failure(makeError(error, funcName, line)))
    }
}

public func resultWrapperToModel<T: StringProtocol, T2, T3: Decodable, T4: ErrorCommonMessage>(_ result: Result<T, T4>,
                                                                                               _ function: @escaping (Result<T2, T4>) throws -> Void,
                                                                                               _ funcName: String = #function,
                                                                                               _ line: Int = #line,
                                                                                               _ handler: @escaping (T3,
                                                                                                                     @escaping (Result<T2, T4>) throws -> Void
                                                                                               ) throws -> Void
) throws {
    switch result {
    case let .success(value):
        try handler(try value.toModel(T3.self), function)
    case let .failure(error):
        try? function(.failure(makeError(error, funcName, line)))
    }
}


public func resultWrapper<T, T2: ErrorCommonMessage>(_ result: Result<T, T2>,
                                                     _ funcName: String = #function,
                                                     _ line: Int = #line,
                                                     _ handler: @escaping (T) throws -> Void
) throws {
    switch result {
    case let .success(value):
        try handler(value)
    case let .failure(error):
        throw makeError(error, funcName, line)
    }
}




//public func resultWrapperToModel<T, T2: Decodable>(_ response: T.Type,
//                                                                           _ funcName: String = #function,
//                                                                           _ line: Int = #line
//) throws -> T2 {
//    if let model = result.toJson()?.toModel(T2.self) {
//        return model
//    } else {
//        throw makeError(T3.mess("\(#function) line: \(#line) Can not decode model"))
//    }
//}

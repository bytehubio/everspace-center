//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 23.03.2023.
//

import Foundation
import Vapor
import IkigaJSON

/// Captures all errors and transforms them into an internal server error HTTP response.
public final class CustomErrorMiddleware: Middleware {
    /// Structure of `ErrorMiddleware` default response.
    internal struct ErrorResponse: Codable {
        /// The reason for the error.
        var error: String
    }

    /// Create a default `ErrorMiddleware`. Logs errors to a `Logger` based on `Environment`
    /// and converts `Error` to `Response` based on conformance to `AbortError` and `Debuggable`.
    ///
    /// - parameters:
    ///     - environment: The environment to respect when presenting errors.
    public static func `default`(environment: Environment) -> Self {
        .init { req, error in
            // variables to determine
            let status: HTTPResponseStatus
            let reason: String
            let headers: HTTPHeaders

            // inspect the error type
            switch error {
            case let abort as AbortError:
                // this is an abort error, we should use its status, reason, and headers
                reason = abort.reason
                status = abort.status
                headers = abort.headers
            default:
                // if not release mode, and error is debuggable, provide debug info
                // otherwise, deliver a generic 500 to avoid exposing any sensitive error info
                reason = environment.isRelease
                    ? "Something went wrong."
                : String(describing: error.localizedDescription)
                status = .internalServerError
                headers = [:]
            }
            
            // Report the error to logger.
            req.logger.report(error: error)
            
            // create a Response with appropriate status
            let response = Response(status: status, headers: headers)
            
            // attempt to serialize the error to json
            do {
                let resultError: String = "Status: \(status). Reason: \(reason)"
                if req.url.string.contains("jsonRpc") {
                    var errorResponse: JsonRPCResponse<JsonRPCVoid>!
                    if let id = req.parameters.get("id") {
                        errorResponse = JsonRPCResponse<JsonRPCVoid>(id: id, jsonrpc: .v2_0, error: resultError)
                    } else if let content: JsonRPCRequestDefault = try? req.content.decode(JsonRPCRequestDefault.self) {
                        errorResponse = JsonRPCResponse<JsonRPCVoid>(id: content.id, jsonrpc: content.jsonrpc, error: resultError)
                    } else {
                        errorResponse = JsonRPCResponse<JsonRPCVoid>(error: resultError)
                    }
                    response.body = try .init(data: IkigaJSONEncoder().encode(errorResponse), byteBufferAllocator: req.byteBufferAllocator)
                } else {
                    let errorResponse = ErrorResponse(error: reason)
                    response.body = try .init(data: IkigaJSONEncoder().encode(errorResponse), byteBufferAllocator: req.byteBufferAllocator)
                }
                
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)", byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }

    /// Error-handling closure.
    private let closure: (Request, Error) -> (Response)

    /// Create a new `ErrorMiddleware`.
    ///
    /// - parameters:
    ///     - closure: Error-handling closure. Converts `Error` to `Response`.
    public init(_ closure: @escaping (Request, Error) -> (Response)) {
        self.closure = closure
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        return next.respond(to: request).flatMapErrorThrowing { error in
            return self.closure(request, error)
        }
    }
}


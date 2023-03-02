//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.03.2023.
//

import Foundation
import Vapor
import EverscaleClientSwift

final class TransactionsController {
    
    func getTransactions(_ req: Request) async throws -> [EverClient.TransactionHistoryModel] {
        guard let address: String = req.query["address"] else {
            app.logger.warning("\(req.query)")
            throw makeError(AppError.mess("Address required"))
        }
        return try await withUnsafeThrowingContinuation { continuation in
            if (req.query["hash"] as String?) != nil || (req.query["lt"] as String?) != nil {
                EverClient.getTransactions(address: address,
                                           limit: UInt32(req.parameters.get("limit") ?? ""),
                                           lastLt: req.query["lt"] as String?,
                                           hashId: req.query["hash"] as String?
                ) { result in
                    switch result {
                    case let .success(transactions):
                        continuation.resume(returning: transactions)
                    case let .failure(error):
                        continuation.resume(throwing: makeError(error))
                    }
                }
            } else {
                EverClient.getTransactions(address: address,
                                           limit: req.query["limit"] as UInt32?
                ) { result in
                    switch result {
                    case let .success(transactions):
                        continuation.resume(returning: transactions)
                    case let .failure(error):
                        continuation.resume(throwing: makeError(error))
                    }
                }
            }
        }
    }
    
    deinit {
        app.logger.warning("\(Self.self) deinit")
    }
}

extension TransactionsController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getTransactions", use: getTransactions)
    }
}

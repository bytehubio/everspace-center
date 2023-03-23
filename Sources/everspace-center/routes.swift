//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//

import Vapor

public enum RPCMethods: String, Content {
    case transactions_getTransactions
}

func routes(_ app: Application) throws {
    try app.register(collection: JsonRpcController())
//    try app.group("transactions") { group in
//        try group.register(collection: TransactionsController())
//    }
}


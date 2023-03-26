//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//

import Vapor
import Swiftgger

func routes(_ app: Application) throws {
    let jsonRpc: JsonRpcController = .init()
    try app.group("jsonRpc") { group in
        try group.register(collection: jsonRpc)
    }
    
    let swagger: SwaggerController = .init()
    try app.group("") { group in
        try group.register(collection: swagger)
    }
    
    try app.register(collection: JsonRpcController.transactionsController)
    
    try app.register(collection: JsonRpcController.accountsController)
}

//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//

import Vapor
import Swiftgger

func routes(_ app: Application) throws {

    try app.group("") { group in
        try group.register(collection: SwaggerController.shared)
    }
    
    try app.group("everscale") { group in
        try group.register(collection: EverSwaggerController.shared)
        try group.register(collection: EverJsonRpcController.shared)
        try group.register(collection: EverTransactionsController.shared)
        try group.register(collection: EverAccountsController.shared)
        try group.register(collection: EverSendController.shared)
        try group.register(collection: EverRunGetMethodsController.shared)
    }
    
//    try app.group("toncoin") { group in
//        try group.register(collection: SwaggerController())
//    }
}

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
        try group.register(collection: EverJsonRpcController())
        try group.register(collection: EverTransactionsController(EverClient.shared.client, EverSwaggerController.shared))
        try group.register(collection: EverAccountsController(EverClient.shared.client, EverSwaggerController.shared))
        try group.register(collection: EverSendController(EverClient.shared.client, EverSwaggerController.shared))
        try group.register(collection: EverRunGetMethodsController(EverClient.shared.client, EverSwaggerController.shared))
        try group.register(collection: EverBlocksController(EverClient.shared.client, EverSwaggerController.shared))
    }
    
    try app.group("toncoin") { group in
        try group.register(collection: TonSwaggerController.shared)
        try group.register(collection: TonJsonRpcController())
        try group.register(collection: TonTransactionsController(TonClient.shared.client, TonSwaggerController.shared))
        try group.register(collection: TonAccountsController(TonClient.shared.client, TonSwaggerController.shared))
        try group.register(collection: TonSendController(TonClient.shared.client, TonSwaggerController.shared))
        try group.register(collection: TonRunGetMethodsController(TonClient.shared.client, TonSwaggerController.shared))
        try group.register(collection: TonBlocksController(TonClient.shared.client, TonSwaggerController.shared))
    }
}

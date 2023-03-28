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
        try group.register(collection: EverTransactionsController(EverClient.client, EverSwaggerController.shared))
        try group.register(collection: EverAccountsController(EverClient.client, EverSwaggerController.shared))
        try group.register(collection: EverSendController(EverClient.client, EverSwaggerController.shared))
        try group.register(collection: EverRunGetMethodsController(EverClient.client, EverSwaggerController.shared))
        try group.register(collection: EverBlocksController(EverClient.client, EverSwaggerController.shared))
    }
    
    try app.group("everscale-devnet") { group in
        try group.register(collection: EverDevnetSwaggerController.shared)
        try group.register(collection: EverJsonRpcController())
        try group.register(collection: EverTransactionsController(EverDevClient.client, EverDevnetSwaggerController.shared))
        try group.register(collection: EverAccountsController(EverDevClient.client, EverDevnetSwaggerController.shared))
        try group.register(collection: EverSendController(EverDevClient.client, EverDevnetSwaggerController.shared))
        try group.register(collection: EverRunGetMethodsController(EverDevClient.client, EverDevnetSwaggerController.shared))
        try group.register(collection: EverBlocksController(EverDevClient.client, EverDevnetSwaggerController.shared))
    }
    
    try app.group("toncoin") { group in
        try group.register(collection: TonSwaggerController.shared)
        try group.register(collection: TonJsonRpcController())
        try group.register(collection: TonTransactionsController(TonClient.client, TonSwaggerController.shared))
        try group.register(collection: TonAccountsController(TonClient.client, TonSwaggerController.shared))
        try group.register(collection: TonSendController(TonClient.client, TonSwaggerController.shared))
        try group.register(collection: TonRunGetMethodsController(TonClient.client, TonSwaggerController.shared))
        try group.register(collection: TonBlocksController(TonClient.client, TonSwaggerController.shared))
    }
}

//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//

import Vapor
import Swiftgger

let mainController: MainController = .init()

let everSwaggerController: EverSwaggerController = .init("everscale")
let everJsonRpcController: EverJsonRpcController = .init()
let everTransactionsController: EverTransactionsController = .init(EverClient.client, everSwaggerController)
let everAccountsController: EverAccountsController = .init(EverClient.client, everSwaggerController)
let everSendController: EverSendController = .init(EverClient.client, everSwaggerController)
let everRunGetMethodsController: EverRunGetMethodsController = .init(EverClient.client, everSwaggerController)
let everBlocksController: EverBlocksController = .init(EverClient.client, everSwaggerController)

let everDevnetSwaggerController: EverDevnetSwaggerController = .init("everscale-devnet")
let everDevnetJsonRpcController: EverDevnetJsonRpcController = .init()
let everDevnetTransactionsController: EverTransactionsController = .init(EverDevClient.client, everDevnetSwaggerController)
let everDevnetAccountsController: EverAccountsController = .init(EverDevClient.client, everDevnetSwaggerController)
let everDevnetSendController: EverSendController = .init(EverDevClient.client, everDevnetSwaggerController)
let everDevnetRunGetMethodsController: EverRunGetMethodsController = .init(EverDevClient.client, everDevnetSwaggerController)
let everDevnetBlocksController: EverBlocksController = .init(EverDevClient.client, everDevnetSwaggerController)

let tonSwaggerController: TonSwaggerController = .init("toncoin")
let tonJsonRpcController: TonJsonRpcController = .init()
let tonTransactionsController: EverTransactionsController = .init(TonClient.client, tonSwaggerController)
let tonAccountsController: EverAccountsController = .init(TonClient.client, tonSwaggerController)
let tonSendController: EverSendController = .init(TonClient.client, tonSwaggerController)
let tonRunGetMethodsController: EverRunGetMethodsController = .init(TonClient.client, tonSwaggerController)
let tonBlocksController: EverBlocksController = .init(TonClient.client, tonSwaggerController)

func routes(_ app: Application) throws {

    try app.group("") { group in
        try group.register(collection: mainController)
    }
    
    try app.group("everscale") { group in
        try group.register(collection: everSwaggerController)
        try group.register(collection: everJsonRpcController)
        try group.register(collection: everTransactionsController)
        try group.register(collection: everAccountsController)
        try group.register(collection: everSendController)
        try group.register(collection: everRunGetMethodsController)
        try group.register(collection: everBlocksController)
    }
    
    try app.group("everscale-devnet") { group in
        try group.register(collection: everDevnetSwaggerController)
        try group.register(collection: everDevnetJsonRpcController)
        try group.register(collection: everDevnetTransactionsController)
        try group.register(collection: everDevnetAccountsController)
        try group.register(collection: everDevnetSendController)
        try group.register(collection: everDevnetRunGetMethodsController)
        try group.register(collection: everDevnetBlocksController)
    }
    
    try app.group("toncoin") { group in
        try group.register(collection: tonSwaggerController)
        try group.register(collection: tonJsonRpcController)
        try group.register(collection: tonTransactionsController)
        try group.register(collection: tonAccountsController)
        try group.register(collection: tonSendController)
        try group.register(collection: tonRunGetMethodsController)
        try group.register(collection: tonBlocksController)
    }
}

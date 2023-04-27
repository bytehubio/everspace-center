//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//

import Vapor
import Swiftgger

let mainController: MainController = .init()

/// EVERSCALE
let everSwaggerController: EverSwaggerController = .init("everscale")
let everJsonRpcController: EverJsonRpcController = .init()
let everTransactionsController: EverTransactionsController = .init(everSwaggerController, EVERSCALE_SDK_DOMAIN_ENV)
let everAccountsController: EverAccountsController = .init(everSwaggerController, EVERSCALE_SDK_DOMAIN_ENV)
let everSendController: EverSendController = .init(everSwaggerController, EVERSCALE_SDK_DOMAIN_ENV)
let everRunGetMethodsController: EverRunGetMethodsController = .init(everSwaggerController, EVERSCALE_SDK_DOMAIN_ENV)
let everBlocksController: EverBlocksController = .init(everSwaggerController, EVERSCALE_SDK_DOMAIN_ENV)

let everDevnetSwaggerController: EverDevnetSwaggerController = .init("everscale-devnet")
let everDevnetJsonRpcController: EverDevnetJsonRpcController = .init()
let everDevnetTransactionsController: EverTransactionsController = .init(everDevnetSwaggerController, EVERSCALE_DEVNET_SDK_DOMAIN_ENV)
let everDevnetAccountsController: EverAccountsController = .init(everDevnetSwaggerController, EVERSCALE_DEVNET_SDK_DOMAIN_ENV)
let everDevnetSendController: EverSendController = .init(everDevnetSwaggerController, EVERSCALE_DEVNET_SDK_DOMAIN_ENV)
let everDevnetRunGetMethodsController: EverRunGetMethodsController = .init(everDevnetSwaggerController, EVERSCALE_DEVNET_SDK_DOMAIN_ENV)
let everDevnetBlocksController: EverBlocksController = .init(everDevnetSwaggerController, EVERSCALE_DEVNET_SDK_DOMAIN_ENV)

let rfldSwaggerController: RfldSwaggerController = .init("everscale-rfld")
let rfldJsonRpcController: RfldJsonRpcController = .init()
let rfldTransactionsController: EverTransactionsController = .init(rfldSwaggerController, EVERSCALE_RFLD_SDK_DOMAIN_ENV)
let rfldAccountsController: EverAccountsController = .init(rfldSwaggerController, EVERSCALE_RFLD_SDK_DOMAIN_ENV)
let rfldSendController: EverSendController = .init(rfldSwaggerController, EVERSCALE_RFLD_SDK_DOMAIN_ENV)
let rfldRunGetMethodsController: EverRunGetMethodsController = .init(rfldSwaggerController, EVERSCALE_RFLD_SDK_DOMAIN_ENV)
let rfldBlocksController: EverBlocksController = .init(rfldSwaggerController, EVERSCALE_RFLD_SDK_DOMAIN_ENV)

/// VENOM
let venomSwaggerController: VenomSwaggerController = .init("venom")
let venomJsonRpcController: VenomJsonRpcController = .init()
let venomTransactionsController: EverTransactionsController = .init(venomSwaggerController, VENOM_SDK_DOMAIN_ENV)
let venomAccountsController: EverAccountsController = .init(venomSwaggerController, VENOM_SDK_DOMAIN_ENV)
let venomSendController: EverSendController = .init(venomSwaggerController, VENOM_SDK_DOMAIN_ENV)
let venomRunGetMethodsController: EverRunGetMethodsController = .init(venomSwaggerController, VENOM_SDK_DOMAIN_ENV)
let venomBlocksController: EverBlocksController = .init(venomSwaggerController, VENOM_SDK_DOMAIN_ENV)


let venomDevnetSwaggerController: VenomDevnetSwaggerController = .init("venom-testnet")
let venomDevnetJsonRpcController: VenomDevnetJsonRpcController = .init()
let venomDevnetTransactionsController: EverTransactionsController = .init(venomDevnetSwaggerController, VENOM_TESTNET_SDK_DOMAIN_ENV)
let venomDevnetAccountsController: EverAccountsController = .init(venomDevnetSwaggerController, VENOM_TESTNET_SDK_DOMAIN_ENV)
let venomDevnetSendController: EverSendController = .init(venomDevnetSwaggerController, VENOM_TESTNET_SDK_DOMAIN_ENV)
let venomDevnetRunGetMethodsController: EverRunGetMethodsController = .init(venomDevnetSwaggerController, VENOM_TESTNET_SDK_DOMAIN_ENV)
let venomDevnetBlocksController: EverBlocksController = .init(venomDevnetSwaggerController, VENOM_TESTNET_SDK_DOMAIN_ENV)

/// TONCOIN
let tonSwaggerController: TonSwaggerController = .init("toncoin")
let tonJsonRpcController: TonJsonRpcController = .init()
let tonTransactionsController: EverTransactionsController = .init(tonSwaggerController, TONCOIN_SDK_DOMAIN_ENV)
let tonAccountsController: EverAccountsController = .init(tonSwaggerController, TONCOIN_SDK_DOMAIN_ENV)
let tonSendController: EverSendController = .init(tonSwaggerController, TONCOIN_SDK_DOMAIN_ENV)
let tonRunGetMethodsController: EverRunGetMethodsController = .init(tonSwaggerController, TONCOIN_SDK_DOMAIN_ENV)
let tonBlocksController: EverBlocksController = .init(tonSwaggerController, TONCOIN_SDK_DOMAIN_ENV)
let tonJettonsController: TonJettonsController = .init(tonSwaggerController, TONCOIN_SDK_DOMAIN_ENV)

let tonTestnetSwaggerController: ToncoinTestnetSwaggerController = .init("toncoin-testnet")
let tonTestnetJsonRpcController: ToncoinTestnetJsonRpcController = .init()
let tonTestnetTransactionsController: EverTransactionsController = .init(tonTestnetSwaggerController, TONCOIN_TESTNET_SDK_DOMAIN_ENV)
let tonTestnetAccountsController: EverAccountsController = .init(tonTestnetSwaggerController, TONCOIN_TESTNET_SDK_DOMAIN_ENV)
let tonTestnetSendController: EverSendController = .init(tonTestnetSwaggerController, TONCOIN_TESTNET_SDK_DOMAIN_ENV)
let tonTestnetRunGetMethodsController: EverRunGetMethodsController = .init(tonTestnetSwaggerController, TONCOIN_TESTNET_SDK_DOMAIN_ENV)
let tonTestnetBlocksController: EverBlocksController = .init(tonTestnetSwaggerController, TONCOIN_TESTNET_SDK_DOMAIN_ENV)
let tonTestnetJettonsController: TonJettonsController = .init(tonTestnetSwaggerController, TONCOIN_TESTNET_SDK_DOMAIN_ENV)

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
    
    try app.group("everscale-rfld") { group in
        try group.register(collection: rfldSwaggerController)
        try group.register(collection: rfldJsonRpcController)
        try group.register(collection: rfldTransactionsController)
        try group.register(collection: rfldAccountsController)
        try group.register(collection: rfldSendController)
        try group.register(collection: rfldRunGetMethodsController)
        try group.register(collection: rfldBlocksController)
    }
    
    try app.group("venom") { group in
        try group.register(collection: venomSwaggerController)
        try group.register(collection: venomJsonRpcController)
        try group.register(collection: venomTransactionsController)
        try group.register(collection: venomAccountsController)
        try group.register(collection: venomSendController)
        try group.register(collection: venomRunGetMethodsController)
        try group.register(collection: venomBlocksController)
    }
    
    try app.group("venom-testnet") { group in
        try group.register(collection: venomDevnetSwaggerController)
        try group.register(collection: venomDevnetJsonRpcController)
        try group.register(collection: venomDevnetTransactionsController)
        try group.register(collection: venomDevnetAccountsController)
        try group.register(collection: venomDevnetSendController)
        try group.register(collection: venomDevnetRunGetMethodsController)
        try group.register(collection: venomDevnetBlocksController)
    }
    
    try app.group("toncoin") { group in
        try group.register(collection: tonSwaggerController)
        try group.register(collection: tonJsonRpcController)
        try group.register(collection: tonTransactionsController)
        try group.register(collection: tonAccountsController)
        try group.register(collection: tonSendController)
        try group.register(collection: tonRunGetMethodsController)
        try group.register(collection: tonBlocksController)
        try group.register(collection: tonJettonsController)
    }
    
    try app.group("toncoin-testnet") { group in
        try group.register(collection: tonTestnetSwaggerController)
        try group.register(collection: tonTestnetJsonRpcController)
        try group.register(collection: tonTestnetTransactionsController)
        try group.register(collection: tonTestnetAccountsController)
        try group.register(collection: tonTestnetSendController)
        try group.register(collection: tonTestnetRunGetMethodsController)
        try group.register(collection: tonTestnetBlocksController)
        try group.register(collection: tonTestnetJettonsController)
    }
}

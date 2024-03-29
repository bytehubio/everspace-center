//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 26.03.2023.
//

import Foundation
import SwiftExtensionsPack
import Vapor
import EverscaleClientSwift
import Swiftgger


class EverAccountsController: RouteCollection {
    
    var swagger: SwaggerControllerPrtcl
    let network: String
    
    init(_ swagger: SwaggerControllerPrtcl, _ network: String) {
        self.swagger = swagger
        self.network = network
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getAccount", use: getAccount)
        routes.get("getAccounts", use: getAccounts)
        routes.get("getBalance", use: getBalance)
        routes.get("convertAddress", use: convertAddress)
    }
    
    func getAccount(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "getAccount", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, GetAccountRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountRequest>.self)
            result = try JsonRPCResponse<Everscale.Account>(id: content.id,
                                                        result: try await getAccount(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "getAccount", .queryParams)
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await getAccount(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getAccounts(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "getAccounts", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, GetAccountsRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountsRequest>.self)
            result = try JsonRPCResponse<[Everscale.Account]>(id: content.id,
                                                          result: try await getAccounts(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "getAccounts", .queryParams)
            let content: GetAccountsRequest = try req.query.decode(GetAccountsRequest.self)
            result =  try await getAccounts(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getBalance(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "getBalance", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, GetAccountRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountRequest>.self)
            result = try JsonRPCResponse<Everscale.AccountBalance>(id: content.id,
                                                               result: try await getBalance(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "getBalance", .queryParams)
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await getBalance(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func convertAddress(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "convertAddress", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, GetAccountRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountRequest>.self)
            result = try JsonRPCResponse<ConvertAccountResponse>(id: content.id,
                                                             result: try await convertAddress(sdkClientActor.emptyClient(), content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "convertAddress", .queryParams)
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await convertAddress(sdkClientActor.emptyClient(), content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
}


extension EverAccountsController {
    
    struct GetAccountRequest: Content {
        var address: String = ""
    }
    
    struct GetAccountByCodeHashRequest: Content {
        var address: String = ""
    }
    
    struct GetAccountsRequest: Content {
        var addresses: [String]? = [""]
        var order: TSDKSortDirection? = .ASC
        var limit: UInt32? = 1
        var code_hash: String? = nil
        var from_id: String? = nil
        var workchain_id: Int? = nil
    }
    
    struct ConvertAccountResponse: Content {
        var hex: String = ""
        var bounceable: String = ""
        var nonBounceable: String = ""
    }
    
    func getAccount(_ client: TSDKClientModule, _ content: GetAccountRequest) async throws -> Everscale.Account {
        try await Everscale.getAccount(client: client, accountAddress: content.address)
    }
    
    func getAccounts(_ client: TSDKClientModule, _ content: GetAccountsRequest) async throws -> [Everscale.Account] {
        try await Everscale.getAccounts(client: client,
                                        accountAddresses: content.addresses,
                                        order: content.order,
                                        limit: content.limit,
                                        code_hash: content.code_hash,
                                        from_id: content.from_id,
                                        workchain_id: content.workchain_id)
    }
    
    func getBalance(_ client: TSDKClientModule, _ content: GetAccountRequest) async throws -> Everscale.AccountBalance {
        try await Everscale.getBalance(client: client, accountAddress: content.address)
    }
    
    func convertAddress(_ emptyClient: TSDKClientModule, _ content: GetAccountRequest) async throws -> ConvertAccountResponse {
        if content.address.contains(":") {
            let bounceable: String = try await Everscale.tonConvertAddrToToncoinFormat(emptyClient, content.address)
            let nonBounceable: String = try await Everscale.tonConvertAddrToToncoinFormat(emptyClient, content.address, false)
            let hex: String = content.address
            return .init(hex: hex, bounceable: bounceable, nonBounceable: nonBounceable)
        } else {
            let hex: String = try await Everscale.tonConvertAddrToEverFormat(emptyClient, content.address)
            let bounceable: String = try await Everscale.tonConvertAddrToToncoinFormat(emptyClient, hex)
            let nonBounceable: String = try await Everscale.tonConvertAddrToToncoinFormat(emptyClient, hex, false)
            return .init(hex: hex, bounceable: bounceable, nonBounceable: nonBounceable)
        }
    }
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "accounts",
                          description: "Accounts Controller",
                          actions: [
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getAccount",
                                      summary: "",
                                      description: "Get Account Info",
                                      parametersObject: GetAccountRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.Account>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getAccounts",
                                      summary: "",
                                      description: "Get Accounts",
                                      parametersObject: GetAccountsRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<[Everscale.Account]>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getBalance",
                                      summary: "",
                                      description: "Get Balance",
                                      parametersObject: GetAccountRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<String>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/convertAddress",
                                      summary: "",
                                      description: "Convert Account Format",
                                      parametersObject: GetAccountRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<ConvertAccountResponse>.self, asCollection: false))
                                      ]),
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<Everscale.Account>(result: Everscale.Account())),
            APIObject(object: JsonRPCResponse<[Everscale.Account]>(result: [Everscale.Account()])),
            APIObject(object: JsonRPCResponse<Everscale.AccountBalance>(result: Everscale.AccountBalance())),
            APIObject(object: JsonRPCResponse<ConvertAccountResponse>(result: ConvertAccountResponse())),
            APIObject(object: Everscale.Account()),
            APIObject(object: Everscale.AccountBalance()),
            APIObject(object: ConvertAccountResponse()),
        ])
    }
}

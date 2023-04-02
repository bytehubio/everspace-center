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
    }
    
    func getAccount(_ req: Request) async throws -> Response {
        let sdkClient: SDKClient = try getSDKClient(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, GetAccountRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountRequest>.self)
            result = JsonRPCResponse<Everscale.Account>(id: content.id,
                                                        result: try await getAccount(sdkClient.client, content.params)).toJson()
        } else {
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await getAccount(sdkClient.client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getAccounts(_ req: Request) async throws -> Response {
        let sdkClient: SDKClient = try getSDKClient(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, GetAccountsRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountsRequest>.self)
            result = JsonRPCResponse<[Everscale.Account]>(id: content.id,
                                                          result: try await getAccounts(sdkClient.client, content.params)).toJson()
        } else {
            let content: GetAccountsRequest = try req.query.decode(GetAccountsRequest.self)
            result =  try await getAccounts(sdkClient.client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getBalance(_ req: Request) async throws -> Response {
        let sdkClient: SDKClient = try getSDKClient(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, GetAccountRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, GetAccountRequest>.self)
            result = JsonRPCResponse<Everscale.AccountBalance>(id: content.id,
                                                               result: try await getBalance(sdkClient.client, content.params)).toJson()
        } else {
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await getBalance(sdkClient.client, content).toJson()
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
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<Everscale.Account>(result: Everscale.Account())),
            APIObject(object: JsonRPCResponse<[Everscale.Account]>(result: [Everscale.Account()])),
            APIObject(object: JsonRPCResponse<Everscale.AccountBalance>(result: Everscale.AccountBalance())),
            APIObject(object: Everscale.Account()),
            APIObject(object: Everscale.AccountBalance())
        ])
    }
}

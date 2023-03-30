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
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()
    
    init(_ client: TSDKClientModule, _ swagger: SwaggerControllerPrtcl) {
        self.client = client
        self.swagger = swagger
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getAccount", use: getAccount)
        routes.get("getAccounts", use: getAccounts)
        routes.get("getBalance", use: getBalance)
    }
    
    func getAccount(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<GetAccountRequest> = try req.content.decode(EverJsonRPCRequest<GetAccountRequest>.self)
            result = JsonRPCResponse<Everscale.Account>(id: content.id,
                                                        result: try await getAccount(client, content.params)).toJson()
        } else {
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await getAccount(client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getAccounts(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<GetAccountsRequest> = try req.content.decode(EverJsonRPCRequest<GetAccountsRequest>.self)
            result = JsonRPCResponse<[Everscale.Account]>(id: content.id,
                                                          result: try await getAccounts(client, content.params)).toJson()
        } else {
            let content: GetAccountsRequest = try req.query.decode(GetAccountsRequest.self)
            result =  try await getAccounts(client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getBalance(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<GetAccountRequest> = try req.content.decode(EverJsonRPCRequest<GetAccountRequest>.self)
            result = JsonRPCResponse<Everscale.AccountBalance>(id: content.id,
                                                               result: try await getBalance(client, content.params)).toJson()
        } else {
            let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
            result = try await getBalance(client, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
}


extension EverAccountsController {
    
    struct GetAccountRequest: Content {
        var address: String = ""
    }
    
    struct GetAccountsRequest: Content {
        var addresses: [String] = [""]
    }
    
    func getAccount(_ client: TSDKClientModule, _ content: GetAccountRequest) async throws -> Everscale.Account {
        try await Everscale.getAccount(client: client, accountAddress: content.address)
    }
    
    func getAccounts(_ client: TSDKClientModule, _ content: GetAccountsRequest) async throws -> [Everscale.Account] {
        try await Everscale.getAccounts(client: client, accountAddresses: content.addresses)
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

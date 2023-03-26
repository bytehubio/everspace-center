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


final class AccountsController: RouteCollection {
    
    typealias Response = String
    
    struct GetAccountRequest: Content {
        var address: String = ""
    }
    
    struct GetAccountsRequest: Content {
        var addresses: [String] = [""]
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getAccount", use: getAccount)
        routes.get("getAccounts", use: getAccounts)
        routes.get("getBalance", use: getBalance)
    }

    func getAccount(_ req: Request) async throws -> Response {
        let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
        return try await getAccount(content).toJson()
    }
    
    func getAccountRpc(_ req: Request) async throws -> Response {
        let content: JsonRPCRequest<GetAccountRequest> = try req.content.decode(JsonRPCRequest<GetAccountRequest>.self)
        return try JsonRPCResponse<EverClient.Account>(id: content.id, result: try await getAccount(content.params)).toJson()
    }
    
    func getAccounts(_ req: Request) async throws -> Response {
        let content: GetAccountsRequest = try req.query.decode(GetAccountsRequest.self)
        return try await getAccounts(content).toJson()
    }
    
    func getAccountsRpc(_ req: Request) async throws -> Response {
        let content: JsonRPCRequest<GetAccountsRequest> = try req.content.decode(JsonRPCRequest<GetAccountsRequest>.self)
        return try JsonRPCResponse<[EverClient.Account]>(id: content.id, result: try await getAccounts(content.params)).toJson()
    }
    
    func getBalance(_ req: Request) async throws -> Response {        
        let content: GetAccountRequest = try req.query.decode(GetAccountRequest.self)
        return try await getBalance(content)
    }
    
    func getBalanceRpc(_ req: Request) async throws -> Response {
        let content: JsonRPCRequest<GetAccountRequest> = try req.content.decode(JsonRPCRequest<GetAccountRequest>.self)
        return try JsonRPCResponse<String>(id: content.id, result: try await getBalance(content.params)).toJson()
    }
    
    private func getAccount(_ content: GetAccountRequest) async throws -> EverClient.Account {
        try await EverClient.getAccount(accountAddress: content.address)
    }
    
    private func getAccounts(_ content: GetAccountsRequest) async throws -> [EverClient.Account] {
        try await EverClient.getAccounts(accountAddresses: content.addresses)
    }
    
    private func getBalance(_ content: GetAccountRequest) async throws -> Response {
        try await EverClient.getBalance(accountAddress: content.address)
    }
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        
        return openAPIBuilder.add(
            APIController(name: "accounts",
                          description: "Controller where we can manage users",
                          actions: [
                APIAction(method: .get,
                          route: "/getAccount",
                          summary: "",
                          description: "Get Account Info",
                          parametersObject: GetAccountRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "",
                                  type: .object(JsonRPCResponse<EverClient.Account>.self, asCollection: false))
                          ]),
                APIAction(method: .get,
                          route: "/getAccounts",
                          summary: "",
                          description: "Get Accounts",
                          parametersObject: GetAccountsRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "",
                                  type: .object(JsonRPCResponse<[EverClient.Account]>.self, asCollection: false))
                          ]),
                APIAction(method: .get,
                          route: "/getBalance",
                          summary: "",
                          description: "Get Balance",
                          parametersObject: GetAccountRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "",
                                  type: .object(JsonRPCResponse<String>.self, asCollection: false))
                          ]),
            ])
        ).add([
            APIObject(object: JsonRPCResponse<EverClient.Account>(result: EverClient.Account())),
            APIObject(object: JsonRPCResponse<[EverClient.Account]>(result: [EverClient.Account()])),
            APIObject(object: EverClient.Account())
        ])
    }
}

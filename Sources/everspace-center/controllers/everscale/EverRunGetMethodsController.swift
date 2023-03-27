//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 27.03.2023.
//

import Foundation
import SwiftExtensionsPack
import Vapor
import EverscaleClientSwift
import Swiftgger


final class EverRunGetMethodsController: RouteCollection {
    
    typealias Response = String
    
    static let shared: EverRunGetMethodsController = .init()
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("runGetMethodFift", use: runGetMethodFift)
        routes.get("runGetMethodAbi", use: runGetMethodAbi)
    }
    
    func runGetMethodFift(_ req: Request) async throws -> Response {
        let content: EverClient.RunGetMethodFift = try req.query.decode(EverClient.RunGetMethodFift.self)
        let result: EverClient.RunGetMethodFiftResponse = try await runGetMethodFift(content: content)
        return try result.toJson()
    }
    
    func runGetMethodFiftRpc(_ req: Request) async throws -> Response {
        let content: EverJsonRPCRequest<EverClient.RunGetMethodFift> = try req.content.decode(EverJsonRPCRequest<EverClient.RunGetMethodFift>.self)
        return try JsonRPCResponse<EverClient.RunGetMethodFiftResponse>(id: content.id,
                                                                        result: try await runGetMethodFift(content: content.params)).toJson()
    }
    
    func runGetMethodAbi(_ req: Request) async throws -> Response {
        let content: EverClient.RunGetMethodAbi = try req.query.decode(EverClient.RunGetMethodAbi.self)
        return try await runGetMethodAbi(content: content).toJson()
    }
    
    func runGetMethodAbiRpc(_ req: Request) async throws -> Response {
        let content: EverJsonRPCRequest<EverClient.RunGetMethodAbi> = try req.content.decode(EverJsonRPCRequest<EverClient.RunGetMethodAbi>.self)
        return try JsonRPCResponse<EverClient.RunGetMethodFiftResponse>(id: content.id,
                                                                        result: try await runGetMethodAbi(content: content.params)).toJson()
    }
}

extension EverRunGetMethodsController {
    
    struct SendExternalMessageRequest: Content {
        var boc: String = ""
    }
    
    func runGetMethodFift(_ client: TSDKClientModule = EverClient.shared.client,
                          _ emptyClient: TSDKClientModule = EverClient.shared.emptyClient,
                          content: EverClient.RunGetMethodFift
    ) async throws -> EverClient.RunGetMethodFiftResponse {
        try await EverClient.runGetMethodFift(client: client,
                                              emptyClient: emptyClient,
                                              address: content.address,
                                              method: content.method,
                                              params: content.params)
    }
    
    func runGetMethodAbi(_ client: TSDKClientModule = EverClient.shared.client,
                         _ emptyClient: TSDKClientModule = EverClient.shared.emptyClient,
                         content: EverClient.RunGetMethodAbi
    ) async throws -> EverClient.RunGetMethodFiftResponse {
        try await EverClient.runGetMethodAbi(client: client,
                                             emptyClient: emptyClient,
                                             address: content.address,
                                             method: content.method,
                                             jsonParams: content.jsonParams,
                                             abi: content.abi)
    }
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "run get methods",
                          description: "Controller where we can manage users",
                          actions: [
                            APIAction(method: .get,
                                      route: "/everscale/runGetMethodFift",
                                      summary: "",
                                      description: "Get Account Transactions",
                                      parametersObject: EverClient.RunGetMethodFift(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Specific user",
                                              type: .object(JsonRPCResponse<EverClient.RunGetMethodFiftResponse>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/everscale/runGetMethodAbi",
                                      summary: "",
                                      description: "Get Account Transactions",
                                      parametersObject: EverClient.RunGetMethodAbi(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Specific user",
                                              type: .object(JsonRPCResponse<EverClient.RunGetMethodFiftResponse>.self, asCollection: false))
                                      ]),
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<EverClient.RunGetMethodFiftResponse>(result: .init())),
            APIObject(object: EverClient.RunGetMethodAbi()),
            APIObject(object: EverClient.RunGetMethodFift()),
            APIObject(object: EverClient.RunGetMethodFiftResponse()),
        ])
    }
}

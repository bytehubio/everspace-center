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


class EverRunGetMethodsController: RouteCollection {
    var swagger: SwaggerControllerPrtcl
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()
    
    init(_ client: TSDKClientModule, _ swagger: SwaggerControllerPrtcl) {
        self.client = client
        self.swagger = swagger
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("runGetMethodFift", use: runGetMethodFift)
        routes.get("runGetMethodAbi", use: runGetMethodAbi)
    }
    
    func runGetMethodFift(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, Everscale.RunGetMethodFift> = try req.content.decode(JsonRPCRequest<EverRPCMethods, Everscale.RunGetMethodFift>.self)
            result = JsonRPCResponse<Everscale.RunGetMethodFiftResponse>(id: content.id,
                                                                            result: try await runGetMethodFift(client,
                                                                                                               emptyClient,
                                                                                                               content: content.params)).toJson()
        } else {
            let content: Everscale.RunGetMethodFift = try req.query.decode(Everscale.RunGetMethodFift.self)
            result = try await runGetMethodFift(client, emptyClient, content: content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func runGetMethodAbi(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<EverRPCMethods, Everscale.RunGetMethodAbi> = try req.content.decode(JsonRPCRequest<EverRPCMethods, Everscale.RunGetMethodAbi>.self)
            result = JsonRPCResponse<Everscale.RunGetMethodFiftResponse>(id: content.id,
                                                                            result: try await runGetMethodAbi(client,
                                                                                                              emptyClient,
                                                                                                              content: content.params)).toJson()
        } else {
            let content: Everscale.RunGetMethodAbi = try req.query.decode(Everscale.RunGetMethodAbi.self)
            result = try await runGetMethodAbi(client, emptyClient, content: content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
}

extension EverRunGetMethodsController {
    
    struct SendExternalMessageRequest: Content {
        var boc: String = ""
    }
    
    func runGetMethodFift(_ client: TSDKClientModule,
                          _ emptyClient: TSDKClientModule,
                          content: Everscale.RunGetMethodFift
    ) async throws -> Everscale.RunGetMethodFiftResponse {
        try await Everscale.runGetMethodFift(client: client,
                                              emptyClient: emptyClient,
                                              address: content.address,
                                              method: content.method,
                                              params: content.params)
    }
    
    func runGetMethodAbi(_ client: TSDKClientModule,
                         _ emptyClient: TSDKClientModule,
                         content: Everscale.RunGetMethodAbi
    ) async throws -> Everscale.RunGetMethodFiftResponse {
        try await Everscale.runGetMethodAbi(client: client,
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
                          description: "RunGetMethod Controller",
                          actions: [
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/runGetMethodFift",
                                      summary: "",
                                      description: "Run Get Fift method.\nParams field is a array. Example of variants: [12345] or [12345, {\"type\": \"Slice\", \"value\": \"base64Boc\"}] etc",
                                      parametersObject: Everscale.RunGetMethodFift(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.RunGetMethodFiftResponse>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/runGetMethodAbi",
                                      summary: "",
                                      description: "Run Get method by Abi",
                                      parametersObject: Everscale.RunGetMethodAbi(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.RunGetMethodFiftResponse>.self, asCollection: false))
                                      ]),
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<Everscale.RunGetMethodFiftResponse>(result: .init())),
            APIObject(object: Everscale.RunGetMethodAbi()),
            APIObject(object: Everscale.RunGetMethodFift()),
            APIObject(object: Everscale.RunGetMethodFiftResponse()),
        ])
    }
}

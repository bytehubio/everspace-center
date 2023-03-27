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


final class EverSendController: RouteCollection {
    
    typealias Response = String
    
    static let shared: EverSendController = .init()
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("sendExternalMessage", use: sendExternalMessage)
    }

    func sendExternalMessage(_ req: Request) async throws -> Response {
        let content: SendExternalMessageRequest = try req.query.decode(SendExternalMessageRequest.self)
        return try await sendExternalMessage(EverClient.shared.client, content).toJson()
    }
    
    func sendExternalMessageRpc(_ req: Request) async throws -> Response {
        let content: EverJsonRPCRequest<SendExternalMessageRequest> = try req.content.decode(EverJsonRPCRequest<SendExternalMessageRequest>.self)
        return try JsonRPCResponse<EverClient.SendExternalMessage>(id: content.id,
                                                                   result: try await sendExternalMessage(EverClient.shared.client, content.params)).toJson()
    }
}

extension EverSendController {
    
    struct SendExternalMessageRequest: Content {
        var boc: String = ""
    }
    
    func sendExternalMessage(_ client: TSDKClientModule,
                             _ content: SendExternalMessageRequest
    ) async throws -> EverClient.SendExternalMessage {
        try await EverClient.sendExternalMessage(client: client, boc: content.boc)
    }

    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "send",
                          description: "Controller where we can manage users",
                          actions: [
                APIAction(method: .get,
                          route: "/everscale/sendExternalMessageRequest",
                          summary: "",
                          description: "Get Account Transactions",
                          parametersObject: SendExternalMessageRequest(),
                          responses: [
                            .init(code: "200",
                                  description: "Specific user",
                                  type: .object(JsonRPCResponse<EverClient.SendExternalMessage>.self, asCollection: false))
                          ])
            ])
        ).add([
            APIObject(object: JsonRPCResponse<EverClient.SendExternalMessage>(result: .init())),
            APIObject(object: EverClient.SendExternalMessage()),
        ])
    }
}

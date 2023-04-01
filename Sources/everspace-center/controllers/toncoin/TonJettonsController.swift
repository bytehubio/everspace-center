//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 01.04.2023.
//

import Foundation
import SwiftExtensionsPack
import Vapor
import EverscaleClientSwift
import Swiftgger


class TonJettonsController: RouteCollection {
    
    var swagger: SwaggerControllerPrtcl
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()
    
    init(_ client: TSDKClientModule, _ swagger: SwaggerControllerPrtcl) {
        self.client = client
        self.swagger = swagger
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getJettonInfo", use: getJettonInfo)
    }
    
    func getJettonInfo(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: JsonRPCRequest<TonRPCMethods, JettonInfoRequest> = try req.content.decode(JsonRPCRequest<TonRPCMethods, JettonInfoRequest>.self)
            result = JsonRPCResponse<Toncoin.ToncoinJettonInfo>(id: content.id,
                                                                     result: try await getJettonInfo(client, emptyClient, content.params)).toJson()
        } else {
            let content: JettonInfoRequest = try req.query.decode(JettonInfoRequest.self)
            result = try await getJettonInfo(client, emptyClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
}

extension TonJettonsController {
    
    struct JettonInfoRequest: Content {
        var jettonRootAddress: String = ""
    }
    
    private func getJettonInfo(_ client: TSDKClientModule,
                               _ emptyClient: TSDKClientModule,
                               _ content: JettonInfoRequest
    ) async throws -> Toncoin.ToncoinJettonInfo {
        try await Toncoin.tonGetJettonInfo(client: client, emptyClient: client, rootAddr: content.jettonRootAddress)
    }
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "jettons",
                          description: "Jettons Controller",
                          actions: [
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getJettonInfo",
                                      summary: "",
                                      description: "get Jetton Info",
                                      parametersObject: JettonInfoRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Toncoin.ToncoinJettonInfo>.self, asCollection: false))
                                      ])
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<Toncoin.ToncoinJettonInfo>(result: .init())),
            APIObject(object: JettonInfoRequest()),
        ])
    }

}

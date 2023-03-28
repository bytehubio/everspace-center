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


class EverSendController: RouteCollection {
    
    typealias Response = String
    var swagger: SwaggerControllerPrtcl
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()
    
    init(_ client: TSDKClientModule, _ swagger: SwaggerControllerPrtcl) {
        self.client = client
        self.swagger = swagger
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("sendExternalMessage", use: sendExternalMessage)
        routes.post("waitForTransaction", use: sendExternalMessage)
    }
    
    func sendExternalMessage(_ req: Request) async throws -> Response {
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<SendExternalMessageRequest> = try req.content.decode(EverJsonRPCRequest<SendExternalMessageRequest>.self)
            return try JsonRPCResponse<Everscale.SendExternalMessage>(id: content.id,
                                                                      result: try await sendExternalMessage(client, content.params)).toJson()
        } else {
            let content: SendExternalMessageRequest = try req.query.decode(SendExternalMessageRequest.self)
            return try await sendExternalMessage(client, content).toJson()
        }
        
    }
    
    func waitForTransaction(_ req: Request) async throws -> Response {
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<WaitForTransactionRequest> = try req.content.decode(EverJsonRPCRequest<WaitForTransactionRequest>.self)
            return try JsonRPCResponse<TSDKResultOfProcessMessage>(id: content.id,
                                                                   result: try await waitForTransaction(client, content.params)).toJson()
        } else {
            let content: WaitForTransactionRequest = try req.query.decode(WaitForTransactionRequest.self)
            return try await waitForTransaction(client, content).toJson()
        }
        
    }
}

extension EverSendController {
    
    struct SendExternalMessageRequest: Content {
        var boc: String = ""
    }
    
    struct WaitForTransactionRequest: Content {
        var boc: String = ""
        var shard_block_id: String = ""
    }
    
    func sendExternalMessage(_ client: TSDKClientModule,
                             _ content: SendExternalMessageRequest
    ) async throws -> Everscale.SendExternalMessage {
        try await Everscale.sendExternalMessageGQL(client: client, boc: content.boc)
    }
    
    func waitForTransaction(_ client: TSDKClientModule,
                            _ content: WaitForTransactionRequest
    ) async throws -> TSDKResultOfProcessMessage {
        let result = try await client.processing.wait_for_transaction(TSDKParamsOfWaitForTransaction(message: content.boc,
                                                                                                     shard_block_id: content.shard_block_id,
                                                                                                     send_events: false))
        return result
    }
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "send",
                          description: "Send Controller",
                          actions: [
                            APIAction(method: .post,
                                      route: "/\(swagger.route)/sendExternalMessage",
                                      summary: "",
                                      description: "Send External Message",
                                      parametersObject: SendExternalMessageRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.SendExternalMessage>.self, asCollection: false))
                                      ]),
                            APIAction(method: .post,
                                      route: "/\(swagger.route)/waitForTransaction",
                                      summary: "",
                                      description: "Wait For Transactions",
                                      parametersObject: WaitForTransactionRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<TSDKResultOfProcessMessage>.self, asCollection: false))
                                      ])
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<Everscale.SendExternalMessage>(result: .init())),
            APIObject(object: Everscale.SendExternalMessage()),
            APIObject(object: WaitForTransactionRequest()),
            APIObject(object: JsonRPCResponse<TSDKResultOfProcessMessage>(result: TSDKResultOfProcessMessage(transaction: ["...":"..."].toAnyValue(), out_messages: [], decoded: nil, fees: TSDKTransactionFees(in_msg_fwd_fee: 1, storage_fee: 1, gas_fee: 1, out_msgs_fwd_fee: 1, total_account_fees: 1, total_output: 1, ext_in_msg_fee: 1, total_fwd_fees: 1, account_fees: 1)))),
            APIObject(object: TSDKResultOfProcessMessage(transaction: ["...":"..."].toAnyValue(), out_messages: [], decoded: nil, fees: TSDKTransactionFees(in_msg_fwd_fee: 1, storage_fee: 1, gas_fee: 1, out_msgs_fwd_fee: 1, total_account_fees: 1, total_output: 1, ext_in_msg_fee: 1, total_fwd_fees: 1, account_fees: 1))),
        ])
    }
}

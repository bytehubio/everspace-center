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
    var swagger: SwaggerControllerPrtcl
    let network: String
    
    init(_ swagger: SwaggerControllerPrtcl, _ network: String) {
        self.swagger = swagger
        self.network = network
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.post("sendExternalMessage", use: sendExternalMessage)
        routes.post("waitForTransaction", use: waitForTransaction)
        routes.post("sendAndWaitTransaction", use: sendAndWaitTransaction)
        routes.post("estimateFee", use: estimateFee)
    }
    
    func sendExternalMessage(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "sendExternalMessage", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, SendExternalMessageRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, SendExternalMessageRequest>.self)
            result = try JsonRPCResponse<Everscale.SendExternalMessage>(id: content.id,
                                                                    result: try await sendExternalMessage(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "sendExternalMessage", .queryParams)
            let content: SendExternalMessageRequest = try req.query.decode(SendExternalMessageRequest.self)
            result = try await sendExternalMessage(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func waitForTransaction(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "waitForTransaction", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, WaitForTransactionRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, WaitForTransactionRequest>.self)
            result = try JsonRPCResponse<TSDKResultOfProcessMessage>(id: content.id,
                                                                 result: try await waitForTransaction(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "waitForTransaction", .queryParams)
            let content: WaitForTransactionRequest = try req.query.decode(WaitForTransactionRequest.self)
            result = try await waitForTransaction(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func sendAndWaitTransaction(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "sendAndWaitTransaction", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, SendExternalMessageRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, SendExternalMessageRequest>.self)
            result = try JsonRPCResponse<TSDKResultOfProcessMessage>(id: content.id,
                                                                 result: try await sendAndWaitTransaction(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "sendAndWaitTransaction", .queryParams)
            let content: SendExternalMessageRequest = try req.query.decode(SendExternalMessageRequest.self)
            result = try await sendAndWaitTransaction(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func estimateFee(_ req: Request) async throws -> Response {
        let sdkClient: TSDKClientModule = try await sdkClientActor.client(req, network)
        let result: String!
        if req.url.string.contains("jsonRpc") {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "estimateFee", .jsonRpc)
            let content: JsonRPCRequest<EverRPCMethods, Everscale.EstimateFeeRequest> = try req.content.decode(JsonRPCRequest<EverRPCMethods, Everscale.EstimateFeeRequest>.self)
            result = try JsonRPCResponse<Everscale.EstimateFeeResponse>(id: content.id,
                                                                    result: try await estimateFee(sdkClient, content.params)).toJson()
        } else {
            Stat.methodUse(req.headers[API_KEY_NAME].first, network, "estimateFee", .queryParams)
            let content: Everscale.EstimateFeeRequest = try req.query.decode(Everscale.EstimateFeeRequest.self)
            result = try await estimateFee(sdkClient, content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
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
        try await Everscale.sendExternalMessage(client: client, boc: content.boc)
        //        try await Everscale.sendExternalMessageGQL(client: client, boc: content.boc)
    }
    
    func waitForTransaction(_ client: TSDKClientModule,
                            _ content: WaitForTransactionRequest
    ) async throws -> TSDKResultOfProcessMessage {
        let result = try await client.processing.wait_for_transaction(TSDKParamsOfWaitForTransaction(message: content.boc,
                                                                                                     shard_block_id: content.shard_block_id,
                                                                                                     send_events: false))
        return result
    }
    
    func sendAndWaitTransaction(_ client: TSDKClientModule,
                                _ content: SendExternalMessageRequest
    ) async throws -> TSDKResultOfProcessMessage {
        let out = try await sendExternalMessage(client, content)
        let result = try await client.processing.wait_for_transaction(TSDKParamsOfWaitForTransaction(message: content.boc,
                                                                                                     shard_block_id: out.shard_block_id,
                                                                                                     send_events: false))
        return result
    }
    
    func estimateFee(_ client: TSDKClientModule,
                     _ content: Everscale.EstimateFeeRequest
    ) async throws -> Everscale.EstimateFeeResponse {
        try await Everscale.estimateFee(client: client,
                                        encodedMessage: content.encodedMessage,
                                        boc: content.accountBoc,
                                        skip_transaction_check: content.skip_transaction_check,
                                        return_updated_account: content.return_updated_account,
                                        unlimited_balance: content.unlimited_balance,
                                        type: content.type)
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
                                      ]),
                            APIAction(method: .post,
                                      route: "/\(swagger.route)/sendAndWaitTransaction",
                                      summary: "",
                                      description: "Send Boc And Wait For Transaction",
                                      parametersObject: SendExternalMessageRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<TSDKResultOfProcessMessage>.self, asCollection: false))
                                      ]),
                            APIAction(method: .post,
                                      route: "/\(swagger.route)/estimateFee",
                                      summary: "",
                                      description: "Estimate Fee",
                                      parametersObject: Everscale.EstimateFeeRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.EstimateFeeResponse>.self, asCollection: false))
                                      ])
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<Everscale.SendExternalMessage>(result: .init())),
            APIObject(object: Everscale.SendExternalMessage()),
            APIObject(object: WaitForTransactionRequest()),
            APIObject(object: JsonRPCResponse<TSDKResultOfProcessMessage>(result: TSDKResultOfProcessMessage(transaction: ["...":"..."].toAnyValue(), out_messages: [], decoded: nil, fees: TSDKTransactionFees(in_msg_fwd_fee: 1, storage_fee: 1, gas_fee: 1, out_msgs_fwd_fee: 1, total_account_fees: 1, total_output: 1, ext_in_msg_fee: 1, total_fwd_fees: 1, account_fees: 1)))),
            APIObject(object: TSDKResultOfProcessMessage(transaction: ["...":"..."].toAnyValue(), out_messages: [], decoded: nil, fees: TSDKTransactionFees(in_msg_fwd_fee: 1, storage_fee: 1, gas_fee: 1, out_msgs_fwd_fee: 1, total_account_fees: 1, total_output: 1, ext_in_msg_fee: 1, total_fwd_fees: 1, account_fees: 1))),
            APIObject(object: Everscale.EstimateFeeRequest()),
            APIObject(object: JsonRPCResponse<Everscale.EstimateFeeResponse>(result: Everscale.EstimateFeeResponse())),
        ])
    }
}

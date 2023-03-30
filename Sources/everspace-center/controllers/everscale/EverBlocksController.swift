
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


class EverBlocksController: RouteCollection {
    
    var swagger: SwaggerControllerPrtcl
    var client: TSDKClientModule
    var emptyClient: TSDKClientModule = SDKClient.makeEmptyClient()
    
    init(_ client: TSDKClientModule, _ swagger: SwaggerControllerPrtcl) {
        self.client = client
        self.swagger = swagger
        prepareSwagger(swagger.openAPIBuilder)
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("getConfigParams", use: getConfigParams)
        routes.get("getLastMasterBlock", use: getLastMasterBlock)
        routes.get("getBlock", use: getBlock)
        routes.get("getRawBlock", use: getRawBlock)
        routes.get("lookupBlock", use: lookupBlock)
    }
    
    func getConfigParams(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<BlockConfigRequest> = try req.content.decode(EverJsonRPCRequest<BlockConfigRequest>.self)
            result = JsonRPCResponse<BlockConfigResponse>(id: content.id,
                                                          result: try await getConfigParams(client, content.params, req)).toJson()
        } else {
            let content: BlockConfigRequest = try req.query.decode(BlockConfigRequest.self)
            result = try await getConfigParams(client, content, req).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getLastMasterBlock(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<[String: String]> = try req.content.decode(EverJsonRPCRequest<[String: String]>.self)
            result = JsonRPCResponse<Everscale.LastMasterBlockResponse>(id: content.id,
                                                                        result: try await getLastMasterBlock(client)).toJson()
        } else {
            result = try await getLastMasterBlock(client).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getBlock(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<Everscale.GetBlockRequest> = try req.content.decode(EverJsonRPCRequest<Everscale.GetBlockRequest>.self)
            result = JsonRPCResponse<Everscale.BlockResponse>(id: content.id,
                                                              result: try await getBlock(client, content: content.params)).toJson()
        } else {
            let content: Everscale.GetBlockRequest = try req.query.decode(Everscale.GetBlockRequest.self)
            result = try await getBlock(client, content: content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func getRawBlock(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<Everscale.GetBlockRequest> = try req.content.decode(EverJsonRPCRequest<Everscale.GetBlockRequest>.self)
            result = JsonRPCResponse<Everscale.RawBlockResponse>(id: content.id,
                                                                 result: try await getRawBlock(client, content: content.params)).toJson()
        } else {
            let content: Everscale.GetBlockRequest = try req.query.decode(Everscale.GetBlockRequest.self)
            result = try await getRawBlock(client, content: content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
    
    func lookupBlock(_ req: Request) async throws -> Response {
        let result: String!
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<Everscale.LookupBlockRequest> = try req.content.decode(EverJsonRPCRequest<Everscale.LookupBlockRequest>.self)
            result = JsonRPCResponse<Everscale.LookupBlockResponse>(id: content.id,
                                                                    result: try await lookupBlock(client, content: content.params)).toJson()
        } else {
            let content: Everscale.LookupBlockRequest = try req.query.decode(Everscale.LookupBlockRequest.self)
            result = try await lookupBlock(client, content: content).toJson()
        }
        return try await encodeResponse(for: req, json: result)
    }
}


extension EverBlocksController {
    
    struct BlockConfigRequest: Content {
        var number: Int = 1
    }
    
    struct BlockConfigResponse: Content {
        var param: Int = 1
        var boc: String = "..."
    }
    
    func getConfigParams(_ client: TSDKClientModule, _ content: BlockConfigRequest, _ req: Request) async throws -> BlockConfigResponse {
        if content.number > 34 || content.number < 0 {
            throw makeError(AppError.mess("Number out of range"))
        }
        let queryResult = try await client.net.query(TSDKParamsOfQuery(query: "query{ blocks(filter: {workchain_id: {eq: -1}, key_block: {eq: true}}, limit: 1) {master{config_addr}}}"))
        guard let address = ((((queryResult.result.toDictionary()?["data"] as? [String: Any])?["blocks"] as? [Any])?.first as? [String: Any])?["master"] as? [String: Any])?["config_addr"] as? String
        else {
            throw makeError(AppError.mess("Config Address not found"))
        }
        let account = try await Everscale.getAccount(client: client, accountAddress: "-1:\(address)")
        let fileManager: FileManager = FileManager.default
        let uniqName: String = "\(UUID())-\(req.id).boc"
        let filePath: String = "\(pathToRootDirectory)/get_congig_params/\(uniqName)"
        let tempFileURL: URL = URL(fileURLWithPath: filePath)
        if !fileManager.fileExists(atPath: filePath) {
            fileManager.createFile(atPath: filePath, contents: nil, attributes: nil)
        }
        guard let contentData = account.data.data(using: .utf8) else {
            throw makeError(AppError.mess("Can not convert string to Data"))
        }
        try await req.fileio.writeFile(ByteBuffer(data: contentData), at: filePath)
        let command: String = "node \(pathToRootDirectory)/get_congig_params/cfgparam.js \(filePath) \(content.number)"
        let out: String = try await systemCommand(command, timeOutSec: 7)
        try fileManager.removeItem(at: tempFileURL)
        let model: BlockConfigResponse = try out.toModel(BlockConfigResponse.self)
        
        return model
    }
    
    
    func getLastMasterBlock(_ client: TSDKClientModule) async throws -> Everscale.LastMasterBlockResponse {
        try await Everscale.getLastMasterBlock(client: client)
    }
    
    func getBlock(_ client: TSDKClientModule, content: Everscale.GetBlockRequest) async throws -> Everscale.BlockResponse {
        try await Everscale.getBlock(client: client, content: content)
    }
    
    func getRawBlock(_ client: TSDKClientModule, content: Everscale.GetBlockRequest) async throws -> Everscale.RawBlockResponse {
        try await Everscale.getRawBlock(client: client, content: content)
    }
    
    func lookupBlock(_ client: TSDKClientModule, content: Everscale.LookupBlockRequest) async throws -> Everscale.LookupBlockResponse {
        try await Everscale.lookupBlock(client: client, content: content)
    }
    
    
    @discardableResult
    func prepareSwagger(_ openAPIBuilder: OpenAPIBuilder) -> OpenAPIBuilder {
        return openAPIBuilder.add(
            APIController(name: "Blocks",
                          description: "Blocks Controller",
                          actions: [
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getConfigParams",
                                      summary: "",
                                      description: "Description",
                                      parametersObject: BlockConfigRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<BlockConfigResponse>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getLastMasterBlock",
                                      summary: "",
                                      description: "Get Last Master Block",
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.LastMasterBlockResponse>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getBlock",
                                      summary: "",
                                      description: "Get Block",
                                      parametersObject: Everscale.GetBlockRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.BlockResponse>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/getRawBlock",
                                      summary: "",
                                      description: "Get Raw Block",
                                      parametersObject: Everscale.GetBlockRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.RawBlockResponse>.self, asCollection: false))
                                      ]),
                            APIAction(method: .get,
                                      route: "/\(swagger.route)/lookupBlock",
                                      summary: "",
                                      description: "Lookup Block",
                                      parametersObject: Everscale.LookupBlockRequest(),
                                      responses: [
                                        .init(code: "200",
                                              description: "Description",
                                              type: .object(JsonRPCResponse<Everscale.LookupBlockResponse>.self, asCollection: false))
                                      ]),
                          ])
        ).add([
            APIObject(object: JsonRPCResponse<BlockConfigResponse>(result: BlockConfigResponse())),
            APIObject(object: BlockConfigRequest()),
            APIObject(object: JsonRPCResponse<Everscale.LastMasterBlockResponse>(result: Everscale.LastMasterBlockResponse())),
            APIObject(object: Everscale.LastMasterBlockResponse()),
            APIObject(object: JsonRPCResponse<Everscale.BlockResponse>(result: Everscale.BlockResponse())),
            APIObject(object: Everscale.BlockResponse()),
            APIObject(object: JsonRPCResponse<Everscale.RawBlockResponse>(result: Everscale.RawBlockResponse())),
            APIObject(object: Everscale.RawBlockResponse()),
            APIObject(object: JsonRPCResponse<Everscale.LookupBlockResponse>(result: Everscale.LookupBlockResponse())),
            APIObject(object: Everscale.LookupBlockResponse()),
        ])
    }
}


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
        routes.get("getConfigParams", use: getConfigParams)
    }
    
    func getConfigParams(_ req: Request) async throws -> Response {
        if req.url.string.contains("jsonRpc") {
            let content: EverJsonRPCRequest<BlockConfigRequest> = try req.content.decode(EverJsonRPCRequest<BlockConfigRequest>.self)
            return try JsonRPCResponse<BlockConfigResponse>(id: content.id,
                                                            result: try await getConfigParams(client, content.params, req)).toJson()
        } else {
            let content: BlockConfigRequest = try req.query.decode(BlockConfigRequest.self)
            return try await getConfigParams(client, content, req).toJson()
        }
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
            ])
        ).add([
            APIObject(object: JsonRPCResponse<BlockConfigResponse>(result: BlockConfigResponse())),
            APIObject(object: BlockConfigRequest()),
        ])
    }
}

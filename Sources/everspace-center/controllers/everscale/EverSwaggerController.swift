//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 26.03.2023.
//

import Foundation
import Vapor
import Swiftgger

final class EverSwaggerController: RouteCollection, SwaggerControllerPrtcl {
    
    var route: String
    let openAPIBuilder: OpenAPIBuilder = .init(
        title: "EVERSCALE API",
        version: "1.0.0",
        description: """
        [ALL TVM BLOCKCHAIN'S API](\(Domain))\n\n\n
        **Authorization information is on the main page**\n\n\n
        You can use JSON RPC requests:\n
            \(Domain)/everscale/jsonRpc\n\n
        Example request:\n
            {\n
                "id": "1",\n
                "jsonrpc": "2.0",\n
                "method": "getTransactions",\n
                "params": {\n
                    "address": "...",\n
                    "limit": 1,\n
                    "lt": "...",\n
                    "to_lt": "...",\n
                    "hash": "..."\n
                }\n
            }\n\n
        **Contact:** [Telegram TVM API Support](https://t.me/everspace_center)\n
        """,
    //            termsOfService: "http://example.com/terms/",
        contact: APIContact(name: "Mail", email: "admin@bytehub.io", url: URL(string: "https://github.com/nerzh")),
    //            license: APILicense(name: "MIT", url: URL(string: "http://mit.license")),
        authorizations: [
            .apiKey(description: "b17a652df5d642a6aa6e9dae4601685a"),
//            .basic(description: "BASIC"),
//            .jwt(description: "JWT")
    //        .jwt(description: "You can get token from *sign-in* action from *Account* controller.")
        ]
    )
    
    init(_ route: String) {
        self.route = route
    }
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("", use: index)
        routes.get("swagger", use: show)
    }
    
    func index(_ req: Request) async throws -> Response {
        let html: String = """
        <!DOCTYPE html>
        <html lang="en">
          <head>
            <meta charset="UTF-8">
            <title>Swagger UI</title>
            <link rel="stylesheet" type="text/css" href="css/swagger/swagger-ui.css" />
            <link rel="stylesheet" type="text/css" href="css/swagger/index.css" />
            <link rel="icon" type="image/png" href="images/swagger/favicon-32x32.png" sizes="32x32" />
            <link rel="icon" type="image/png" href="images/swagger/favicon-16x16.png" sizes="16x16" />
          </head>
        
          <body>
            <div id="swagger-ui"></div>
            <script src="/js/swagger/swagger-ui-bundle.js" charset="UTF-8"> </script>
            <script src="/js/swagger/swagger-ui-standalone-preset.js" charset="UTF-8"> </script>
            <script src="/js/swagger/swagger-initializer-everscale.js" charset="UTF-8"> </script>
          </body>
        </html>
        """
        
        return try await encodeResponse(for: req, html: html)
    }
    
    func show(_ req: Request) async throws -> Response {
        try await encodeResponse(for: req, json: try openAPIBuilder.built().toJson())
    }
}

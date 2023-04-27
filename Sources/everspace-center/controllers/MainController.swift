//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 24.03.2023.
//

import Foundation
import Vapor
import Swiftgger
import EverscaleClientSwift
import SwiftExtensionsPack
import BigInt

final class MainController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("", use: index)
        #if DEBUG
        routes.get("test", use: test)
        #endif
    }
    
    func index(_ req: Request) async throws -> Response {
        pe("index")
//        throw AppError("test")
        let html: String = """
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Everspace Center. Everscale API. Toncoin API. Venom API.</title>
            <!-- Google tag (gtag.js) -->
            <script async src="https://www.googletagmanager.com/gtag/js?id=G-BQS5FC2ZLJ"></script>
            <script>
              window.dataLayer = window.dataLayer || [];
              function gtag(){dataLayer.push(arguments);}
              gtag('js', new Date());

              gtag('config', 'G-BQS5FC2ZLJ');
            </script>

            <link href='https://fonts.googleapis.com/css?family=JetBrains Mono' rel='stylesheet'>

            <style>
                body {
                    font-family: 'JetBrains Mono';
                    font-size: 16px;
                    max-width: 80vh;
                    margin-left: auto;
                    margin-right: auto;
                    width: 95%;
                }

                a {
                    color: blue;
                }

                .sep-top {
                    margin-top: 10px;
                }

                .footer {
                    width: 100%;
                    text-align: center;
                }
            </style>
        </head>

        <body>
            <h1 id="everspace-center-api" style="text-align: center;">Everspace Center API</h1>

            <p>Welcome! We provide access to HTTP API for TVM compatible blockchains.</p>

            <h2 id="available-networks">Available networks</h2>
            <ul>
                <li><a href="\(Domain)/everscale"><code>Everscale Mainnet</code></a></li>
                <li><a href="\(Domain)/everscale-devnet"><code>Everscale Devnet</code></a></li>
                <li><a href="\(Domain)/everscale-rfld"><code>Everscale RFLD Devnet</code></a></li>
                
                <div class="sep-top"></div>
                <li><a href="\(Domain)/venom"><code>VENOM Mainnet</code></a></li>
                <li><a href="\(Domain)/venom-testnet"><code>VENOM Testnet</code></a></li>

                <div class="sep-top"></div>
                <li><a href="\(Domain)/toncoin"><code>TON Mainnet</code></a></li>
                <li><a href="\(Domain)/toncoin-testnet"><code>TON Testnet</code></a></li>
            </ul>
            
            <h2 id="available-networks">Authorization</h2>
            <p>For authorization you need to get an API-KEY here <a href="https://dashboard.evercloud.dev">https://dashboard.evercloud.dev</a> and add your key to the <b>X-API-KEY</b> request headers.</p>
        
            <iframe width="650"
                    height="780"
                    frameborder="0"
                    src="https://networkload.everscale.repl.co/">
            </iframe>

            <footer>
                <br>
                <div class="footer">
                    <p>Made on Apple Swift with ❤️ by <a href="https://everspace.app/" target="_blank">Everspace Wallet Team</a></p>
                    <p><a href="https://t.me/everspace_center">Support</a> | <a href="mailto:admin@bytehub.io">E-mail</a></p>
                </div>
            </footer>

        </body>
        </html>
        """
        
        return try await encodeResponse(for: req, html: html)
    }
    
    #if DEBUG
    init() {
        Task {
            try await testFile()
        }
    }
    #endif
}

#if DEBUG
extension MainController {
    
    func test(_ req: Request) async throws -> Response {
//        let sdkClient: SDKClient = try getSDKClient(apiKey: "b17a652df5d642a6aa6e9dae4601685a", network: EVERSCALE_SDK_DOMAIN_ENV)
//        let version = try await sdkClient.emptyClient.version()
//        pe(version.version)
//        
//        
//        let addr = "Uf82RDKWzkyabxdMwg-WROan8fXx3QVC1Y6C7lRLMlKxsjb_"
//        let AccountId = try await sdkClient.emptyClient.utils.convert_address(TSDKParamsOfConvertAddress(address: addr, output_format: TSDKAddressStringFormat(type: .AccountId)))
//        pe("AccountId", AccountId)
//        
//        let hex = try await sdkClient.emptyClient.utils.convert_address(TSDKParamsOfConvertAddress(address: addr, output_format: TSDKAddressStringFormat(type: .Hex)))
//        pe("Hex", hex)
        
        
        return try await encodeResponse(for: req, json: "{}")
    }
}
#endif












//extension SwaggerController {
//
//    static let openAPIBuilder: OpenAPIBuilder = .init(
//        title: "Everspace Center API",
//        version: "1.0.0",
//        description: """
//                This is incredible Everscale API.\n
//        **Now temporarily without authorization.**\n
//        **Everscale API:** [Everscale API Link](\(\(Domain))/everscale)\n
//        **Contact:** [Telegram](https://t.me/nerzh)\n
//        """,
//    //            termsOfService: "http://example.com/terms/",
//        contact: APIContact(name: "Mail", email: "admin@bytehub.io", url: URL(string: "https://github.com/nerzh")),
//    //            license: APILicense(name: "MIT", url: URL(string: "http://mit.license")),
//        authorizations: [
//    //        .jwt(description: "You can get token from *sign-in* action from *Account* controller.")
//        ]
//    )
//}

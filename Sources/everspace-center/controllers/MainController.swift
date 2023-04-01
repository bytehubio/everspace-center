//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 24.03.2023.
//

import Foundation
import Vapor
import Swiftgger

final class MainController: RouteCollection {
    
    func boot(routes: Vapor.RoutesBuilder) throws {
        routes.get("", use: index)
    }
    
    func index(_ req: Request) async throws -> Response {
        let html: String = """
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="UTF-8">
            <meta http-equiv="X-UA-Compatible" content="IE=edge">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Everspace Center. Everscale API. Toncoin API. Venom API.</title>

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
            <h1 id="everspace-center-api">Everspace Center API</h1>

            <p>Welcome! We provide access to HTTP API for TVM compatible blockchains.</p>
            <p>(now temporarily without authorization)</p>

            <h2 id="available-networks">Available networks</h2>
            <ul>
                <li><a href="\(Domain)/everscale"><code>Everscale Mainnet</code></a></li>
                <li><a href="\(Domain)/everscale-devnet"><code>Everscale Devnet</code></a></li>
                <li><a href="\(Domain)/everscale-rfld"><code>Everscale RFLD Devnet</code></a></li>
                
                <div class="sep-top"></div>
                <li><a href="\(Domain)/venom-testnet"><code>VENOM TESTNET</code></a></li>

                <div class="sep-top"></div>
                <li><a href="\(Domain)/toncoin"><code>TON Mainnet</code></a></li>
                <!-- <li><code>TON Testnet (soon)</code></li> -->
                <!-- <div class="sep-top"></div>
                <li><a href="\(Domain)/venom-testnet"><code>Venom Testnet</code></a></li>
                <div class="sep-top"></div>

                <li><a href="\(Domain)/everscale-n01-fld-dapp"><code>Everscale n01-fld-dapp</code></a></li>
                <li><a href="\(Domain)/everscale-n02-fld-dapp"><code>Everscale n02-fld-dapp</code></a></li>
                <li><a href="\(Domain)/everscale-n03-fld-dapp"><code>Everscale n03-fld-dapp</code></a></li>
                <li><a href="\(Domain)/everscale-n04-fld-dapp"><code>Everscale n04-fld-dapp</code></a></li> -->
            </ul>

            <footer>
                <br>
                <div class="footer">
                    Made with ❤️ by <a href="https://everspace.app/" target="_blank">Everspace Wallet Team</a>
                    | <a href="https://t.me/everspace_center">Telegram</a>
                    | <a href="mailto:admin@bytehub.io">E-mail</a>
                </div>
            </footer>

        </body>
        </html>
        """
        
        return try await encodeResponse(for: req, html: html)
    }
}
//
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

//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 17.04.2023.
//

import Foundation
import EverscaleClientSwift
import BigInt
import SwiftExtensionsPack

func testFile() async throws {
#if DEBUG
    //    let client = SDKClientActor()
    //    for i in 0...500000 {
    //        autoReleasePool {
    //            Task {
    //                var k = ""
    //                if i % 2 == 0 {
    //                    k = "b17a652df5d642a6aa6e9dae4601685a"
    //                } else {
    //                    k = "99ccda31fa2145c7b775aabc1c88a00b"
    //                }
    //                let cl: TSDKClientModule = try await client.client(k, EVERSCALE_SDK_DOMAIN_ENV)
    //                let out = try await Everscale.getLastMasterBlock(client: cl)
    //                pe(out.id, i)
    //            }
    //        }
    //        usleep(10000)
    //    }
//    let mess = "te6ccgEBBAEA0gABRYgAS46UKxHnB75ZpXVnZPs/KbM6QxYBT9bAvBfIZFMAH7wMAQHhyetxBGIru62TMku6+T1JED+zJ0+3K3JLwylhFYEjnePhDOB/VUgCV5JpBJ/ZgzCAsnKB8DJ9yQQn+WE9VFFKBUGo2zyLEtw2pOxGWiqJPpk+3dunLfGFFCp2InI+hTR6wAAAYfU3H9PZE8RsUzuZGyACAWWAHAzePt8rns8TYEabPB05y6d0rCO55VVcIIepndt7v3NAAAAAAAAAAAAAAAAAAAAACCgDAAA="
//    let boc = "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"
//    
//    let out = try await everClient.tvm.run_executor(TSDKParamsOfRunExecutor.init(message: mess,
//                                                                                 account: TSDKAccountForExecutor.init(type: .Account,
//                                                                                                                      boc: boc,
//                                                                                                                      unlimited_balance: true),
//                                                                                 execution_options: TSDKExecutionOptions.init(blockchain_config: nil,
//                                                                                                                              block_time: nil,
//                                                                                                                              block_lt: nil,
//                                                                                                                              transaction_lt: nil,
//                                                                                                                              chksig_always_succeed: nil,
//                                                                                                                              signature_id: nil),
//                                                                                 abi: nil,
//                                                                                 skip_transaction_check: true,
//                                                                                 boc_cache: nil,
//                                                                                 return_updated_account: false))
//    
//    
//    pe(out)
#endif
}

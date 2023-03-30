//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 30.03.2023.
//

import Foundation

import EverscaleClientSwift
import BigInt
import SwiftExtensionsPack
import Vapor

extension Everscale {
    
    struct EstimateFeeRequest: Content {
        var encodedMessage: String = ""
        var accountBoc: String = ""
        var skip_transaction_check: Bool? = false
        var return_updated_account: Bool? = false
        var unlimited_balance: Bool? = false
        var type: TSDKAccountForExecutorEnumTypes? = .Account
    }
    
    struct EstimateFeeResponse: Content {
        /// Fee for account storage
        var storage_fee: Int = 1
        /// Fee for processing
        var gas_fee: Int = 1
        /// Fee for inbound external message import.
        var ext_in_msg_fee: Int = 1
        /// Total fees the account pays for message forwarding
        var total_fwd_fees: Int = 1
        /// Total account fees for the transaction execution. Compounds of storage_fee + gas_fee + ext_in_msg_fee + total_fwd_fees
        var account_fees: Int = 1
    }
    
    class func estimateFee(client: TSDKClientModule,
                           encodedMessage: String,
                           boc: String,
                           skip_transaction_check: Bool? = nil,
                           return_updated_account: Bool? = nil,
                           unlimited_balance: Bool? = nil,
                           type: TSDKAccountForExecutorEnumTypes? = nil
    ) async throws -> EstimateFeeResponse {
        let paramsOfRunExecutor: TSDKParamsOfRunExecutor = .init(message: encodedMessage,
                                                                 account: TSDKAccountForExecutor(type: type ?? .Account,
                                                                                                 boc: boc,
                                                                                                 unlimited_balance: unlimited_balance ?? true),
                                                                 execution_options: nil,
                                                                 abi: nil,
                                                                 skip_transaction_check: skip_transaction_check ?? false,
                                                                 boc_cache: nil,
                                                                 return_updated_account: return_updated_account ?? false)
        let fees = try await client.tvm.run_executor(paramsOfRunExecutor)
        
        return EstimateFeeResponse(storage_fee: fees.fees.storage_fee,
                                   gas_fee: fees.fees.gas_fee,
                                   ext_in_msg_fee: fees.fees.ext_in_msg_fee,
                                   total_fwd_fees: fees.fees.total_fwd_fees,
                                   account_fees: fees.fees.account_fees)
    }
}

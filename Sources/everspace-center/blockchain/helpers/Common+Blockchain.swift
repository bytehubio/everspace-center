//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 26.03.2023.
//

import Foundation
import Vapor
import EverscaleClientSwift
import SwiftExtensionsPack


func tonConvertAddrToEverFormat(client: TSDKClientModule, _ address: String) async throws -> String {
    if address[#":"#] {
        return address
    } else {
        let newAddr: TSDKResultOfConvertAddress = try await client.utils.convert_address(
            TSDKParamsOfConvertAddress(address: address,
                                       output_format: TSDKAddressStringFormat(type: .AccountId))
        )
        if newAddr.address[#":"#] {
            return newAddr.address
        } else {
            let wc: UInt8 = address.base64ToByteArray()[1]
            return "\(wc):\(newAddr.address)"
        }
    }
}

func tonConvertAddrToToncoinFormat(client: TSDKClientModule, _ address: String) async throws -> String {
    let model = try await client.utils.convert_address(
        TSDKParamsOfConvertAddress(address: address,
                                   output_format: TSDKAddressStringFormat(type: .Base64,
                                                                          url: true,
                                                                          test: false,
                                                                          bounce: true)))
    return model.address
}

//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 29.09.2021.
//

import Foundation

struct TransactionModel: Codable {
    var id: String
    var account_addr: String
    var balance_delta: String
    var now: Int
    var now_string: String
    var tr_type: Int
    var tr_type_name: String
    var total_fees: String
    var out_msgs: [String]
    var in_message: InMessage?
    var out_messages: [OutMessage]?

    var isIncomingTransaction: Bool { out_msgs.isEmpty }
    var fromAddr: String {
        if isIncomingTransaction {
            return in_message?.src ?? ""
        } else {
            return account_addr
        }
    }
    var toAddr: String {
        if isIncomingTransaction {
            return account_addr
        } else {
            var dest: String = ""
            (out_messages ?? []).forEach { message in
                if message.value != nil {
                    dest = message.dst
                }
            }
            return dest
        }
    }
    var value: String {
        if isIncomingTransaction {
            return in_message?.value ?? "0"
        } else {
            var val: String = "0"
            (out_messages ?? []).forEach { message in
                if message.value != nil {
                    val = message.value!
                }
            }
            return val
        }
    }

    struct InMessage: Codable {
        var id: String
        var src: String
        var value: String?
        var dst: String
    }

    struct OutMessage: Codable {
        var id: String
        var dst: String
        var value: String?
    }
}

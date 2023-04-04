//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 04.04.2023.
//

import Foundation
import PostgresBridge

extension PostgresRow {
    public var toDictionary: [String: PostgresData] {
        var row: [String: PostgresData] = [:]
        for cell in self {
            row[cell.columnName] = PostgresData(
                type: cell.dataType,
                typeModifier: 0,
                formatCode: cell.format,
                value: cell.bytes
            )
        }
        return row
    }
}

//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Vapor
import PostgresBridge

func migrations(_ app: Application) async throws {
    let migrator = app.postgres.migrator(for: .default)

    migrator.add(Сreate_Statistic_1.self)

    try await migrator.migrate()
//    try await migrator.revertLast()
//    try await migrator.revertAll()
}

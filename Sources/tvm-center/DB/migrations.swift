//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 02.04.2023.
//

import Foundation
import Fluent
import FluentPostgresDriver
import Vapor

func migrateDB(app: Application) async throws {
    do {
        let dbIdentifier: String = "default"
        app.migrations.add(Сreate_Statistic_1(), to: .init(string: dbIdentifier))
        
        try await app.autoMigrate()
    } catch {
        print(String(reflecting: error))
        throw AdvageError(error, errorLevel: .debug)
    }
}

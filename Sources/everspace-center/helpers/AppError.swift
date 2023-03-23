//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.09.2021.
//

import Foundation
import SwiftExtensionsPack

public struct AppError: ErrorCommon, Encodable {
    public var title: String = "Ever Api Error"
    public var reason: String = ""
    public init() {}
}

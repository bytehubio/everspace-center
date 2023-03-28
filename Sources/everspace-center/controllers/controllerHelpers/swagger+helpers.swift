//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 28.03.2023.
//

import Foundation
import Swiftgger

protocol SwaggerControllerPrtcl {
    var openAPIBuilder: OpenAPIBuilder { get }
    var route: String { get }
}

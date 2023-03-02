//
//  File.swift
//  
//
//  Created by Oleh Hudeichuk on 21.05.2021.
//

import Vapor

func routes(_ app: Application) throws {
    
    try app.register(collection: TransactionsController())

//    app.post("restart_subscribe_module") { (request) -> EventLoopFuture<String> in
//        let promise: EventLoopPromise<String> = request.eventLoop.next().makePromise()
////        TonSubscribeService2.restart { error in
////            if let error = error {
////                app.logger.error("\(error.localizedDescription)")
////                promise.fail(error)
////            } else {
////                promise.succeed("OK")
////            }
////        }
//        return promise.futureResult
//    }

//    app.get("test") { (request) -> String in
//        let notification: FCMNotification = .init(title: "TEST", body: "body")
//        let message = FCMMessage<FCMApnsPayload>(notification: notification,
//                                                 data: ["account_addr": ""])
//
//        app.fcm.batchSend(message, tokens: [""])
//        return "TEST OK"
//    }
}


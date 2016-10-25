//
//  main.swift
//  
//
//  Created by scoot on 22.10.2016.
//
//

import Foundation
import Kitura
import HeliumLogger
import LoggerAPI
import Kassandra
import protoc_gen_swift

HeliumLogger.use()

let router = Router()
let kassandra = Kassandra(host: "192.168.0.102", port: 9042)

try kassandra.connect(with: "kituratest") { result in
    if case let Result.error(err) = result {
        Log.error("Can't connect to cassandra cluster: \(err)")
    }
}

router.get("/user/:name") { request, response, next in
    guard let name = request.parameters["name"] else {
        Log.error("No parameter!")
        try response.send("No parameter!").end()
        return
    }
    
    kassandra.execute("SELECT * FROM users where name = '\(name)'") { result in
        if case let Result.error(err) = result {
            Log.error("Request error: \(err)")
            try! response.send("Request error").end()
            return
        }
        
        let rows = result.asRows!
        if rows.count != 1 {
            Log.error("User '\(name)' doesn't exist")
            try! response.send("User '\(name)' doesn't exist").end()
            return
        }
        
        guard let id = rows.first!["id"] as? UUID else {
            Log.error("Wrong id")
            try! response.send("Wrong id").end()
            return
        }
        
        try! response.send("User: '\(name)' UUID: \(id.uuidString)").end()
        
        var user = User()
        user.uuid = id.uuidString
        user.user = name
        let data = try! user.serializeProtobuf()
        
        // DEBUG
        let rawuser = try! User(protobuf: data)
        let json = try! rawuser.serializeJSON()
        print("JSON from protobuf, only for debug: \(json)")
    }
}

router.post("/user") { request, response, next in
    guard let name = try request.readString() else {
        try response.send("No parameter!").end()
        Log.error("No parameter!")
        return
    }
    
    kassandra.execute("INSERT INTO users (name, id) VALUES ('\(name)', uuid())") { result in
        if case let Result.error(err) = result {
            Log.error("Request error: \(err)")
            return
        }
        
        Log.verbose("User added: '\(name)'")
        try! response.send("User added: '\(name)'").end()
    }
}

Kitura.addHTTPServer(onPort: 8090, with: router)
Kitura.run()






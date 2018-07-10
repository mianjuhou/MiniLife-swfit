//
//  User.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/3.
//  Copyright © 2018年 房德安. All rights reserved.
//

import Foundation

struct User: Codable {
    var id:Int64!
    var name:String!
    var email:String!
    var password:String!
    var loginState:Int16!
    var machineNum:String!
    var updateTime:Int64!
}

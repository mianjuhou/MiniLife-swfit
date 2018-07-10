//
//  Goods.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/5.
//  Copyright © 2018年 房德安. All rights reserved.
//

import Foundation

struct Goods: Codable {
    var id:Int64!
    var categoryId:Int64!
    var userId:Int64!
    var name:String!
    var state:Int16!
    var orderNum:Int32!
    var updateTime:Int64!
}

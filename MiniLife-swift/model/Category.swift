//
//  Category.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/5.
//  Copyright © 2018年 房德安. All rights reserved.
//

import Foundation

struct Category: Codable {
    var id:Int64!
    var parentId:Int64!
    var userId:Int64!
    var name:String!
    var orderNum:Int32!
    var updateTime:Int64!
    var cellHeight:Float! = 100
}

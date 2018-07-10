//
//  ResponseListBean.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/6.
//  Copyright © 2018年 房德安. All rights reserved.
//

import Foundation

struct ResponseListBean<K>: Codable where K: Codable {
    var content:[K]!
    var totalNum:Int64
    var totalPage:Int64
    var pageSize:Int64
}

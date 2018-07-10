//
//  ResponseBean.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/4.
//  Copyright © 2018年 房德安. All rights reserved.
//

import Foundation

struct ResponseBean<T>: Codable where T: Codable {
    var content: T!
    var code: Int
    var msg: String
}

//
//  GoodsController.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/5.
//  Copyright © 2018年 房德安. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import TangramKit

class GoodsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var data:[Category] = []
    
    public var parentId: Int64!
    var userId: Int64!
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let dt:Category = data[indexPath.row]
        return CGFloat(dt.cellHeight!)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "goodsCell", for: indexPath) as! GoodsTableCell
        var category = data[indexPath.row]
        cell.catName!.text = category.name + ":"
        let goodsList = loadGoodsData(category.id!)
        var str: String = ""
        for goods in goodsList {
            str = str + "  " + goods.name!
        }
        cell.goodsName.font = UIFont.systemFont(ofSize: 14)
        cell.goodsName.text = str
        let strSize: CGSize =  str.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.0)])
        
        cell.flowLayout.tg_orientation = .vert
        cell.flowLayout.tg_height.equal(.wrap)
        cell.flowLayout.tg_width.equal(.fill)
        cell.flowLayout.backgroundColor = UIColor.red
        cell.flowLayout.autoresizesSubviews = true
        for goods in goodsList {
            let name: String = goods.name!
            let label = UILabel()
            label.text = name
            label.font = UIFont.systemFont(ofSize: 13)
            label.textColor = UIColor.black
            let size: CGSize = name.size(withAttributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13.0)])
            label.frame = CGRect(x: 0, y: 0, width: size.width+5, height: size.height)
            cell.flowLayout.addSubview(label)
        }
        
        let fit = cell.flowLayout.tg_sizeThatFits()
        print("width:\(fit.width) height:\(fit.height)")
        category.cellHeight = Float(strSize.height+fit.height+CGFloat(20.0))
        return cell
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = AppDelegate.user?.id
        self.tableView.dataSource = self
        self.tableView.delegate = self
//        self.tableView.rowHeight = CGFloat(100)
//        self.tableView.estimatedRowHeight = 100
//        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadDBData()
    }
    
    func loadDBData() -> Void {
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //构建查询条件
        let fetchRequest = NSFetchRequest<TCategory>(entityName: "TCategory")
        let predicate = NSPredicate(format: "parentId = %@ and userId = %@", NSNumber(value: parentId!),NSNumber(value: userId!))
        fetchRequest.predicate = predicate
        do {
            //执行查询
            let fetchedObjects:[TCategory] = try context.fetch(fetchRequest)
            //操作查询结果
            data.removeAll()
            for obj in fetchedObjects {
                var cat = Category()
                cat.id = obj.id
                cat.name = obj.name
                cat.orderNum = obj.orderNum
                cat.parentId = obj.parentId
                cat.updateTime = obj.updateTime
                cat.userId = obj.userId
                data.append(cat)
            }
            tableView.reloadData()
        } catch {
            print("查询失败")
        }
    }
    
    func loadGoodsData(_ categoryId:Int64) -> [TGoods] {
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //构建查询条件
        let fetchRequest = NSFetchRequest<TGoods>(entityName: "TGoods")
        let predicate = NSPredicate(format: "categoryId = %@ and userId = %@", NSNumber(value: categoryId),NSNumber(value: userId!))
        fetchRequest.predicate = predicate
        do {
            //执行查询
            let fetchedObjects:[TGoods] = try context.fetch(fetchRequest)
            return fetchedObjects
        } catch {
            print("查询失败")
        }
        return []
    }
    
    @IBAction func clickBack(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

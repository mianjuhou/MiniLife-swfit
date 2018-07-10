//
//  MainController.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/5.
//  Copyright © 2018年 房德安. All rights reserved.
//

import UIKit
import CoreData
import Moya
import Alamofire
import Foundation

class MainController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var data:[Category] = []
    
    var parentClickId: Int64!
    
    var context: NSManagedObjectContext!
    
    var userId: Int64!
    
    //获取数据数量
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    //获取条目View
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryTableCell
        let category = data[indexPath.row]
        cell.name!.text = category.name!
        return cell
    }
    //条目点击事件回调
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        parentClickId = data[indexPath.row].id
        self.performSegue(withIdentifier: "to_goods", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! GoodsController
        controller.parentId = parentClickId
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        context = app.persistentContainer.viewContext
        userId = AppDelegate.user?.id
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadDataFromDB()
    }
    
    @IBAction func clickDownload(_ sender: UIButton) {
        downCategoryData()
        downGoodsData()
    }
    //从网络获取分类数据
    func downCategoryData() -> Void {
        //从网络获取
        let parameters: Parameters = [
            "userId":String(describing: userId!)
        ]
        Alamofire
            .request("http://\(AppDelegate.ip):8888/goods/category/download2", method: .post , parameters: parameters)
            .responseString(completionHandler: {(dataResponse: DataResponse<String>) in
                switch dataResponse.result {
                case .success(let value) :
                    guard let jsonData = value.data(using: .utf8) else {
                        print("JOSN字符串转JSON对象失败")
                        return
                    }
                    guard let obj = try? JSONDecoder().decode(ResponseBean<ResponseListBean<Category>>.self, from: jsonData) else {
                        print("JSON对象转Model失败")
                        return
                    }
                    if obj.code == 1 {
                        print("获取分类成功")
                        for category in obj.content.content {
                            //插入或更新
                            self.getCategory(category)
                        }
                        self.loadDataFromDB()
                    } else {
                        print("获取分类失败")
                    }
                    break
                case .failure(let error) :
                    print("网络错误: \(error.localizedDescription)")
                    break
                }
            })
    }
    
    //从网络获取物品数据
    func downGoodsData() -> Void {
        //从网络获取
        let parameters: Parameters = [
            "userId":String(describing: userId!)
        ]
        Alamofire
            .request("http://\(AppDelegate.ip):8888/goods/goods/download2", method: .post , parameters: parameters)
            .responseString(completionHandler: {(dataResponse: DataResponse<String>) in
                switch dataResponse.result {
                case .success(let value) :
                    guard let jsonData = value.data(using: .utf8) else {
                        print("JOSN字符串转JSON对象失败")
                        return
                    }
                    guard let obj = try? JSONDecoder().decode(ResponseBean<ResponseListBean<Goods>>.self, from: jsonData) else {
                        print("JSON对象转Model失败")
                        return
                    }
                    if obj.code == 1 {
                        print("获取分类成功")
                        for goods in obj.content.content {
                            self.getGoods(goods)
                        }
                        self.loadDataFromDB()
                    } else {
                        print("获取分类失败")
                    }
                    break
                case .failure(let error) :
                    print("网络错误: \(error.localizedDescription)")
                    break
                }
            })
    }
    
    //从数据库加载数据
    func loadDataFromDB() -> Void {
        //从数据库获取分类信息
        //构建查询条件
        let fetchRequest = NSFetchRequest<TCategory>(entityName: "TCategory")
        let predicate = NSPredicate(format: "parentId = 0 and userId = %@", NSNumber(value: userId!))
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
//    //插入分类到数据库
//    func insertCategory(_ category: Category) -> Void {
//        //创建插入对象
//        let tcategory = NSEntityDescription.insertNewObject(forEntityName: "TCategory", into: context) as! TCategory
//        tcategory.id = category.id
//        tcategory.name = category.name
//        tcategory.orderNum = category.orderNum
//        tcategory.parentId = category.parentId
//        tcategory.updateTime = category.updateTime
//        tcategory.userId = category.userId
//        do {
//            //保存操作
//            try context.save()
//            print("保存成功")
//        } catch {
//            print("保存失败")
//        }
//    }
//    //插入物品到数据库
//    func insertGoods(_ goods: Goods) -> Void {
//        //创建插入对象
//        let tgoods = NSEntityDescription.insertNewObject(forEntityName: "TGoods", into: context) as! TGoods
//        tgoods.id = goods.id
//        tgoods.name = goods.name
//        tgoods.orderNum = goods.orderNum
//        tgoods.categoryId = goods.categoryId
//        tgoods.updateTime = goods.updateTime
//        tgoods.userId = goods.userId
//        tgoods.state = goods.state
//        do {
//            //保存操作
//            try context.save()
//            print("保存成功")
//        } catch {
//            print("保存失败")
//        }
//    }
    
    func getCategory(_ cat: Category) -> Void {
        //构建查询条件
        let fetchRequest = NSFetchRequest<TCategory>(entityName: "TCategory")
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        let predicate = NSPredicate(format: "id = %@ and userId = %@", NSNumber(value: cat.id!), NSNumber(value: userId!))
        fetchRequest.predicate = predicate
        do {
            //执行查询
            let fetchedObjects:[TCategory] = try context.fetch(fetchRequest)
            if fetchedObjects.count > 0 {
                let tcat = fetchedObjects[0]
                if tcat.updateTime < cat.updateTime {
                    tcat.name = cat.name
                    tcat.orderNum = cat.orderNum
                    tcat.updateTime = cat.updateTime
                    try context.save()
                }
            } else {
                let tcategory = NSEntityDescription.insertNewObject(forEntityName: "TCategory", into: context) as! TCategory
                tcategory.id = cat.id
                tcategory.name = cat.name
                tcategory.orderNum = cat.orderNum
                tcategory.parentId = cat.parentId
                tcategory.updateTime = cat.updateTime
                tcategory.userId = cat.userId
                try context.save()
            }
        } catch {
            print("查询失败")
        }
    }
    
    func getGoods(_ goods: Goods) -> Void {
        //构建查询条件
        let fetchRequest = NSFetchRequest<TGoods>(entityName: "TGoods")
        fetchRequest.fetchLimit=1
        fetchRequest.fetchOffset=0
        let predicate = NSPredicate(format: "id = %@ and userId = %@", NSNumber(value: goods.id!), NSNumber(value: userId!))
        fetchRequest.predicate = predicate
        do {
            //执行查询
            let fetchedObjects:[TGoods] = try context.fetch(fetchRequest)
            if fetchedObjects.count > 0 {
                let gd = fetchedObjects[0]
                if gd.updateTime < goods.updateTime {
                    gd.name = goods.name
                    gd.orderNum = goods.orderNum
                    gd.state = goods.state
                    gd.updateTime = goods.updateTime
                    try context.save()
                }
            } else {
                let tgoods = NSEntityDescription.insertNewObject(forEntityName: "TGoods", into: context) as! TGoods
                tgoods.id = goods.id
                tgoods.name = goods.name
                tgoods.orderNum = goods.orderNum
                tgoods.categoryId = goods.categoryId
                tgoods.updateTime = goods.updateTime
                tgoods.userId = goods.userId
                tgoods.state = goods.state
                try context.save()
            }
        } catch {
            print("查询失败")
        }
    }
    
    //上传数据
    @IBAction func clickUpload(_ sender: UIButton) {
    }
    
}

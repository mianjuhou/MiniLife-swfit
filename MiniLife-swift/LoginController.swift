//
//  LoginController.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/3.
//  Copyright © 2018年 房德安. All rights reserved.
//

import UIKit
import Foundation
import Moya
import Alamofire
import CoreData

class LoginController: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    @IBAction func clickLogin(_ sender: UIButton) {
        let email = txtEmail.text
        let password = txtPassword.text
        
        let parameters: Parameters = [
            "email":email!,
            "password":password!
        ]
        
        Alamofire
            .request("http://\(AppDelegate.ip):8888/user/user/login", method: .post , parameters: parameters)
            .responseString(completionHandler: {(response : DataResponse<String>) in
                switch response.result {
                case .success(let value):
                    guard let jsonData = value.data(using: .utf8) else {
                        print("JOSN字符串转JSON对象失败")
                        return
                    }
                    guard let obj = try? JSONDecoder().decode(ResponseBean<User>.self, from: jsonData) else {
                        print("JSON对象转Model失败")
                        return
                    }
                    if obj.code == 1 {
                        print("\(obj.content.name!)登录成功")
                        self.save(user: obj.content,sender)
                        
                    }else{
                        print("登录失败:\(obj.msg)")
                    }
                    break
                case .failure(let error):
                    print("网络错误: \(error.localizedDescription)")
                    break
                }
            })
    }
    
    @IBAction func clickForgetPw(_ sender: UIButton) {
        
    }
    
    func save(user: User,_ sender: UIButton) -> Void {
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //创建TUser对象
        let tuser = NSEntityDescription.insertNewObject(forEntityName: "TUser", into: context) as! TUser
        tuser.id = user.id
        tuser.name = user.name
        tuser.password = user.password
        tuser.email = user.email
        tuser.loginState = 1
        tuser.machineNum = user.machineNum
        tuser.updateTime = user.updateTime
        do {
            //保存操作
            try context.save()
            AppDelegate.user = tuser
            print("保存成功")
            self.performSegue(withIdentifier: "login_to_main", sender: sender.self)
        } catch {
            print("保存失败")
        }
    }
    
    func query() -> Void {
        //请求参数
        let email = "fangdean@yeah.net"
        let password = "123456"
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //查询条件
        let fetchRequest = NSFetchRequest<TUser>(entityName: "TUser")
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = 0
        let predicate = NSPredicate(format: "email = %@ and password = %@ and loginState = 1", email,password)
        fetchRequest.predicate = predicate
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            if fetchedObjects.count > 0 {
                let obj = fetchedObjects[0]
                print("用户已登录")
                print("name:\(obj.name!),\(obj.updateTime)")
            } else {
                print("用户未登录")
            }
        } catch {
            print("查询失败")
        }
    }
    
    func update() -> Void {
        let email = "fangdean@yeah.net"
        let password = "123456"
        print("start ....")
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //查询条件
        let fetchRequest = NSFetchRequest<TUser>(entityName: "TUser")
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = 0
        let predicate = NSPredicate(format: "email = %@ and password = %@ and loginState = 1", email,password)
        fetchRequest.predicate = predicate
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            if fetchedObjects.count > 0 {
                let obj = fetchedObjects[0]
                obj.updateTime = 11111
                try context.save()
            } else {
                print("用户未登录")
            }
        } catch {
            print("查询失败")
        }
    }
    
    func delete() -> Void {
        let email = "fangdean@yeah.net"
        let password = "123456"
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //查询条件
        let fetchRequest = NSFetchRequest<TUser>(entityName: "TUser")
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = 0
        let predicate = NSPredicate(format: "email = %@ and password = %@ and loginState = 1", email,password)
        fetchRequest.predicate = predicate
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            if fetchedObjects.count > 0 {
                let obj = fetchedObjects[0]
                context.delete(obj)
                try context.save()
            } else {
                print("用户未登录")
            }
        } catch {
            print("查询失败")
        }
    }
    
}

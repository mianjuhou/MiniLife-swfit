//
//  ViewController.swift
//  MiniLife-swift
//
//  Created by 房德安 on 2018/7/3.
//  Copyright © 2018年 房德安. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        queryLoginInfo(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func goLogin(_ sender: UIButton) {
        queryLoginInfo(sender)
    }
    
    func queryLoginInfo(_ sender: Any) -> Void {
        //获取管理的数据上下文对象
        let app = UIApplication.shared.delegate as! AppDelegate
        let context = app.persistentContainer.viewContext
        //查询条件
        let fetchRequest = NSFetchRequest<TUser>(entityName: "TUser")
        fetchRequest.fetchLimit = 1
        fetchRequest.fetchOffset = 0
        let predicate = NSPredicate(format: "loginState = 1", "")
        fetchRequest.predicate = predicate
        do {
            let fetchedObjects = try context.fetch(fetchRequest)
            if fetchedObjects.count > 0 {
                let obj = fetchedObjects[0]
                AppDelegate.user = obj
                print("用户已登录")
                self.performSegue(withIdentifier: "go_main", sender: sender.self)
            } else {
                print("用户未登录")
                self.performSegue(withIdentifier: "go_login", sender: sender.self)
            }
        } catch {
            print("查询失败")
        }
    }
    
}


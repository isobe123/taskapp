//
//  ViewController.swift
//  taskapp
//
//  Created by be on 2019/06/15.
//  Copyright © 2019年 isobe. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIBarButtonItem!
    private var mySearchBar: UISearchBar!
   
    let realm = try! Realm()
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //検索バーの設置
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            //NavigationBarに適したサイズの検索バーを設置
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            //デリゲート
            searchBar.delegate = self
            //プレースホルダー
            searchBar.placeholder = "カテゴリを検索"
            //検索バーのスタイル
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            //NavigationTitleが置かれる場所に検索バーを設置
            navigationItem.titleView = searchBar
            //NavigationTitleのサイズを検索バーと同じにする
            navigationItem.titleView?.frame = searchBar.frame
        }
    }
    
    @IBAction func searchButton(_ sender: Any) {
        setSearchBar()
    }
    
    //検索バーで入力する時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    //キャンセルボタンを表示
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
        
    //検索バーのキャンセルがタップされた時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        //キーボードを閉じる
        searchBar.resignFirstResponder()
        searchBar.isHidden = true
        taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }
    
    //検索バーでEnterが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.enablesReturnKeyAutomatically = false
        taskArray = realm.objects(Task.self).filter("category == %@", searchBar.text!).sorted(byKeyPath: "date", ascending: false)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)->Int{
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = dateString
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView:UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath:IndexPath) {
        if editingStyle == .delete{
            let task = self.taskArray[indexPath.row]
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            try! realm.write {
                self.realm.delete(task)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            center.getPendingNotificationRequests{ (requests:[UNNotificationRequest])in
                for request in requests{
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let inputViewController:InputViewController = segue.destination as! InputViewController
        
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = Date()
            
            let allTasks = realm.objects(Task.self)
            if allTasks.count != 0{
                task.id = allTasks.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}


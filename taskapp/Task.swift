//
//  Task.swift
//  taskapp
//
//  Created by be on 2019/06/16.
//  Copyright © 2019年 isobe. All rights reserved.
//

import RealmSwift

class Task: Object {
    @objc dynamic var id = 0
    @objc dynamic var title = ""
    @objc dynamic var contents = ""
    @objc dynamic var date = Date()
    @objc dynamic var category = ""
    override static func primaryKey() -> String?{
        return "id"
    }
}

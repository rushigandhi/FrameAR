//
//  Commit.swift
//  app
//
//  Created by Rushi Gandhi on 2019-06-22.
//  Copyright © 2019 Rushi Gandhi. All rights reserved.
//

import Foundation

class Commit: Codable {
    var id: String
    var message: String
    var tags: [Tag]
    var parentId: String?
    var branchingName: String?
    
    init(id: String, message: String, tags: [Tag], parentId: String?, branchingName: String){
        self.id = id
        self.message = message
        self.tags = tags
        self.parentId = parentId
        self.branchingName = branchingName
    }
}

//
//  DataManager.swift
//  app
//
//  Created by Rushi Gandhi on 2019-06-22.
//  Copyright © 2019 Rushi Gandhi. All rights reserved.
//

import Foundation

class Prelaunch {
    
    let projectId: String
    let commitId: String
    let file: String
    
    init(projectId: String, commitId: String, file: String) {
        self.projectId = projectId
        self.commitId = commitId
        self.file = file
    }
    
}

class DataManager {
    
    // MARK: - Properties
    
    static let shared = DataManager(projects: [])
    
    static var prelaunch: Prelaunch? = nil
    
    // MARK: -
    
    var projects: [Project]
    
    // Initialization
    
    private init(projects: [Project]) {
        self.projects = projects
    }
    
}

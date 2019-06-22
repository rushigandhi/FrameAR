//
//  DataManager.swift
//  app
//
//  Created by Rushi Gandhi on 2019-06-22.
//  Copyright © 2019 Rushi Gandhi. All rights reserved.
//

import Foundation

class DataManager {
    
    // MARK: - Properties
    
    static let shared = DataManager(projects: [])
    
    // MARK: -
    
    var projects: [Project]
    
    // Initialization
    
    private init(projects: [Project]) {
        self.projects = projects
    }
    
}

//
//  CommitCalculator.swift
//  app
//
//  Created by Rushi Gandhi on 2019-06-22.
//  Copyright © 2019 Rushi Gandhi. All rights reserved.
//

import Foundation

class CommitCalculator {
    
    static func getBranches(project: Project) -> [String] {
        var res = [String]()
        
        for commit in project.commits {
            if let branch = commit.branchingName {
                res.append(branch)
            }
        }
        
        return res
    }
    
    static func getCommitsOfBranch(project: Project, branch: String) -> [Commit] {
        var res = [Commit]()
        
        var topCommit: Commit? = nil
        for commit in project.commits {
            if commit.branchingName == branch {
                topCommit = commit
                break
            }
        }
        
        if topCommit == nil { return res }
                
        res.append(topCommit!)
        
        // find one where the parent commit is top commit
        while true {
            var breaking = true
            for commit in project.commits {
                if commit.parentId == topCommit?.id && commit.branchingName == nil {
                    res.append(commit)
                    topCommit = commit
                    breaking = false
                    break
                }
            }
    
            if(breaking) {
                break
            }
        }
        
        return res
    }
}

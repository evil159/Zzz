//
//  RepositoryStorage.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/14/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class RepositoryStorage {
    
    enum RepoStorageError: ErrorType {
        case AlreadyExists
    }
    
    private static let repositoriesKey = "com.rol.zzz.RepositoriesKey"
    
    static func repositories() -> [Repository] {
        
        let paths = savedRepositoriesPaths()
        var result = [Repository]()
        
        for path in paths {
            
            do {
                let repo = try repository(from: path)
                
                result.append(repo);
            } catch {
                continue
            }
        }
        
        return result
    }

    static func addRepository(path: String) throws -> [Repository] {
     
        try validatePath(path)
        
        let repo = try repository(from: path)
        var repos = repositories()
        
        saveRepositoryPath(path)
        
        repos.append(repo)
        
        return repos
    }

    private static func repository(from path: String) throws -> Repository {
        
        return try Repository(existingLocalRepository: path)
    }
    
    private static func savedRepositoriesPaths() -> [String] {
        
        guard let paths = NSUserDefaults.standardUserDefaults().arrayForKey(repositoriesKey) as? [String] else {
            return []
        }

        return paths;
    }
    
    private static func validatePath(path: String) throws {
        
        for repoPath in savedRepositoriesPaths() {

            if repoPath == path {
                throw RepoStorageError.AlreadyExists
            }
        }
    }
    
    private static func saveRepositoryPath(path: String) {
        
        var paths = savedRepositoriesPaths()
        
        paths.append(path)
        
        NSUserDefaults.standardUserDefaults().setObject(paths, forKey: repositoriesKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
}
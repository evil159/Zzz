//
//  RepositoryStorage.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/14/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class RepositoryStorage {
    
    enum RepoStorageError: Error {
        case alreadyExists
    }
    
    fileprivate static let repositoriesKey = "com.rol.zzz.RepositoriesKey1"
    
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

    static func addRepository(_ path: String) throws -> [Repository] {
     
        try validatePath(path)
        
        let repo = try repository(from: path)
        var repos = repositories()
        
        saveRepositoryPath(path)
        
        repos.append(repo)
        
        return repos
    }

    fileprivate static func repository(from path: String) throws -> Repository {

        
        return try Repository(existingLocalRepository: path)
    }
    
    fileprivate static func savedRepositoriesPaths() -> [String] {
        
        guard let paths = UserDefaults.standard.array(forKey: repositoriesKey) as? [String] else {
            return []
        }

        return paths;
    }
    
    fileprivate static func validatePath(_ path: String) throws {
        
        for repoPath in savedRepositoriesPaths() {

            if repoPath == path {
                throw RepoStorageError.alreadyExists
            }
        }
    }
    
    fileprivate static func saveRepositoryPath(_ path: String) {
        
        var paths = savedRepositoriesPaths()
        
        paths.append(path)
        
        UserDefaults.standard.set(paths, forKey: repositoriesKey)
        UserDefaults.standard.synchronize()
    }
}

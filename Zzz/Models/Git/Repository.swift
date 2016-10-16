//
//  Repository.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/15/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class Repository: GCLiveRepository {
    
    var name: String {
        let components = repositoryPath.componentsSeparatedByString("/")
        return components.count > 1 ? components[components.count - 2] : repositoryPath
    }
    
    override class func historySorting() -> GCHistorySorting {
        return .ReverseChronological
    }
}
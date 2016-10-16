//
//  RepositoriesViewController.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/4/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

protocol RepositoriesViewControllerDelegate {
    func repositoriesViewController(_ repoViewController: RepositoriesViewController, didSelectRepo repo: GCLiveRepository)
}

class RepositoriesViewController: NSViewController {
    
    @IBOutlet var outlineView: NSOutlineView?
    
    var delegate: RepositoriesViewControllerDelegate?
    var repos: [Repository] = [] {
        didSet {
            reloadData(repos)
        }
    }
    fileprivate let repositoryGroup = RepositoryGroup()
    
    func reloadData(_ repos: [Repository]) {
        
        repositoryGroup.childred = repos
        
        outlineView?.reloadData()
        outlineView?.expandItem(nil, expandChildren: true)
    }
}

private class RepositoryGroup {
    var childred = [Repository]()
}

// MARK: NSOutlineViewDataSource
extension RepositoriesViewController: NSOutlineViewDataSource {
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let group = item as? RepositoryGroup {
            return group.childred.count
        }
        
        return 1
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if let group = item as? RepositoryGroup {
            return group.childred[index]
        }
        
        return repositoryGroup
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if let group = item as? RepositoryGroup {
            return group.childred.count > 0
        }
        
        return false
    }
}

// MARK: NSOutlineViewDelegate
extension RepositoriesViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is RepositoryGroup;
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        guard let cell = outlineView.make(withIdentifier: "RepoCell", owner: nil) as? NSTableCellView else {
            return nil
        }
        
        if let repo = item as? Repository {
            cell.textField?.stringValue = repo.name
        }
        
        if item is RepositoryGroup {
            cell.textField?.stringValue = "REPOSITORIES"
        }
        
        return cell
    }
    
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        guard let repo = item as? GCLiveRepository else {
            return false
        }
        
        delegate?.repositoriesViewController(self, didSelectRepo: repo)
        
        return true
    }
}

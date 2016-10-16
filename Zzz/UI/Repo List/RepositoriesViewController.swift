//
//  RepositoriesViewController.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/4/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

protocol RepositoriesViewControllerDelegate {
    func repositoriesViewController(repoViewController: RepositoriesViewController, didSelectRepo repo: GCLiveRepository)
}

class RepositoriesViewController: NSViewController {
    
    @IBOutlet var outlineView: NSOutlineView?
    
    var delegate: RepositoriesViewControllerDelegate?
    var repos: [Repository] = [] {
        didSet {
            reloadData(repos)
        }
    }
    private let repositoryGroup = RepositoryGroup()
    
    func reloadData(repos: [Repository]) {
        
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
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        if let group = item as? RepositoryGroup {
            return group.childred.count
        }
        
        return 1
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let group = item as? RepositoryGroup {
            return group.childred[index]
        }
        
        return repositoryGroup
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        if let group = item as? RepositoryGroup {
            return group.childred.count > 0
        }
        
        return false
    }
}

// MARK: NSOutlineViewDelegate
extension RepositoriesViewController: NSOutlineViewDelegate {
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return item is RepositoryGroup;
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
        guard let cell = outlineView.makeViewWithIdentifier("RepoCell", owner: nil) as? NSTableCellView else {
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
    
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        
        guard let repo = item as? GCLiveRepository else {
            return false
        }
        
        delegate?.repositoriesViewController(self, didSelectRepo: repo)
        
        return true
    }
}
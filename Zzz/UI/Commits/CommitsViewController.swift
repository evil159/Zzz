//
//  CommitsViewController.swift
//  Zzz
//
//  Created by Roman Laitarenko on 6/29/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Cocoa
import AppKit

protocol CommitsViewControllerDelegate {
    func commitsViewController(_ commitsViewController: CommitsViewController,
                               didSelectCommit commit: GCHistoryCommit,
                                               diff: GCDiff)
    func commitsViewController(_ commitsViewController: CommitsViewController,
                               didSelectStaging repo: GCLiveRepository)
}

class CommitsViewController: NSViewController {
    
    var delegate: CommitsViewControllerDelegate?
    
    var repo: GCLiveRepository? {
        didSet (oldRepo) {
            
            oldRepo?.statusMode = .disabled
            repo?.statusMode = .unified

            reloadRepository(repo)
        }
    }
    fileprivate var history: GCHistory?
    
    @IBOutlet var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadRepository(repo)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        repo?.statusMode = .unified
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        repo?.statusMode = .disabled;
    }
}

// MARK: Private
private extension CommitsViewController {
    
    static let cellHeight = CGFloat(46.0)
    
    func reloadRepository(_ repo: GCLiveRepository?) {
        
        defer {
            tableView.reloadData()
        }
        
        guard let repo = repo else {
            return
        }
        
        repo.delegate = self
        
        do {
            history = try repo.loadHistory(using: .reverseChronological)
        } catch {
            presentAlert(withType: .stop,
                         title: "Failed to load the latest history",
                         message: "Backing up to last known history")
            history = repo.history
        }
    }
}

extension CommitsViewController: GCLiveRepositoryDelegate {
    
    func repositoryDidChange(_ repository: GCRepository!) {
        print("repo did change")
    }
    
    func repositoryDidUpdateState(_ repository: GCLiveRepository!) {
        print("repo update state")
    }
    
    func repositoryDidUpdateStatus(_ repository: GCLiveRepository!) {
        print("repo update status")
    }
    
    func repositoryDidUpdateHistory(_ repository: GCLiveRepository!) {
        
        reloadRepository(repo)
        print("repo update history")
    }
    
    func repositoryWorkingDirectoryDidChange(_ repository: GCRepository!) {

        print("repo working dir changed")
        
        tableView.reloadData(forRowIndexes: IndexSet(integer: 0), columnIndexes: IndexSet(integer: 0))
    }
}

// MARK: NSTableViewDataSource
extension CommitsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        guard let count = history?.allCommits.count else {
            return 0
        }
        
        return count + 1
    }
}

// MARK: NSTableViewDelegate
extension CommitsViewController: NSTabViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellIdentifier = (row == 0) ? "indexCell" : String(describing: CommitCell.self)
        let cell = tableView.make(withIdentifier: cellIdentifier, owner: nil)
        
        if let cell = cell as? CommitCell,
            let commit = history?.allCommits[row - 1] as? GCHistoryCommit {
            
            cell.fillWithCommit(commit)
        }
        
        if row == 0,
            let cell = cell as? NSTableCellView,
            let deltas = repo?.unifiedStatus.deltas {
            
            cell.textField?.stringValue = deltas.count > 0 ?
                "\(deltas.count) changes" : "No changes in working directory";
        }

        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        guard let history = history, let repo = repo else {
            return false
        }
        
        if row == 0 {
            
            delegate?.commitsViewController(self, didSelectStaging: repo)
            return true
        }
        
        let commit = history.allCommits[row - 1] as! GCHistoryCommit

        var diff: GCDiff
        
        do {
            diff = try repo.diffCommit(commit,
                                        with:commit.parents.first as? GCCommit,
                                        filePattern: nil,
                                        options: .findRenames,
                                        maxInterHunkLines: 0,
                                        maxContextLines: 0)
        } catch {
            return false
        }
        
        delegate?.commitsViewController(self, didSelectCommit: commit, diff: diff)
        
        return true
    }
}

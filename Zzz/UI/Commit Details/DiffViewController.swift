//
//  CommitDetailsViewController.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/7/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

protocol DiffViewControllerDelegate {
    func diffViewControllerRequestsCommit(diffViewController: DiffViewController, message: String);
}

class DiffViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var emptyTextLabel: NSTextField!
    
    var delegate: DiffViewControllerDelegate?
    var messageCell: CommitMessageCell?
    
    private var deltas: [GCDiffDelta] = []
    private var commit: GCHistoryCommit?
    private var stagingRepo: GCLiveRepository?
    private var inStagingMode: Bool {
        return (stagingRepo != nil)
    }
    private var hasCommit: Bool {
        return (commit != nil)
    }
    
    func load(commit: GCHistoryCommit?, diff: GCDiff?) {
        
        deltas = diff?.deltas as? [GCDiffDelta] ?? []
        self.commit = commit
        emptyTextLabel.hidden = !deltas.isEmpty
        stagingRepo = nil
        
        tableView.reloadData()
    }
    
    func showStaging(repo: GCLiveRepository) {
        stagingRepo = repo
        deltas = repo.unifiedStatus.deltas as? [GCDiffDelta] ?? []
        
        tableView.reloadData()
    }
}

// MARK: Actions
extension DiffViewController {
    
    @IBAction func stageCheckboxPressed(sender: NSButton) {
        
        let row = sender.tag;
        let delta = deltas[row]
        let repo = delta.diff.repository as? GCLiveRepository
        let fileExists = NSFileManager.defaultManager().fileExistsAtPath(delta.canonicalPath)

        do {
            if fileExists {
                
                try repo?.addFileToIndex(delta.canonicalPath)
            } else {
                try repo?.resetFileInIndexToHEAD(delta.canonicalPath)
            }
            
            sender.state = fileExists ? NSOnState : NSOffState
            repo?.notifyRepositoryChanged()
        } catch {
            NSApp.presentError(error as NSError)
        }
    }
    
    @IBAction func commitButtonPressed(sender: NSButton) {
        
        guard let message = messageCell?.messageTextView.string where message.characters.count > 0 else {
            return
        }
        
        delegate?.diffViewControllerRequestsCommit(self, message: message)
    }
}

// MARK: NSTableViewDataSource
extension DiffViewController: NSTableViewDataSource {
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        
        if let repo = stagingRepo { // staging mode
            return repo.unifiedStatus.deltas.count
        }
        
        return hasCommit ? deltas.count + 1 : 0 // +1 is for the header in commit details mode
    }
}

// MARK: NSTableViewDelegate
extension DiffViewController: NSTableViewDelegate {
    
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var identifier = (row == 0) ? String(CommitMessageCell) : String(StagingDiffDeltaCell)
        
        if !inStagingMode {
            identifier = (row == 0) ? String(DiffHeaderCell) : String(DiffDeltaCell)
        }
        
        let cell = tableView.makeViewWithIdentifier(identifier, owner: nil)
        
        switch cell {
        case let cell as DiffHeaderCell:
            cell.commit = commit
        case let cell as StagingDiffDeltaCell:
            cell.fill(with: deltas[row - 1])
            cell.stageCheckbox.tag = row
        case let cell as DiffDeltaCell:
            cell.fill(with: deltas[row - 1])
        case let cell as CommitMessageCell:
            messageCell = cell
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return row == 0 ? 94.0 : 17.0
    }
    
    func tableView(tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row != 0
    }
}

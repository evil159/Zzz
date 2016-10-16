//
//  CommitDetailsViewController.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/7/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

protocol DiffViewControllerDelegate {
    func diffViewControllerRequestsCommit(_ diffViewController: DiffViewController, message: String);
}

class DiffViewController: NSViewController {
    
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var emptyTextLabel: NSTextField!
    
    var delegate: DiffViewControllerDelegate?
    var messageCell: CommitMessageCell?
    
    fileprivate var deltas: [GCDiffDelta] = []
    fileprivate var commit: GCHistoryCommit?
    fileprivate var stagingRepo: GCLiveRepository?
    fileprivate var inStagingMode: Bool {
        return (stagingRepo != nil)
    }
    fileprivate var hasCommit: Bool {
        return (commit != nil)
    }
    
    func load(_ commit: GCHistoryCommit?, diff: GCDiff?) {
        
        deltas = diff?.deltas as? [GCDiffDelta] ?? []
        self.commit = commit
        emptyTextLabel.isHidden = !deltas.isEmpty
        stagingRepo = nil
        
        tableView.reloadData()
    }
    
    func showStaging(_ repo: GCLiveRepository) {
        stagingRepo = repo
        deltas = repo.unifiedStatus.deltas as? [GCDiffDelta] ?? []
        
        tableView.reloadData()
    }
}

// MARK: Actions
extension DiffViewController {
    
    @IBAction func stageCheckboxPressed(_ sender: NSButton) {
        
        let row = sender.tag;
        let delta = deltas[row]
        let repo = delta.diff.repository as? GCLiveRepository
        let fileExists = FileManager.default.fileExists(atPath: delta.canonicalPath)

        do {
            if fileExists {
                
                try repo?.addFile(toIndex: delta.canonicalPath)
            } else {
                try repo?.resetFileInIndex(toHEAD: delta.canonicalPath)
            }
            
            sender.state = fileExists ? NSOnState : NSOffState
            repo?.notifyChanged()
        } catch {
            NSApp.presentError(error as NSError)
        }
    }
    
    @IBAction func commitButtonPressed(_ sender: NSButton) {
        
        guard let message = messageCell?.messageTextView.string , message.characters.count > 0 else {
            return
        }
        
        delegate?.diffViewControllerRequestsCommit(self, message: message)
    }
}

// MARK: NSTableViewDataSource
extension DiffViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        if let repo = stagingRepo { // staging mode
            return repo.unifiedStatus.deltas.count
        }
        
        return hasCommit ? deltas.count + 1 : 0 // +1 is for the header in commit details mode
    }
}

// MARK: NSTableViewDelegate
extension DiffViewController: NSTableViewDelegate {
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var identifier = (row == 0) ? String(describing: CommitMessageCell.self) : String(describing: StagingDiffDeltaCell.self)
        
        if !inStagingMode {
            identifier = (row == 0) ? String(describing: DiffHeaderCell.self) : String(describing: DiffDeltaCell.self)
        }
        
        let cell = tableView.make(withIdentifier: identifier, owner: nil)
        
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
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return row == 0 ? 94.0 : 17.0
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return row != 0
    }
}

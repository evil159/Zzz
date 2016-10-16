//
//  WindowController.swift
//  Zzz
//
//  Created by Roman Laitarenko on 8/4/16.
//  Copyright © 2016 Roman Laitarenko. All rights reserved.
//

import Foundation

class WindowController: NSWindowController {
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        setup()
    }
}

// MARK: Actions
extension WindowController {
    
    @IBAction func addButtonPressed(button: NSView) {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.resolvesAliases = true
        panel.worksWhenModal = true
        panel.beginSheetModalForWindow(window!, completionHandler:{ resultCode in
            
            guard resultCode == NSFileHandlingPanelOKButton else {
                return
            }
            
            guard let url = panel.URLs.first else {
                return
            }
            
            self.repositoryUrlSelected(url)
        })
    }
}

// MARK: Private
private extension WindowController {
    
    var splitVC: NSSplitViewController? {
        return contentViewController as? NSSplitViewController
    }
    
    var reposVC: RepositoriesViewController? {
        return splitVC?.splitViewItems[0].viewController as? RepositoriesViewController
    }
    
    var commitsVC: CommitsViewController? {
        return splitVC?.splitViewItems[1].viewController as? CommitsViewController
    }
    
    var commitDetailsVC: DiffViewController? {
        return splitVC?.splitViewItems[2].viewController as? DiffViewController
    }
    
    func setup() {
        
        if let window = window {
            
            var frame = window.frame
            frame.size = NSSize(width: 1050, height: 650)
            window.setFrame(frame, display: true)
            
            window.titleVisibility = .Hidden
        }

        splitVC?.splitView.setPosition(150, ofDividerAtIndex: 0)
        splitVC?.splitView.setPosition(240, ofDividerAtIndex: 1)
        
        reposVC?.delegate = self
        commitsVC?.delegate = self
        commitDetailsVC?.delegate = self
        
        reposVC?.repos = RepositoryStorage.repositories()
    }
    
    func repositoryUrlSelected(url: NSURL) {
        
        var err: NSError?
        var repos: [Repository]?
        
        defer {
            if let err = err {
                NSApp.presentError(err)
            }
        }
        
        guard let path = url.path else {
            err = NSError(domain: "com.rol.zzz.Repos", code: 88, userInfo: [NSLocalizedDescriptionKey : "Failed to handle repository path"])
            return
        }
        
        do {
            repos = try RepositoryStorage.addRepository(path)
        } catch RepositoryStorage.RepoStorageError.AlreadyExists {
            err = NSError(domain: "com.rol.zzz.Repos", code: 89, userInfo: [NSLocalizedDescriptionKey : "Repository already added"])
            return
        } catch {
            err = error as NSError
            return
        }
        
        reposVC?.repos = repos ?? [];
    }
}

// MARK: RepositoriesViewControllerDelegate
extension WindowController: RepositoriesViewControllerDelegate {
    
    func repositoriesViewController(repoViewController: RepositoriesViewController, didSelectRepo repo: GCLiveRepository) {
        
        commitDetailsVC?.load(nil, diff: nil) // clear commit details
        commitsVC?.repo = repo
    }
}

// MARK: CommitsViewControllerDelegate
extension WindowController: CommitsViewControllerDelegate {
    
    func commitsViewController(commitsViewController: CommitsViewController, didSelectCommit commit: GCHistoryCommit, diff: GCDiff) {
        
        commitDetailsVC?.load(commit, diff: diff)
    }
    
    func commitsViewController(commitsViewController: CommitsViewController, didSelectStaging repo: GCLiveRepository) {
        commitDetailsVC?.showStaging(repo)
    }
}

// MARK: DiffViewControllerDelegate
extension WindowController: DiffViewControllerDelegate {
    
    func diffViewControllerRequestsCommit(diffViewController: DiffViewController, message: String) {
        
        do {
            try commitsVC?.repo?.createCommitFromHEADWithMessage(message)
        } catch {
            NSApp.presentError(NSError(domain: "domain", code: 88, userInfo: [NSLocalizedDescriptionKey : "Commit error"]))
        }
    }
}


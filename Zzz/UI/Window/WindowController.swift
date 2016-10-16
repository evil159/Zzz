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
    
    @IBAction func addButtonPressed(_ button: NSView) {
        
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.resolvesAliases = true
        panel.worksWhenModal = true
        panel.beginSheetModal(for: window!, completionHandler:{ resultCode in
            
            guard resultCode == NSFileHandlingPanelOKButton else {
                return
            }
            
            guard let url = panel.urls.first else {
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
            
            window.titleVisibility = .hidden
        }

        splitVC?.splitView.setPosition(150, ofDividerAt: 0)
        splitVC?.splitView.setPosition(240, ofDividerAt: 1)
        
        reposVC?.delegate = self
        commitsVC?.delegate = self
        commitDetailsVC?.delegate = self
        
        reposVC?.repos = RepositoryStorage.repositories()
    }
    
    func repositoryUrlSelected(_ url: URL) {
        
        var err: NSError?
        var repos: [Repository]?
        
        defer {
            if let err = err {
                NSApp.presentError(err)
            }
        }
        
        do {
            repos = try RepositoryStorage.addRepository(url.path)
        } catch RepositoryStorage.RepoStorageError.alreadyExists {
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
    
    func repositoriesViewController(_ repoViewController: RepositoriesViewController, didSelectRepo repo: GCLiveRepository) {
        
        commitDetailsVC?.load(nil, diff: nil) // clear commit details
        commitsVC?.repo = repo
    }
}

// MARK: CommitsViewControllerDelegate
extension WindowController: CommitsViewControllerDelegate {
    
    func commitsViewController(_ commitsViewController: CommitsViewController, didSelectCommit commit: GCHistoryCommit, diff: GCDiff) {
        
        commitDetailsVC?.load(commit, diff: diff)
    }
    
    func commitsViewController(_ commitsViewController: CommitsViewController, didSelectStaging repo: GCLiveRepository) {
        commitDetailsVC?.showStaging(repo)
    }
}

// MARK: DiffViewControllerDelegate
extension WindowController: DiffViewControllerDelegate {
    
    func diffViewControllerRequestsCommit(_ diffViewController: DiffViewController, message: String) {
        
        do {
            try commitsVC?.repo?.createCommitFromHEAD(withMessage: message)
        } catch {
            NSApp.presentError(NSError(domain: "domain", code: 88, userInfo: [NSLocalizedDescriptionKey : "Commit error"]))
        }
    }
}


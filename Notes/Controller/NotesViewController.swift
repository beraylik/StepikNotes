//
//  NotesViewController.swift
//  Notes
//
//  Created by Миландр on 19/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {
    
    private let cellId = "CellId"
    private let cellClassName = "NoteTableViewCell"
    private var notes = [Note]()
    private var context: NSManagedObjectContext?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let willEditing = !tableView.isEditing
        tableView.isEditing = willEditing
        editBarButton.title = willEditing ? "Done" : "Edit"
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        pushToEdit(note: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = CoreDataService.shared.persistentContainer.newBackgroundContext()
        setupTableView()
//        updateToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        FileNotebook.shared.saveToFile()
    }
    
    private func setupTableView() {
        let nib = UINib(nibName: cellClassName, bundle: Bundle.main)
        tableView.register(nib, forCellReuseIdentifier: cellId)
        tableView.isEditing = false
        tableView.backgroundColor = .darkGray
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    // MARK: - Interactions
    
    @objc private func updateToken() {
        guard let token = GithubService.shared.gitHubToken, !token.isEmpty else {
             requestToken()
            return
        }
    }
    
    private func requestToken() {
        let requestTokenViewController = AuthViewController()
        requestTokenViewController.delegate = self
        present(requestTokenViewController, animated: false, completion: nil)
    }
    
    private func pushToEdit(note: Note?) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let editView = storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }
        editView.note = note
        editView.context = self.context
        navigationController?.pushViewController(editView, animated: true)
    }
    
    private func loadNotes() {
        guard let context = context else { return }
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let loadNotesOperation = LoadNotesOperation(
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(loadNotesOperation)
        
        let updateUI = BlockOperation { [weak self] in
            if let notes = loadNotesOperation.result {
                self?.notes = notes
                self?.tableView.reloadData()
            }
        }
        loadNotesOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
    private func deleteNote(at indexPath: IndexPath) {
        guard let context = context else { return }
        
        let note = notes[indexPath.row]
        
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        
        let removeNoteOperation = RemoveNoteOperation(
            note: note,
            context: context,
            backendQueue: backendQueue,
            dbQueue: dbQueue
        )
        commonQueue.addOperation(removeNoteOperation)
        
        let updateUI = BlockOperation { [weak self] in
            self?.notes.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        removeNoteOperation.completionBlock = {
            OperationQueue.main.addOperation(updateUI)
        }
    }
    
}

// MARK: - TableView DataSource

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NoteTableViewCell
        cell.setData(notes[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        deleteNote(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
}

// MARK: - TableView Delegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushToEdit(note: notes[indexPath.row])
    }
    
}

// MARK: - AuthViewController Delegate

extension NotesViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        GithubService.shared.gitHubToken = token
    }
    func finishedAuth(successful: Bool) {
        loadNotes()
    }
}

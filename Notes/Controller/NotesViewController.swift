//
//  NotesViewController.swift
//  Notes
//
//  Created by Миландр on 19/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {
    
    private let cellId = "CellId"
    private let cellClassName = "NoteTableViewCell"
    private var notes = [Note]()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let willEditing = !tableView.isEditing
        tableView.isEditing = willEditing
        editBarButton.title = willEditing ? "Done" : "Edit"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) { // TODO: Fix fetching data
        let backendQueue = OperationQueue()
        let dbQueue = OperationQueue()
        let commonQueue = OperationQueue()
        
        let loadNotesOperation = LoadNotesOperation(
            notebook: FileNotebook.shared,
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
        OperationQueue.main.addOperation(updateUI)
        // while RunLoop.current.run(mode: .default, before: .distantFuture) {}
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
        FileNotebook.shared.remove(with: notes[indexPath.row].uid)
        notes = FileNotebook.shared.notes
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
}

// MARK: - TableView Delegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let editView = storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }
        editView.note = notes[indexPath.row]
        navigationController?.pushViewController(editView, animated: true)
    }
    
}

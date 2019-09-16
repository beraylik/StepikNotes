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
    private var viewModel: NotesViewModel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let willEditing = !tableView.isEditing
        tableView.isEditing = willEditing
        editBarButton.title = willEditing ? "Done" : "Edit"
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        pushToEdit(noteIndex: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = NotesViewModel()
        viewModel.didUpdateNotes = { [weak self] in
            self?.tableView.reloadData()
        }
        
        setupTableView()
//        updateToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.loadNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print(#function)
        viewModel.saveNotes()
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
    
    private func pushToEdit(noteIndex: Int?) {
        let storyboard = UIStoryboard.init(name: "Main", bundle: Bundle.main)
        guard let editView = storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditNoteViewController else { return }

        editView.viewModel = viewModel.getNoteViewModel(index: noteIndex)
        navigationController?.pushViewController(editView, animated: true)
    }
    
}

// MARK: - TableView DataSource

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NoteTableViewCell
        
        let noteVM = viewModel.getNoteViewModel(index: indexPath.row)
        cell.titleLabel.text = noteVM.title
        cell.contentLabel.text = noteVM.content
        cell.colorView.backgroundColor = noteVM.color
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        viewModel.deleteNote(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notesCount
    }
    
}

// MARK: - TableView Delegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushToEdit(noteIndex: indexPath.row)
    }
    
}

// MARK: - AuthViewController Delegate

extension NotesViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        GithubService.shared.gitHubToken = token
    }
    func finishedAuth(successful: Bool) {
        viewModel.loadNotes()
    }
}

//
//  NotesViewController.swift
//  Notes
//
//  Created by Миландр on 19/07/2019.
//  Copyright © 2019 beraylik. All rights reserved.
//

import UIKit
import CoreData

protocol NotesVCProtocol: class {
    func updateContent()
    func removeRow(index: Int)
}

class NotesViewController: UIViewController {
    
    // MARK: - Properties
    
    private let cellId = "CellId"
    private let cellClassName = "NoteTableViewCell"
    
    private var presenter: NotesPresenterProtocol!
    
    // MARK: - IB Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var editBarButton: UIBarButtonItem!
    
    // MARK: - IB Actions
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let willEditing = !tableView.isEditing
        tableView.isEditing = willEditing
        editBarButton.title = willEditing ? "Done" : "Edit"
    }
    
    @IBAction func addNoteTapped(_ sender: Any) {
        pushToEdit(noteAtIndex: nil)
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = NotesPresenter()
        presenter.setVCDelegate(self)
        
        setupTableView()
        
        // Uncomment if you need Network saving
//        updateToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        presenter.loadNotes()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        presenter.saveNotes()
    }
    
    // MARK: - Configure UI
    
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
    
    private func pushToEdit(noteAtIndex: Int?) {
        guard let editVC = presenter.editNoteVC(index: noteAtIndex) else { return }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
}

// MARK: - TableView DataSource

extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NoteTableViewCell
        
        let noteItem = presenter.getNotePresenter(at: indexPath.row)
        cell.setNoteItem(noteItem)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        presenter.deleteNote(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.getNotesCount()
    }
    
}

// MARK: - TableView Delegate

extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        pushToEdit(noteAtIndex: indexPath.row)
    }
    
}

// MARK: - NotesPresenter Delegate

extension NotesViewController: NotesVCProtocol {
    
    func updateContent() {
        tableView.reloadData()
    }
    
    func removeRow(index: Int) {
        let indexPath = IndexPath(row: index, section: 0)
        tableView.deleteRows(at: [indexPath], with: .fade)
    }
    
}

// MARK: - AuthViewController Delegate

extension NotesViewController: AuthViewControllerDelegate {
    func handleTokenChanged(token: String) {
        GithubService.shared.gitHubToken = token
    }
    func finishedAuth(successful: Bool) {
        presenter.loadNotes()
    }
}

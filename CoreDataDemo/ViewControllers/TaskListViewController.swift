//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

protocol TaskViewControllerDelegate {
    func reloadData()
}

class TaskListViewController: UITableViewController {
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        taskList = StorageManager.shared.fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    // не нравится мне этот метод очень большой, как лучше разбить на 2 с минимальными отличиями
    // или что-то можно вынести в отдельные методы
    private func showAlert(with title: String, and message: String, isSaveAction: Bool = true, previousTask: String = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        var leftButton: UIAlertAction
        
        if isSaveAction {
            leftButton = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                self.save(task)
            }
        } else {
            leftButton = UIAlertAction(title: "Edit", style: .default) { _ in
                guard let newTask = alert.textFields?.first?.text, !newTask.isEmpty else { return }
                StorageManager.shared.edit(taskName: previousTask, newTask: newTask)
                self.taskList.forEach { task in
                    if task.title == previousTask {
                        task.title = newTask
                    }
                }
                self.tableView.reloadData()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(leftButton)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        var tasks = StorageManager.shared.save(taskName)
        while tasks.isEmpty == false {
            taskList.append(tasks.removeFirst())
        }
        
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        print(cellIndex.row)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let previousTask = taskList[indexPath.row].title else { return}
        showAlert(with: "Edit Task",
                  and: "What do you want to do?",
                  isSaveAction: false,
                  previousTask: previousTask)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
              StorageManager.shared.remove(taskName: taskList[indexPath.row].title ?? "")
              taskList.remove(at: indexPath.row)
              tableView.deleteRows(at: [indexPath], with: .automatic)
          }
        }
    
}

// MARK: - TaskViewControllerDelegate
extension TaskListViewController: TaskViewControllerDelegate {
    func reloadData() {
        taskList = StorageManager.shared.fetchData()
        tableView.reloadData()
    }
}

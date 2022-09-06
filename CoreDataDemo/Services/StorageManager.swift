//
//  StorageManager.swift
//  CoreDataDemo
//
//  Created by Eugenie Tyan on 06.09.2022.
//

import CoreData

class StorageManager {
     
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy private var context = persistentContainer.viewContext
    
    private init () {}

    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func save(_ taskName: String) -> [Task] {
        var tasks: [Task] = []
        //тут костыль я не придумал как по другому передать данные обратно
        //если метод возращает просто таск, я не понимаю что передавать из гвардов
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return []}
        guard let task = NSManagedObject(entity: entityDescription, insertInto: context) as? Task else { return []}
        task.title = taskName
        tasks.append(task)
        
        if context.hasChanges {
            do {
                try context.save()
            } catch let error {
                print(error)
            }
        }
        
        return tasks
    }
    
    func edit(taskName: String, newTask: String) {
        // какойто гавнокод, будет работать некорректно в случае с одинаковыми тасками мне кажется
        // но с другой стороны 2 одинаковые таски, одну поменяли в итоге какая разница какую заменили
        // можно для этого массив отсортировать и ьаг будет незаметен
        let taskList = fetchData()
        
        taskList.forEach { task in
            if task.title == taskName {
                task.title = newTask
            }
        }
        
        do {
            try context.save()
        } catch let error {
            print("Failed to edit data", error)
        }
    }
    
    func remove(taskName: String) {
        let tasks = fetchData()
        
        tasks.forEach { task in
            if task.title == taskName {
                context.delete(task)
            }
        }

        do {
            try context.save()
        } catch let error {
            print("Failed to remove data", error)
        }
    }
    
    func fetchData() -> [Task] {
        let fetchRequest = Task.fetchRequest()
        var taskList: [Task] = []
        do {
            taskList = try context.fetch(fetchRequest)
        } catch let error {
            print("Failed to fetch data", error)
        }
        
        return taskList
    }
}

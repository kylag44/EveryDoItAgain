//
//  MasterViewController.swift
//  EveryDoItAgain
//
//  Created by Kyla  on 2018-09-05.
//  Copyright © 2018 Kyla . All rights reserved.
//

import UIKit
import CoreData

/////renamed all the events to todos and commented out all timestamp, and change where it is fetching timestamp as well to one on the todo attributes i made

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

  var detailViewController: DetailViewController? = nil
  var managedObjectContext: NSManagedObjectContext? = nil
  var toDos : [NSManagedObject] = []
  var userDefualts = UserDefaults.standard

  override func viewDidLoad() {
    super.viewDidLoad()
    
    /// set up defualt values
    let defaultTitle = "Title Goes Here"
    let defaultDescription = "Description Goes Here"
    let defualtPriorityNumber = 0
    let defaultSwitch = false
    
    userDefualts.set(defaultTitle, forKey:"title")
    userDefualts.set(defaultDescription, forKey: "todoDescription")
    userDefualts.set(defualtPriorityNumber, forKey: "priorityNumber")
    userDefualts.set(defaultSwitch, forKey: "completed")
    
    // Do any additional setup after loading the view, typically from a nib.
    navigationItem.leftBarButtonItem = editButtonItem

    let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
    navigationItem.rightBarButtonItem = addButton
    if let split = splitViewController {
        let controllers = split.viewControllers
        detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
    super.viewWillAppear(animated)
  }

  ///////////////
  override func viewDidAppear(_ animated: Bool) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let context  = appDelegate.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ToDo")
    
    do {
      toDos = try context.fetch(fetchRequest)
      tableView.reloadData()
    } catch {
      print("error viewdidappear")
    }
  }
 ////////////////////
  
  @objc
  func insertNewObject(_ sender: Any) {
    let context = self.fetchedResultsController.managedObjectContext
    let newToDo = ToDo(context: context)
    let alert = UIAlertController(title: "TO DO", message: "Add a new to do!", preferredStyle: .alert)
 
    let saveAction = UIAlertAction(title: "Save", style: .default) {
      [unowned self] action in


      guard let titleToSave = alert.textFields?[0].text,
            let descriptionToSave = alert.textFields?[2].text,
            let priorityToSave = Int32((alert.textFields?[1].text)!) else {
          return;
      }
      self.save(title: titleToSave, toDoDescription: descriptionToSave, priorityNumber: priorityToSave)
      self.tableView.reloadData()
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    
    let defaultTitle = userDefualts.object(forKey: "title") as! String
    let defaultDescription = userDefualts.object(forKey: "todoDescription") as! String
    let defaultPriorityNumber = userDefualts.object(forKey: "priorityNumber") as! Int
    
    alert.addTextField{ (textField) in
      textField.text = defaultTitle
    }
    alert.addTextField{ (textField) in
      textField.text = "\(defaultPriorityNumber)"
    }
    alert.addTextField{ (textField) in
      textField.text = defaultDescription
    }
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    present(alert, animated: true)

    newToDo.title = String()
    // Save the context.
    do {
        try context.save()
  
    } catch {
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
  }
  
  
  func save(title: String, toDoDescription: String, priorityNumber: Int32) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    
    let entity = NSEntityDescription.entity(forEntityName: "ToDo", in: managedContext)!
    
    let toDo = NSManagedObject(entity: entity, insertInto: managedContext)
    
    toDo.setValue(title, forKey: "title")
    toDo.setValue(priorityNumber, forKey: "priorityNumber")
    toDo.setValue(toDoDescription, forKey: "todoDescription")

    do {
      try managedContext.save()
      toDos.append(toDo)

    } catch {
      print("error save title: string")
    }
  }
  
  

  // MARK: - Segues

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail" {
        if let indexPath = tableView.indexPathForSelectedRow {
        let object = fetchedResultsController.object(at: indexPath)
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
            controller.detailItem = object
            controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true
        }
    }
  }

  // MARK: - Table View

  override func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section]
    return sectionInfo.numberOfObjects
  }
//  Modify tableView(UITableView, cellForRowAt: IndexPath) so that it displays the title, todoDescription and priorityNumber properties from the Todo Core Data entity in the cell's textLabel and detailedTextLabel fields respectively.
//  Note: tableView(UITableView, cellForRowAt: IndexPath) uses a helper method `configureCell(, withTodo)` to achieve this._
//
//  Caution: Ensure that you properly unwrap optionals!
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    let toDo = fetchedResultsController.object(at: indexPath)
    configureCell(cell, withTodo: toDo)
    return cell
  }

  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    return true
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        let context = fetchedResultsController.managedObjectContext
        context.delete(fetchedResultsController.object(at: indexPath))
            
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
  }

  func configureCell(_ cell: UITableViewCell, withTodo toDo: ToDo) {
      cell.textLabel!.text = toDo.title!.description

  }

  // MARK: - Fetched results controller

  var fetchedResultsController: NSFetchedResultsController<ToDo> {
      if _fetchedResultsController != nil {
          return _fetchedResultsController!
      }
      
      let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
      
      // Set the batch size to a suitable number.
      fetchRequest.fetchBatchSize = 20
      
      // Edit the sort key as appropriate.
    ////////////this will sort the list by your attributes
      let sortDescriptor = NSSortDescriptor(key: "priorityNumber", ascending: true)
      
      fetchRequest.sortDescriptors = [sortDescriptor]
      
      // Edit the section name key path and cache name if appropriate.
      // nil for section name key path means "no sections".
      let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
      aFetchedResultsController.delegate = self
      _fetchedResultsController = aFetchedResultsController
      
      do {
          try _fetchedResultsController!.performFetch()
      } catch {
           // Replace this implementation with code to handle the error appropriately.
           // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
           let nserror = error as NSError
           fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
      
      return _fetchedResultsController!
  }    
  var _fetchedResultsController: NSFetchedResultsController<ToDo>? = nil

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.beginUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
      switch type {
          case .insert:
              tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
          case .delete:
              tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
          default:
              return
      }
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
      switch type {
          case .insert:
              tableView.insertRows(at: [newIndexPath!], with: .fade)
          case .delete:
              tableView.deleteRows(at: [indexPath!], with: .fade)
          case .update:
            configureCell(tableView.cellForRow(at: indexPath!)!, withTodo: anObject as! ToDo)
          case .move:
            configureCell(tableView.cellForRow(at: indexPath!)!, withTodo: anObject as! ToDo)
              tableView.moveRow(at: indexPath!, to: newIndexPath!)
      }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
      tableView.endUpdates()
  }






}


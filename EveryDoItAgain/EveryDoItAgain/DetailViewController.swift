//
//  DetailViewController.swift
//  EveryDoItAgain
//
//  Created by Kyla  on 2018-09-05.
//  Copyright © 2018 Kyla . All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

  @IBOutlet weak var detailDescriptionLabel: UILabel!
  @IBOutlet weak var numLabel: UILabel!
  @IBOutlet weak var titleLabel: UILabel!
  
  @IBOutlet weak var completedSwitch: UISwitch!
  
  
  func configureView() {
    // Update the user interface for the detail item.
    if let detail = detailItem {
        if let label = detailDescriptionLabel {
              label.text = detail.todoDescription!.description
        }
      if let numLabel = numLabel {
        numLabel.text = detail.priorityNumber.description
      }
      if let titleLabel = titleLabel {
        titleLabel.text = detail.title!.description
      }
    }
  }

  @IBAction func switchPressed(_ sender: UISwitch) {
    var switchValueBool = sender.isOn
    if sender.isOn == true {
      detailItem?.isCompleted = true
    }
    ///getting app delegate
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
      return
    }
    ///which gives us access to the persistentContainer
    let managedContext = appDelegate.persistentContainer.viewContext
    ////which gives us acceess to managedcontex
    detailItem?.setValue(switchValueBool, forKey: "isCompleted")
    ////taking item and setting it to what its toggled too
    do {
      ///attempt to save 
      try managedContext.save()
    } catch {
      print("error updating switchPressed")
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    completedSwitch.isOn = (detailItem?.isCompleted)!
    
    configureView()
  }

  var detailItem: ToDo? {
    didSet {
        // Update the view.
        configureView()
    }
  }
}


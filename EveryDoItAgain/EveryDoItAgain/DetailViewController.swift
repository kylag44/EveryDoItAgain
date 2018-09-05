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

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    configureView()
  }

  var detailItem: ToDo? {
    didSet {
        // Update the view.
        configureView()
    }
  }
}


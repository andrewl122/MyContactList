//
//  DateViewController.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/15/25.
//

import UIKit

// Step 1: Define the delegate protocol OUTSIDE the class
protocol DateControllerDelegate: AnyObject {
    func dateChanged(date: Date)
}

class DateViewController: UIViewController {

    // Step 2: Declare delegate
    weak var delegate: DateControllerDelegate?

    // Step 3: Connect your UIDatePicker from storyboard
    @IBOutlet weak var dtpDate: UIDatePicker!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Step 4: Create save button
        let saveButton: UIBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonItem.SystemItem.save,
            target: self,
            action: #selector(saveDate)
        )

        self.navigationItem.rightBarButtonItem = saveButton
        self.title = "Pick Birthdate"
    }

    // Step 5: Expose method to Objective-C for selector to work
    @objc func saveDate() {
        delegate?.dateChanged(date: dtpDate.date)
        self.navigationController?.popViewController(animated: true)
    }
}

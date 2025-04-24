//
//  SettingsViewController.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/2/25.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var pckSortField: UIPickerView!
    @IBOutlet weak var swAscending: UISwitch!

    let sortOrderItems: Array<String> = ["contactName", "city", "birthday","email"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set data source and delegate for the picker
        pckSortField.dataSource = self
        pckSortField.delegate = self
    }

    // MARK: Set UI based on stored values
    override func viewWillAppear(_ animated: Bool) {
        // Set the UI based on values in UserDefaults
        let settings = UserDefaults.standard
        swAscending.setOn(settings.bool(forKey: Constants.kSortDirectionAscending), animated: true)
        let sortField = settings.string(forKey: Constants.kSortField)
        var i = 0
        for field in sortOrderItems {
            if field == sortField {
                pckSortField.selectRow(i, inComponent: 0, animated: false)
            }
            i += 1
        }
        pckSortField.reloadComponent(0)
    }

    // MARK: Save switch value
    @IBAction func sortDirectionChanged(_ sender: Any) {
        let settings = UserDefaults.standard
        settings.set(swAscending.isOn, forKey: Constants.kSortDirectionAscending)
        settings.synchronize()
        print("Ascending sort is now set to: \(swAscending.isOn)")
    }

    // MARK: Save picker selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sortField = sortOrderItems[row]
        let settings = UserDefaults.standard
        settings.set(sortField, forKey: Constants.kSortField)
        settings.synchronize()
        print("Chosen item: \(sortField)")
    }

    // MARK: UIPickerViewDataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return sortOrderItems.count
    }

    // MARK: UIPickerViewDelegate Method to display titles
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return sortOrderItems[row]
    }
}

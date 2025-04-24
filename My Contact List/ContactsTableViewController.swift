//
//  ContactsTableViewController.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/16/25.
//

import UIKit
import CoreData

class ContactsTableViewController: UITableViewController {

    // var contacts = ["Jim", "John", "Dana", "Rosie", "Justin", "Jeremy", "Sarah", "Matt", "Joe", "Donald", "Jeff"]
    var contacts: [NSManagedObject] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDataFromDatabase()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func loadDataFromDatabase() {
        // Read settings to enable sorting
        let settings = UserDefaults.standard
        let sortField = settings.string(forKey: Constants.kSortField)
        let sortAscending = settings.bool(forKey: Constants.kSortDirectionAscending)

        // Set up Core Data Context
        let context = appDelegate.persistentContainer.viewContext

        // Set up Request
        let request = NSFetchRequest<NSManagedObject>(entityName: "Contact")

        // Specify sorting
        let sortDescriptor = NSSortDescriptor(key: sortField, ascending: sortAscending)
        let sortDescriptorArray = [sortDescriptor] // to sort by multiple fields, add more sort descriptors to the array
        request.sortDescriptors = sortDescriptorArray

        // Execute request
        do {
            contacts = try context.fetch(request)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell", for: indexPath)

        let contact = contacts[indexPath.row] as? Contact
        // Title: Contact Name
        cell.textLabel?.text = contact?.contactName
        // subtitle: City
        cell.detailTextLabel?.text = contact?.city
//        if let city = contact?.city, let email = contact?.email {
//            cell.detailTextLabel?.text = "\(city)  \(email)"
//        } else {
//            cell.detailTextLabel?.text = ""
//        }
    
        cell.accessoryType = .detailDisclosureButton
        
        return cell
    }

    // MARK: - Support deleting rows

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = contacts[indexPath.row] as? Contact
            let context = appDelegate.persistentContainer.viewContext
            context.delete(contact!)

            do {
                try context.save()
            } catch {
                fatalError("Error saving context: \(error)")
            }

            loadDataFromDatabase()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Alert + Navigation via push (programmatically)

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedContact = contacts[indexPath.row] as? Contact
        let name = selectedContact?.contactName ?? ""

        let actionHandler = { (action: UIAlertAction!) -> Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let controller = storyboard.instantiateViewController(withIdentifier: "ContactController") as? ContactsViewController {
                controller.currentContact = selectedContact
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }

        let alertController = UIAlertController(
            title: "Contact selected",
            message: "Selected row: \(indexPath.row) (\(name))",
            preferredStyle: .alert
        )

        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.navigationController?.popViewController(animated: true)
        }

        let actionDetails = UIAlertAction(title: "Show Details", style: .default, handler: actionHandler)

        alertController.addAction(actionCancel)
        alertController.addAction(actionDetails)
        present(alertController, animated: true, completion: nil)
    }


    // MARK: - Unused if using manual push
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContact" {
            let contactController = segue.destination as! ContactsViewController
            let selectedRow = self.tableView.indexPath(for: sender as! UITableViewCell)?.row
            let selectedContact = contacts[selectedRow!] as? Contact
            contactController.currentContact = selectedContact
        }
    }
    
}

//
//  ContactsViewController.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/2/25.
//

import UIKit
import CoreData

class ContactsViewController: UIViewController, UITextFieldDelegate, DateControllerDelegate {

    var currentContact: Contact?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtContact: UITextField!
    @IBOutlet weak var txtState: UITextField!
    @IBOutlet weak var txtZipcode: UITextField!
    @IBOutlet weak var txtCellPhone: UITextField!
    @IBOutlet weak var txtHomePhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblBirthdate: UILabel!
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate fields if editing existing contact
        if currentContact != nil {
            txtContact.text = currentContact!.contactName
            txtAddress.text = currentContact!.streetAddress
            txtCity.text = currentContact!.city
            txtState.text = currentContact!.state
            txtZipcode.text = currentContact!.zipcode
            txtHomePhone.text = currentContact!.phoneNumber
            txtCellPhone.text = currentContact!.cellNumber
            txtEmail.text = currentContact!.email

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            if currentContact!.birthday != nil {
                lblBirthdate.text = formatter.string(from: currentContact!.birthday! as Date)
            }
        }

        // Set edit/view mode and register text fields for updates
        changeEditMode(self)

        let textFields: [UITextField] = [txtContact, txtAddress, txtCity, txtState, txtZipcode,
                                         txtHomePhone, txtCellPhone, txtEmail]

        for textfield in textFields {
            textfield.addTarget(self,
                                action: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)),
                                for: UIControl.Event.editingDidEnd)
        }
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }

        currentContact?.contactName = txtContact.text
        currentContact?.streetAddress = txtAddress.text
        currentContact?.city = txtCity.text
        currentContact?.state = txtState.text
        currentContact?.zipcode = txtZipcode.text
        currentContact?.cellNumber = txtCellPhone.text
        currentContact?.phoneNumber = txtHomePhone.text
        currentContact?.email = txtEmail.text

        return true
    }

    func dateChanged(date: Date) {
        if currentContact == nil {
            let context = appDelegate.persistentContainer.viewContext
            currentContact = Contact(context: context)
        }

        currentContact?.birthday = date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        lblBirthdate.text = formatter.string(from: date)
    }

    @objc func saveContact() {
        print("Save button tapped")
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueContactDate" {
            let dateController = segue.destination as! DateViewController
            dateController.delegate = self
        }
    }

    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [
            txtContact, txtAddress, txtCity, txtState, txtZipcode,
            txtCellPhone, txtHomePhone, txtEmail
        ]

        if sgmtEditMode.selectedSegmentIndex == 0 {
            for textField in textFields {
                textField.isEnabled = false
                textField.borderStyle = .none
            }
            btnChange.isHidden = true
            navigationItem.rightBarButtonItem = nil
        } else {
            for textField in textFields {
                textField.isEnabled = true
                textField.borderStyle = .roundedRect
            }
            btnChange.isHidden = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveContact))
        }
    }

    // MARK: - Keyboard Notifications
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications()
    }

    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(ContactsViewController.keyboardDidShow(notification:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(self,
            selector: #selector(ContactsViewController.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)
    }

    func unregisterKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardDidShow(notification: NSNotification) {
        let userInfo = notification.userInfo! as NSDictionary
        let keyboardInfo = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue
        let keyboardSize = keyboardInfo.cgRectValue.size

        var contentInset = self.scrollView.contentInset
        contentInset.bottom = keyboardSize.height
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        var contentInset = self.scrollView.contentInset
        contentInset.bottom = 0
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}


    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare for segue to birthdate screen, if needed
    }
    */


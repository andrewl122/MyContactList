//
//  ContactsViewController.swift
//  My Contact List
//
//  Created by Andrew Lawrence on 4/2/25.
//

import UIKit

import CoreData

class ContactsViewController: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var txtBirthday: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lblBirthdate: UILabel!
    @IBOutlet weak var sgmtEditMode: UISegmentedControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeEditMode(self)  // Set initial edit mode
        
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

    @objc func saveContact() {
        appDelegate.saveContext()
        sgmtEditMode.selectedSegmentIndex = 0
        changeEditMode(self)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardNotifications()
    }

    // MARK: - Edit Mode Handling
    @IBAction func changeEditMode(_ sender: Any) {
        let textFields: [UITextField] = [
            txtContact, txtAddress, txtCity, txtState, txtZipcode,
            txtCellPhone, txtHomePhone, txtBirthday, txtEmail
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

    // MARK: - Keyboard Notification Registration
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

    // MARK: - Keyboard Actions
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

    /*
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Prepare for segue to birthdate screen, if needed
    }
    */
}

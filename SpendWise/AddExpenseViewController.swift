// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025


import UIKit
import CoreData

class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var categoryPickerView: UIPickerView!

    let categories = ["Food", "Travel", "Shopping", "Utilities", "Other"]
    var selectedCategory: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Dollar sign prefix
        let dollarLabel = UILabel()
        dollarLabel.text = "$"
        dollarLabel.textColor = .gray
        dollarLabel.sizeToFit()
        amountTextField.leftView = dollarLabel
        amountTextField.leftViewMode = .always
        amountTextField.keyboardType = .decimalPad

        // Picker setup
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        selectedCategory = categories.first

        // Style note field
        noteTextView.layer.borderColor = UIColor.lightGray.cgColor
        noteTextView.layer.borderWidth = 0.5
        noteTextView.layer.cornerRadius = 6
    }

    @IBAction func saveExpenseTapped(_ sender: UIButton) {
        guard let amountText = amountTextField.text?.trimmingCharacters(in: .whitespaces),
              let amount = Double(amountText),
              let category = selectedCategory else {
            showAlert("Invalid Input", "Please enter a valid amount and select a category.")
            return
        }

        let date = datePicker.date
        let note = noteTextView.text

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let expense = Expense(context: context)
        expense.amount = amount
        expense.category = category
        expense.date = date
        expense.note = note

        do {
            try context.save()
            showAlert("Success", "Expense saved successfully.")
            clearFields()
            animateCoinDrop()
        } catch {
            showAlert("Error", "Failed to save expense.")
        }
    }

    func animateCoinDrop() {
        guard let coinImage = UIImage(named: "coin") else { return }

        let coinImageView = UIImageView(image: coinImage)
        coinImageView.frame = CGRect(x: view.bounds.midX - 25, y: -50, width: 50, height: 50)
        coinImageView.contentMode = .scaleAspectFit
        coinImageView.alpha = 0.0
        view.addSubview(coinImageView)

        UIView.animate(withDuration: 0.3, animations: {
            coinImageView.alpha = 1.0
        })

        UIView.animate(withDuration: 1.2, delay: 0, options: [.curveEaseIn], animations: {
            coinImageView.frame.origin.y = self.view.bounds.height - 150
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, animations: {
                coinImageView.alpha = 0.0
            }, completion: { _ in
                coinImageView.removeFromSuperview()
            })
        })
    }

    func clearFields() {
        amountTextField.text = ""
        datePicker.date = Date()
        noteTextView.text = ""
        categoryPickerView.selectRow(0, inComponent: 0, animated: true)
        selectedCategory = categories.first
    }

    func showAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Picker View

    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedCategory = categories[row]
    }
}

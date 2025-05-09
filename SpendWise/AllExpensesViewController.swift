// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025


import UIKit
import CoreData

class AllExpensesViewController: UITableViewController {

    // Array to hold fetched expenses
    var expenses = [Expense]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshControl()
        fetchExpenses()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchExpenses() // Refresh data every time the screen appears
    }

    func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ExpenseCell")
        tableView.rowHeight = 70
    }

    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshExpenses), for: .valueChanged)
    }

    @objc func refreshExpenses() {
        fetchExpenses()
        refreshControl?.endRefreshing()
    }

    // Fetch expenses from Core Data
    func fetchExpenses() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            expenses = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Failed to fetch expenses: \(error)")
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expenses.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseCell", for: indexPath)
        let expense = expenses[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = "\(expense.category ?? "Unknown") - $\(expense.amount)"
        let dateText = expense.date?.formatted(date: .abbreviated, time: .omitted) ?? "No date"
        let noteText = expense.note ?? "No note"
        content.secondaryText = "\(dateText) | Note: \(noteText)"
        content.secondaryTextProperties.numberOfLines = 2
        cell.contentConfiguration = content

        return cell
    }
}

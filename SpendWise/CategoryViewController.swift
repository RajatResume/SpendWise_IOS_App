// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoryTotals: [(category: String, amount: Double, percentage: Double)] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Category Summary"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategorySummaryCell")
        fetchCategorySummaries()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchCategorySummaries()
    }

    func fetchCategorySummaries() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Expense> = Expense.fetchRequest()

        do {
            let expenses = try context.fetch(fetchRequest)
            let grouped = Dictionary(grouping: expenses) { $0.category ?? "Unknown" }

            let total = expenses.reduce(0.0) { $0 + $1.amount }
            categoryTotals = grouped.map { (category, items) in
                let categoryAmount = items.reduce(0.0) { $0 + $1.amount }
                let percentage = total > 0 ? (categoryAmount / total) * 100 : 0
                return (category, categoryAmount, percentage)
            }.sorted { $0.amount > $1.amount }

            tableView.reloadData()

        } catch {
            print("Failed to fetch expenses: \(error)")
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryTotals.count + 1 // extra row for total
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategorySummaryCell", for: indexPath)

        var content = cell.defaultContentConfiguration()

        if indexPath.row < categoryTotals.count {
            let item = categoryTotals[indexPath.row]
            content.text = item.category
            content.secondaryText = "$\(String(format: "%.2f", item.amount)) • \(String(format: "%.1f", item.percentage))%"
        } else {
            // Total row
            let total = categoryTotals.reduce(0.0) { $0 + $1.amount }
            content.text = "Total"
            content.secondaryText = "$\(String(format: "%.2f", total))"
            content.textProperties.font = .boldSystemFont(ofSize: 17)
        }

        cell.contentConfiguration = content
        return cell
    }
}

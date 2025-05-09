// Team Members:
// - Venkatesh Talasila - vtalasi@iu.edu
// - Rajat Madhav Sawant - rsawant@iu.edu

// Final Project iOS App Name: SpendWise

// IU GitHub Submission Date: May 6, 2025

import UIKit
import CoreData
import Accelerate

class ChartsViewController: UIViewController {
    var expenses: [Expense] = []
    var categoryColors: [String: UIColor] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshCharts()
    }
    
    func refreshCharts() {
        fetchExpenses()
        generateCategoryColors()
        
        // Clear old views
        view.subviews.forEach { $0.removeFromSuperview() }
        
        // Setup scrollable content
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Title
        let titleLabel = UILabel()
        titleLabel.text = "Expense Breakdown"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        // Process data with Accelerate
        let grouped = Dictionary(grouping: expenses, by: { $0.category ?? "Unknown" })
        var categories: [String] = []
        var categoryAmounts: [Double] = []
        
        for (category, items) in grouped {
            categories.append(category)
            let amounts = items.map { $0.amount }
            var total = 0.0
            vDSP_sveD(amounts, 1, &total, vDSP_Length(amounts.count))
            categoryAmounts.append(total)
        }
        
        // Calculate percentages
        var grandTotal = 0.0
        vDSP_sveD(categoryAmounts, 1, &grandTotal, vDSP_Length(categoryAmounts.count))
        
        var percentages = [Double](repeating: 0, count: categoryAmounts.count)
        if grandTotal > 0 {
            var divisor = grandTotal
            vDSP_vsdivD(categoryAmounts, 1, &divisor, &percentages, 1, vDSP_Length(categoryAmounts.count))
        }
        
        // Create pie segments
        let pieSegments = zip(categories, zip(categoryAmounts, percentages)).map { category, values in
            let (total, percentage) = values
            return (
                value: CGFloat(total),
                color: categoryColors[category] ?? .lightGray,
                label: "\(category) - \(Int(percentage * 100))%"
            )
        }
        
        // Pie Chart
        let pieChart = PieChartView()
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        pieChart.backgroundColor = .white
        pieChart.segments = pieSegments
        contentView.addSubview(pieChart)
        
        // Monthly data processing
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let monthGroups = Dictionary(grouping: expenses) { expense -> String in
            formatter.string(from: expense.date ?? Date())
        }
        
        let sortedMonths = monthGroups.keys.sorted { formatter.date(from: $0)! < formatter.date(from: $1)! }
        var monthTotals = [Double](repeating: 0, count: sortedMonths.count)
        
        // Calculate monthly totals with Accelerate
        for (index, month) in sortedMonths.enumerated() {
            if let expenses = monthGroups[month] {
                let amounts = expenses.map { $0.amount }
                var total = 0.0
                vDSP_sveD(amounts, 1, &total, vDSP_Length(amounts.count))
                monthTotals[index] = total
            }
        }
        
        // Bar Chart Setup
        let barChartTitle = UILabel()
        barChartTitle.text = "Monthly Expense Trend"
        barChartTitle.font = UIFont.boldSystemFont(ofSize: 16)
        barChartTitle.textAlignment = .center
        barChartTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(barChartTitle)
        
        let scrollContainer = UIScrollView()
        scrollContainer.translatesAutoresizingMaskIntoConstraints = false
        scrollContainer.showsHorizontalScrollIndicator = true
        contentView.addSubview(scrollContainer)
        
        let barChart = BarChartView()
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.setData(
            values: monthTotals.map { CGFloat($0) },
            labels: sortedMonths,
            colors: sortedMonths.map { _ in UIColor.randomPastel() }
        )
        scrollContainer.addSubview(barChart)
        
        let chartWidth = barChart.requiredWidth()
        
        // Layout
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            pieChart.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            pieChart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            pieChart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            pieChart.heightAnchor.constraint(equalToConstant: 420),
            
            barChartTitle.topAnchor.constraint(equalTo: pieChart.bottomAnchor, constant: 20),
            barChartTitle.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            scrollContainer.topAnchor.constraint(equalTo: barChartTitle.bottomAnchor, constant: 10),
            scrollContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollContainer.heightAnchor.constraint(equalToConstant: 220),
            
            barChart.topAnchor.constraint(equalTo: scrollContainer.topAnchor),
            barChart.leadingAnchor.constraint(equalTo: scrollContainer.leadingAnchor),
            barChart.heightAnchor.constraint(equalTo: scrollContainer.heightAnchor),
            barChart.widthAnchor.constraint(equalToConstant: chartWidth),
            
            scrollContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        scrollContainer.contentSize = CGSize(width: chartWidth, height: 220)
    }
    
    private func fetchExpenses() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let request: NSFetchRequest<Expense> = Expense.fetchRequest()
        
        do {
            expenses = try context.fetch(request)
        } catch {
            print("Failed to fetch expenses: \(error)")
        }
    }
    
    private func generateCategoryColors() {
        let uniqueCategories = Set(expenses.compactMap { $0.category })
        let colorPool: [UIColor] = [
            .systemRed, .systemBlue, .systemGreen, .systemOrange, .systemPurple,
            .systemTeal, .systemPink, .systemYellow, .brown, .magenta
        ]
        
        for (index, category) in uniqueCategories.enumerated() {
            categoryColors[category] = colorPool[index % colorPool.count]
        }
    }
}

extension UIColor {
    static func randomPastel() -> UIColor {
        return UIColor(
            hue: CGFloat.random(in: 0...1),
            saturation: 0.6,
            brightness: 0.9,
            alpha: 1.0
        )
    }
}

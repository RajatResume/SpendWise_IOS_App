//
//  Expense+CoreDataProperties.swift
//  SpendWise
//
//  Created by Venkatesh Talasila on 4/29/25.
//
//

import Foundation
import CoreData


extension Expense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Expense> {
        return NSFetchRequest<Expense>(entityName: "Expense")
    }

    @NSManaged public var amount: Double
    @NSManaged public var date: Date?
    @NSManaged public var note: String?
    @NSManaged public var category: String?

}

extension Expense : Identifiable {

}

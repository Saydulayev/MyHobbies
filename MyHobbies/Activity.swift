//
//  Activity.swift
//  MyHobbies
//
//  Created by Akhmed on 10.10.23.
//

import SwiftUI

// MARK: - Activity
struct Activity: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var completionCount: Int = 0
    var history: [Date: Int] = [:]
    var category: ActivityCategory
}

//
//  ActivitiesView.swift
//  MyHobbies
//
//  Created by Akhmed on 10.10.23.
//

import SwiftUI


// MARK: - ActivitiesView
struct ActivitiesView: View {
    @ObservedObject var activities: Activities
    @State private var selectedCategory: ActivityCategory? = nil
    @State private var isShowingAddActivity: Bool = false
    @State private var editMode: EditMode = .inactive
    
    var filteredActivities: [Activity] {
        if let category = selectedCategory {
            return activities.items.filter { $0.category == category }
        }
        return activities.items
    }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredActivities) { activity in
                    NavigationLink(destination: EditActivityView(activity: activity, activities: self.activities)) {
                        Text(activity.title)
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationBarTitle("Активности")
            .navigationBarItems(
                leading: EditButton(),
                trailing: Button("Добавить") {
                    isShowingAddActivity = true
                })
            .sheet(isPresented: $isShowingAddActivity) {
                AddActivityView(activities: self.activities)
            }
            .environment(\.editMode, $editMode)
        }
    }
    
    func removeItems(at offsets: IndexSet) {
        activities.items.remove(atOffsets: offsets)
    }
}


// MARK: - Activities
class Activities: ObservableObject {
    @Published var items: [Activity] = [] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.setValue(encoded, forKey: "Activities")
            }
        }
    }
    
    init() {
        if let items = UserDefaults.standard.data(forKey: "Activities") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([Activity].self, from: items) {
                self.items = decoded
                return
            }
        }
        self.items = []
    }
}


// MARK: - Calendar Extension
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

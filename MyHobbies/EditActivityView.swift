//
//  EditActivityView.swift
//  MyHobbies
//
//  Created by Akhmed on 10.10.23.
//

import SwiftUI

// MARK: - EditActivityView
struct EditActivityView: View {
    @ObservedObject var activities: Activities
    @Environment(\.presentationMode) var presentationMode
    var activity: Activity
    
    @State private var title: String
    @State private var description: String
    @State private var selectedCategory: ActivityCategory
    
    init(activity: Activity, activities: Activities) {
        self.activity = activity
        self.activities = activities
        _title = State(initialValue: activity.title)
        _description = State(initialValue: activity.description)
        _selectedCategory = State(initialValue: activity.category)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Название", text: $title)
                TextField("Описание", text: $description)
                Picker("Категория", selection: $selectedCategory) {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
            }
            .navigationBarTitle("Редактировать")
            .padding(.vertical)
            .navigationBarItems(leading: Button("Отменить") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Сохранить") {
                if let index = activities.items.firstIndex(where: { $0.id == activity.id }) {
                    activities.items[index].title = title
                    activities.items[index].description = description
                    activities.items[index].category = selectedCategory
                }
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

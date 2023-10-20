//
//  AddActivityView.swift
//  MyHobbies
//
//  Created by Akhmed on 10.10.23.
//

import SwiftUI

// MARK: - AddActivityView
struct AddActivityView: View {
    @ObservedObject var activities: Activities
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title = ""
    @State private var description = ""
    @State private var selectedCategory = ActivityCategory.fitness
    
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
            .navigationBarTitle("Добавить активность")
            .navigationBarItems(leading: Button("Отменить") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Button("Сохранить") {
                let activity = Activity(title: title, description: description, category: selectedCategory)
                activities.items.append(activity)
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

//
//  ContentView.swift
//  MyHobbies
//
//  Created by Akhmed on 27.09.23.
//

import SwiftUI
import SwiftUICharts
import UserNotifications


struct ContentView: View {
    @ObservedObject var activities = Activities()
    
    @State private var editMode: EditMode = .inactive
    @State private var isEditing = false
    @State private var showingAddActivity = false
    
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    if let activitiesInCategory = groupedActivities()[category], !activitiesInCategory.isEmpty {
                        Section(header: Text(category.rawValue).bold().foregroundColor(.secondary)) {
                            ForEach(activitiesInCategory) { activity in
                                NavigationLink(destination: ActivityDetailView(activity: activity, activities: self.activities)) {
                                    Text(activity.title)
                                        .font(.headline)
                                        .foregroundColor(.indigo)
                                }
                            }
                            .onDelete { (offsets) in
                                for offset in offsets {
                                    let activityToRemove = activitiesInCategory[offset]
                                    if let globalIndex = activities.items.firstIndex(where: { $0.id == activityToRemove.id }) {
                                        activities.items.remove(at: globalIndex)
                                    }
                                }
                            }
                            .onMove(perform: { (source, destination) in
                                moveItems(from: source, to: destination, within: category)
                            })
                        }
                    }
                }
            }
            .navigationBarTitle("Активности", displayMode: .large)
            .navigationBarItems(leading: Button(action: {
                withAnimation {
                    self.isEditing.toggle()
                }
            }, label: {
                withAnimation {
                    Text(isEditing ? Image(systemName: "list.bullet.indent"): Image(systemName: "list.bullet"))
                }
            }).foregroundColor(.indigo), trailing:
                                    Button(action: {
                withAnimation {
                    self.showingAddActivity = true
                }
            }) {
                Image(systemName: "plus")
            }.foregroundColor(.indigo)
            )
            .environment(\.editMode, isEditing ? Binding.constant(.active) : Binding.constant(.inactive))
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(activities: activities)
            }
        }
        .accentColor(.indigo)
    }
    
    func moveItems(from source: IndexSet, to destination: Int, within category: ActivityCategory) {
        var activitiesInCategory = activities(for: category)
        let _: () = activitiesInCategory.move(fromOffsets: source, toOffset: destination)
        
        // Updating the main activities list
        activities.items = activities.items.filter { $0.category != category }
        activities.items.append(contentsOf: activitiesInCategory)
    }
    
    
    
    func removeItems(at offsets: IndexSet) {
        activities.items.remove(atOffsets: offsets)
    }
    
    func activities(for category: ActivityCategory) -> [Activity] {
        return activities.items.filter { $0.category == category }
    }
    
    func groupedActivities() -> [ActivityCategory: [Activity]] {
        return Dictionary(grouping: activities.items) { $0.category }
    }
}













#Preview {
    MainTabView()
}

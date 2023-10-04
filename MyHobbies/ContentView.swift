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
    
//    List {
//        ForEach(activities.items) { activity in
//            NavigationLink(destination: ActivityDetailView(activity: activity, activities: activities)) {
//                Text(activity.title)
//            }
//        }
    
    var body: some View {
        NavigationView {
            List {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    if let activitiesInCategory = groupedActivities()[category], !activitiesInCategory.isEmpty {
                        Section(header: Text(category.rawValue).bold().foregroundColor(.orange)) {
                            ForEach(activitiesInCategory) { activity in
                                NavigationLink(destination: ActivityDetailView(activity: activity, activities: self.activities)) {
                                    Text(activity.title)
                                        .padding(10)
                                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue).opacity(0.1))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: removeItems)
                .onMove(perform: moveItems)
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
            }).foregroundColor(.blue), trailing:
                                    Button(action: {
                                        withAnimation {
                                            self.showingAddActivity = true
                                        }
                                    }) {
                                        Image(systemName: "plus")
                                    }.foregroundColor(.blue)
            )
            .environment(\.editMode, isEditing ? Binding.constant(.active) : Binding.constant(.inactive))
            .sheet(isPresented: $showingAddActivity) {
                AddActivityView(activities: activities)
            }
        }
        .accentColor(.yellow)
    }

    
    func removeItems(at offsets: IndexSet) {
        activities.items.remove(atOffsets: offsets)
    }
    func activities(for category: ActivityCategory) -> [Activity] {
        return activities.items.filter { $0.category == category }
    }
    func moveItems(from source: IndexSet, to destination: Int) {
        activities.items.move(fromOffsets: source, toOffset: destination)
    }
    func groupedActivities() -> [ActivityCategory: [Activity]] {
        return Dictionary(grouping: activities.items) { $0.category }
    }
}

// MARK: - ActivityCategory
enum ActivityCategory: String, CaseIterable, Codable {
    case fitness = "Спорт"
    case study = "Учеба"
    case hobby = "Хобби"
    case religion = "Религия"
    case job = "Работа"
    case others = "Другое"
    // и так далее
}
// MARK: - TimeRange
enum TimeRange: String, CaseIterable {
    case week = "Недельная"
    case month = "Месячная"
    case year = "Годовая"
}

// MARK: - Activity
struct Activity: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var description: String
    var completionCount: Int = 0
    var history: [Date: Int] = [:]
    var category: ActivityCategory
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

// MARK: - ActivityDetailView
struct ActivityDetailView: View {
    let activity: Activity
    
    @ObservedObject var activities: Activities
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showDatePicker = false
    @State private var reminderDate = Date()
    
    
    var body: some View {
        VStack {
            Text(activity.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text(activity.description)
                .underline()
            
            Picker("Период времени", selection: $selectedTimeRange) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Text(range.rawValue).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // График активности за выбранный период времени.
            BarChartView(data: ChartData(points: getData(for: selectedTimeRange)), title: "\(selectedTimeRange.rawValue) статистика", style: ChartStyle(backgroundColor: .white, accentColor: .blue, secondGradientColor: .green, textColor: .black, legendTextColor: .gray, dropShadowColor: .yellow))
                .padding()
            HStack {
                // Кнопка уменьшения
                Button(action: {
                    guard let index = activities.items.firstIndex(of: activity) else { return }
                    var updatedActivity = activity
                    if updatedActivity.completionCount > 0 {
                        updatedActivity.completionCount -= 1
                        activities.items[index] = updatedActivity
                    }
                }) {
                    Text("-")
                        .frame(width: 30, height: 30)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                
                Text("\(activity.completionCount) \(pluralForm(for: activity.completionCount))")
                    .underline()
                    .padding()
                // Кнопка увеличения
                Button(action: {
                    guard let index = activities.items.firstIndex(of: activity) else { return }
                    var updatedActivity = activity
                    updatedActivity.completionCount += 1
                    activities.items[index] = updatedActivity
                }) {
                    Text("+")
                        .frame(width: 30, height: 30)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding()
            
            // Кнопка сброса
            Button(action: {
                guard let index = activities.items.firstIndex(of: activity) else { return }
                var updatedActivity = activity
                updatedActivity.completionCount = 0
                activities.items[index] = updatedActivity
            }) {
                Text("Сбросить")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .padding()
            
        }
        // Кнопка редактирования активности в навигационной панели.
        .navigationBarItems(trailing:
                                NavigationLink(destination: EditActivityView(activity: activity, activities: activities)) {
            Text("Редактировать")
        })
        // Модальное окно для установки напоминаний.
        .sheet(isPresented: $showDatePicker) {
            VStack {
                Spacer()
                // Выбор даты и времени напоминания.
                DatePicker("Выберите время", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    .labelsHidden()
                    .datePickerStyle(WheelDatePickerStyle())
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                Button("Установить напоминание") {
                    requestNotificationPermission {_ in
                        self.scheduleNotification(for: activity, at: reminderDate)
                        self.showDatePicker = false
                    }
                }
                Spacer()
                Button("Отмена") {
                    self.showDatePicker = false
                }
            }
        }
        
        Button("Добавить напоминание") {
            self.showDatePicker.toggle()
        }
        .foregroundColor(.orange)
    }
    // Получение данных для графика в зависимости от выбранного периода времени.
    func getData(for timeRange: TimeRange) -> [Double] {
        var dataPoints: [Double] = []
        let calendar = Calendar.current
        let rangeCount: Int
        
        switch timeRange {
        case .week:
            rangeCount = 7
        case .month:
            rangeCount = 30
        case .year:
            rangeCount = 12 // 12 months
        }
        
        for i in 0..<rangeCount {
            if let date = calendar.date(byAdding: (timeRange == .year ? .month : .day), value: -i, to: Date()) {
                let relevantDate: Date
                if timeRange == .year {
                    relevantDate = calendar.startOfMonth(for: date)
                } else {
                    relevantDate = calendar.startOfDay(for: date)
                }
                dataPoints.append(Double(activity.history[relevantDate] ?? 0))
            }
        }
        
        return dataPoints.reversed()
    }
    
    // Определение правильной формы слова "раз" в зависимости от количества.
    func pluralForm(for count: Int) -> String {
        if count % 10 == 1 && count % 100 != 11 {
            return "раз"
        } else if (2...4).contains(count % 10) && !(12...14).contains(count % 100) {
            return "раза"
        } else {
            return "раз"
        }
    }
    
    // Планирование уведомления для активности.
    func scheduleNotification(for activity: Activity, at date: Date) {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined, .denied:
                self.requestNotificationPermission(completion: { granted in
                    if granted {
                        self.addNotification(for: activity, at: date, with: center)
                    } else {
                        print("Permission denied!")
                    }
                })
            case .authorized, .provisional:
                self.addNotification(for: activity, at: date, with: center)
            case .ephemeral:
                print("Ephemeral authorization not handled.")
            @unknown default:
                print("Unknown authorization status.")
            }
        }
    }
    
    // Добавление уведомления.
    private func addNotification(for activity: Activity, at date: Date, with center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "Напоминание о активности!"
        content.body = "\(activity.title)"
        content.categoryIdentifier = "alarm"
        content.userInfo = ["activityID": activity.id.uuidString]
        content.sound = UNNotificationSound.default
        
        let triggerDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Error adding notification: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    print("Напоминание успешно добавлено!")
                }
            }
        }
    }
    
    // Запрос разрешения на отправку уведомлений.
    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if let error = error {
                print("Error requesting notifications permission: \(error)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
}

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
            .navigationBarTitle("Редактировать активность")
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

// MARK: - Calendar Extension
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = self.dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ActivityDetailView.swift
//  MyHobbies
//
//  Created by Akhmed on 10.10.23.
//

import SwiftUI
import SwiftUICharts
import ContributionChart


// MARK: - ActivityDetailView
struct ActivityDetailView: View {
    let activity: Activity

    @ObservedObject var activities: Activities
    
    @State private var selectedTimeRange: TimeRange = .week
    @State private var showDatePicker = false
    @State private var reminderDate = Date()
    
    
    
    var body: some View {
        ScrollView {
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
                BarChartView(data: ChartData(points: getData(for: selectedTimeRange)), title: "\(selectedTimeRange.rawValue) статистика", style: ChartStyle(backgroundColor: .white, accentColor: .blue, secondGradientColor: .green, textColor: .black, legendTextColor: .gray, dropShadowColor: .indigo))
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
                        .background(.regularMaterial)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
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
                .foregroundColor(.indigo)
            }
            
            
            

            // Кнопка редактирования активности в навигационной панели.
            .navigationBarItems(trailing:
                                    NavigationLink(destination: EditActivityView(activity: activity, activities: activities)) {
                Text("Редактировать")
        })
        }
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
    
    func getColumnsCount(for timeRange: TimeRange) -> Int {
        switch timeRange {
        case .week:
            return 1  // 1 колонка на 7 дней
        case .month:
            return 4  // Примерно 4 колонки на 30 дней
        case .year:
            return 12 // 12 месяцев
        }
    }

    func getMaxCount() -> Double {
        return Double(activities.items.map { $0.completionCount }.max() ?? 1)
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

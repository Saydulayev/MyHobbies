//
//  MainTabView.swift
//  MyHobbies
//
//  Created by Akhmed on 09.10.23.
//

import SwiftUI
import FirebaseAuth

struct MainTabView: View {
    @State private var selectedTab = 0
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(0)

            if Auth.auth().currentUser != nil {
                ProfileView() // Представление профиля пользователя
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Аккаунт")
                    }
                    .tag(1)
            } else {
                AuthenticationView()
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Войти")
                    }
                    .tag(1)
            }
        }
        .accentColor(colorScheme == .dark ? .white : .black)
    }
}



#Preview {
    MainTabView()
}

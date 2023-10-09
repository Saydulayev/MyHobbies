//
//  MyHobbiesApp.swift
//  MyHobbies
//
//  Created by Akhmed on 27.09.23.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore



//@main
//struct MyHobbiesApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}





class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MyHobbiesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @ObservedObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if authViewModel.isSignedIn {
                    MainTabView()
                } else {
                    AuthenticationView()
                }
            }
            .onAppear {
                authViewModel.listen()
            }
        }
    }
}








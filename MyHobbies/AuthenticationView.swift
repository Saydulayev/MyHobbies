//
//  AuthenticationView.swift
//  MyHobbies
//
//  Created by Akhmed on 08.10.23.
//

//import SwiftUI
//import Firebase
//import FirebaseAuth
//import FirebaseFirestore
//
//struct AuthenticationView: View {
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var isSignIn = true
//    @State private var errorMessage: String?
//    
//    var body: some View {
//        VStack(spacing: 16) {
//            TextField("Email", text: $email)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//                .autocapitalization(.none)
//            
//            SecureField("Пароль", text: $password)
//                .textFieldStyle(RoundedBorderTextFieldStyle())
//            
//            if let error = errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//            }
//            
//            Button(action: isSignIn ? signIn : signUp) {
//                Text(isSignIn ? "Войти" : "Регистрация")
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            
//            Button(action: { isSignIn.toggle() }) {
//                Text(isSignIn ? "Нет аккаунта? Создать" : "Уже есть аккаунт? Войти")
//            }
//        }
//        .padding()
//    }
//    
//    func signIn() {
//        Auth.auth().signIn(withEmail: email, password: password) { result, error in
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//                return
//            }
//            // Выполните переход к основному представлению или обновите интерфейс
//        }
//    }
//    
//    func signUp() {
//        Auth.auth().createUser(withEmail: email, password: password) { result, error in
//            if let error = error {
//                self.errorMessage = error.localizedDescription
//                return
//            }
//            // Выполните переход к основному представлению или обновите интерфейс
//        }
//    }
//}
//
//@main
//struct MyHobbiesApp: App {
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//
//    var body: some Scene {
//        WindowGroup {
//            NavigationView {
//                // Переключение между представлениями аутентификации и основного содержимого
//                if Auth.auth().currentUser != nil {
//                    ContentView()
//                } else {
//                    AuthenticationView()
//                }
//            }
//        }
//    }
//}





#Preview {
    AuthenticationView()
}

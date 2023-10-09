//
//  AuthenticationView.swift
//  MyHobbies
//
//  Created by Akhmed on 08.10.23.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct AuthenticationView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isSignIn = true
    @State private var errorMessage: String?
    @State private var showVerificationAlert = false // Для показа уведомления о подтверждении
    
    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
            
            SecureField("Пароль", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !isSignIn {
                SecureField("Подтвердите пароль", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
            
            Button(action: isSignIn ? signIn : signUp) {
                Text(isSignIn ? "Войти" : "Регистрация")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: { isSignIn.toggle() }) {
                Text(isSignIn ? "Нет аккаунта? Создать" : "Уже есть аккаунт? Войти")
            }
        }
        .padding()
        .alert(isPresented: $showVerificationAlert) {
            Alert(title: Text("Успешно"), message: Text("Регистрация прошла успешно. Пожалуйста, проверьте свою электронную почту и подтвердите регистрацию."), dismissButton: .default(Text("Ок")))
        }
    }
    
    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            // Выполните переход к основному представлению или обновите интерфейс
        }
    }
    
    func signUp() {
        if password != confirmPassword {
            errorMessage = "Пароли не совпадают"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                return
            }
            
            let user = Auth.auth().currentUser
            user?.sendEmailVerification(completion: { (error) in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                // Уведомление пользователя о успешной регистрации
                self.showVerificationAlert = true
            })
        }
    }
}

struct ProfileView: View {
    // Пытаемся получить текущего пользователя из Firebase Auth
    var user: User? = Auth.auth().currentUser
    
    var body: some View {
        VStack {
            // Если пользователь авторизован, отображаем его email, иначе - текст "Профиль пользователя"
            if let userEmail = user?.email {
                VStack {
                    AnimatedText(text: "Добро пожаловать")
                        .font(.largeTitle)
                        .padding(.vertical, 20)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    AnimatedText(text: "\(userEmail)")
                        .font(.title)
                }
                
                
            } else {
                Text("Профиль пользователя")
            }
            
            Button(action: {
                try? Auth.auth().signOut()
            }) {
                Text("Выход")
                    .foregroundColor(.black)
                    .padding(40)
                    .background(.thinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.indigo)
    }
}



class AuthViewModel: ObservableObject {
    var handle: AuthStateDidChangeListenerHandle?
    @Published var isSignedIn = false

    func listen() {
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.isSignedIn = true
            } else {
                self.isSignedIn = false
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopListening() {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}










#Preview {
    AuthenticationView()
}

//
//  AuthFormView.swift
//  CS_HUB
//
//  Created by Nikstanov on 19.03.24.
//

import SwiftUI
import FirebaseAuth

struct AuthFormView: View {
    @EnvironmentObject var dataManager: APIManager
    
    @State private var email : String = ""
    @State private var password : String = ""
    @State private var userIsLoggedIn: Bool = false
    @State private var userIsSignIn: Bool = false
    @State private var isLoading: Bool = false
    
    @State private var firstname : String = ""
    @State private var lastname : String = ""
    @State private var country : String = ""
    
    @State private var showingAlert = false
    @State private var alerts: [String] = []
    
    var body: some View {
        if userIsLoggedIn {
            ContentView()
        }
        else{
            if isLoading {
                ProgressView()
            }
            else{
                if userIsSignIn {
                    contentSignIn
                }
                else{
                    contentSignUp
                }
            }
            
        }
    }
    
    var contentSignUp: some View{
        VStack(spacing: 20){
        
            Group{
            Text("CS_HUB")
                .font(.system(size:80, weight: .bold, design: .rounded))
                .offset(x : 0, y : -50)
            
            
            Text("Sign up")
                .font(.system(size:40, weight: .bold, design: .rounded))
            }
            
            Group{
            TextField("", text: $email, prompt: Text("Email").font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }
            
            Group{
            SecureField("", text: $password, prompt: Text("Password").font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }

            Group{
            TextField("", text: $firstname, prompt: Text("first name").font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }
            
            Group{
            TextField("", text: $lastname, prompt: Text("last name").font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }
            
            Group{
                HStack{
                    Menu{
                        Picker("", selection:
                                $country){
                            ForEach(NSLocale.isoCountryCodes, id: \.self){
                                countrycode in
                                Text(Locale.current.localizedString(forRegionCode: countrycode)
                                     ?? "")
                            }
                        }
                    } label: {
                        Text(Locale.current.localizedString(forRegionCode: country)
                             ?? "country")
                            .font(.system(size:20, weight: .bold))
                            .foregroundColor(.black)
                            .opacity(0.3)
                    }
                    Spacer()
                }
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }
            
            Button{
                register()
            } label: {
                Text("Sign up")
                    .bold()
                    .frame(width: 200, height:40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(.blue)
                    )
                    .foregroundColor(.white)
            }
            .padding(.top)
            .offset(y: 110)
            .alert(isPresented: $showingAlert){
                Alert(title: Text("Ooops"),
                      message: Text(alerts.joined(separator: "/n")), dismissButton: .default(Text("OK")))
            }
            
            Button{
                userIsSignIn.toggle()
            } label: {
                Text("Already have an account?")
            }
            .padding(.top)
            .offset(y: 80)
        }
        .frame(width: 350)
        .onAppear(){
            self.isLoading = false
            Auth.auth().addStateDidChangeListener {
                auth, user in
                if user != nil {
                    userIsLoggedIn = true
                    self.isLoading = false
                    dataManager.fetchUser()
                }
            }
        }
        .onChange(of: showingAlert){
            newVal in
            if !newVal {
                alerts.removeAll()
            }
        }
    }
    
    var contentSignIn: some View{
        VStack(spacing: 20){
            Text("CS_HUB")
                .font(.system(size:80, weight: .bold, design: .rounded))
                .offset(x : 0, y : -100)
            Text("Sign in")
                .font(.system(size:40, weight: .bold, design: .rounded))
                .offset(x : 0, y : 0)
            
            TextField("", text: $email, prompt: Text("Email").font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            
            SecureField("", text: $password, prompt: Text("Password").font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            
            Button{
                login()
            } label: {
                Text("Sign in")
                    .bold()
                    .frame(width: 200, height:40)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .foregroundColor(.blue)
                    )
                    .foregroundColor(.white)
            }
            .padding(.top)
            .offset(y: 110)
            .alert(isPresented: $showingAlert){
                Alert(title: Text("Ooops"),
                      message: Text(alerts.joined(separator: "/n")), dismissButton: .default(Text("OK")))
            }
            
            Button{
                userIsSignIn.toggle()
            } label: {
                Text("Sign up")
            }
            .padding(.top)
            .offset(y: 80)
            
        }
        .frame(width: 350)
        .onAppear(){
            Auth.auth().addStateDidChangeListener {
                auth, user in
                if user != nil {
                    userIsLoggedIn = true
                    self.isLoading = false
                    dataManager.fetchUser()
                }
            }
        }
        .onChange(of: showingAlert){
            newVal in
            if !newVal {
                alerts.removeAll()
            }
        }
    }
    
    func isValidEmail(_ email : String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPred.evaluate(with: email)
    }
    
    func register(){
        guard isValidEmail(email) else{
            alerts.append("Invalid email")
            self.showingAlert = true
            return
        }
        guard password.count >= 8 else{
            alerts.append("password length should be >= 8")
            self.showingAlert = true
            return
        }
        dataManager.createUser(email: email, password: password, firstname: firstname, lastname: lastname, country: country){
            error in
            alerts.append(error)
            self.showingAlert = true
        }
    }
    
    func login(){
        self.isLoading = true
        guard isValidEmail(email) else{
            alerts.append("Invalid email")
            self.showingAlert = true
            return
        }
        guard password.count >= 8 else{
            alerts.append("password length should be >= 8")
            self.showingAlert = true
            self.isLoading = false
            return
        }
        Auth.auth().signIn(withEmail: email, password: password){
            result, error in
            guard error == nil else{
                self.alerts.append(error!.localizedDescription)
                self.showingAlert = true
                print(error!.localizedDescription)
                self.isLoading = false
                return
            }
        }
    }
}

struct AuthFormView_Previews: PreviewProvider {
    static var previews: some View {
        AuthFormView()
    }
}

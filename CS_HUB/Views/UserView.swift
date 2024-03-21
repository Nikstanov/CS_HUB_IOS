//
//  UserView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct UserView: View {
    
    @EnvironmentObject var dataManager: APIManager
    @State var email : String
    @State var firstname : String
    @State var lastname : String
    @State var country : String
    
    init(_ user : User){
        self.email = user.email
        self.firstname = user.firstname
        self.lastname = user.lastname
        self.country = user.country
    }
    
    var body: some View {
        VStack{
            Text("User info")
                .font(.system(size:40, weight: .bold, design: .rounded))
            
            Group{
                TextField("", text: $email, prompt: Text(email).font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }

            Group{
                TextField("", text: $firstname, prompt: Text(firstname).font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }
            
            Group{
                TextField("", text: $lastname, prompt: Text(lastname).font(.system(size:20, weight: .bold)))
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
                
            } label: {
                Text("Save")
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
        }
        .frame(width: 350)
        .navigationBarTitle("Players")
    }
}

struct UserView_Previews: PreviewProvider {
    static var previews: some View {
        UserView(User(id: "brrr", email: "someEmail", firstname: "test_anme", lastname: "test_lastname", country: "AB"))
    }
}

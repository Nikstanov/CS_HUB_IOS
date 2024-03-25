//
//  ContentView.swift
//  CS_HUB
//
//  Created by Nikstanov on 13.03.24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    
    @EnvironmentObject var dataManager: APIManager
    
    @State private var signOut = false;
    @State private var selected = 0
    
    var body: some View {
        if signOut {
            AuthFormView()
        }
        else{
            NavigationView{
                VStack{
                    switch selected {
                    case 0:
                        TeamsView()
                    case 1:
                        PlayersView()
                    case 2:
                        UserView(dataManager.user)
                    default:
                        TeamsView()
                    }
                    Spacer()
                    ZStack{
                        HStack{
                            Button {
                                selected = 0
                            } label: {
                              Text("Teams")
                            }.foregroundColor(selected == 0 ? .black : .gray)
                            Spacer()
                            Button {
                                selected = 1
                            } label: {
                              Text("Players")
                            }.foregroundColor(selected == 1 ? .black : .gray)
                            Spacer()
                            Button {
                                selected = 2
                            } label: {
                              Text("User")
                            }.foregroundColor(selected == 2 ? .black : .gray)
                        }
                    }
                    .frame(width: 300, height: 20)
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading:
                        Button{
                            do {
                                try Auth.auth().signOut()
                            }
                            catch {
                                print("Some error with sign out")
                            }
                            dataManager.unfecthLikedPlayers()
                            signOut.toggle()
                        } label: {
                            Text("Sign out")
                        })
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12")
    }
}

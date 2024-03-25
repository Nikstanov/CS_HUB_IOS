//  PlayersView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct PlayersView: View{
    
    @EnvironmentObject var dataManager: APIManager
    @State private var isCreateNew = false
    @State private var isOnlyLiked = false
    @State private var search = ""
    
    var body: some View{
        if isCreateNew {
            PlayerView(true)
        }
        else{
            HStack{
                Toggle(isOn: $isOnlyLiked){
                    Text("Favourites only")
                }
            }
            .frame(width: 350)
            
            Group{
                TextField("", text: $search, prompt: Text(search).font(.system(size:20, weight: .bold)))
                .foregroundColor(.black)
                .textFieldStyle(.plain)
            Rectangle()
                .frame(width: 350, height: 1)
                .foregroundColor(.black)
            }
            .frame(width: 350)
            
            List(dataManager.players, id: \.id){ player in
                if isOnlyLiked {
                    if dataManager.liked_players.contains(player.nick_name){
                        if search == "" || player.nick_name.contains(search){
                            NavigationLink{
                                PlayerView(false, player: player)
                            } label: {
                                PlayerRow(player: player)
                            }
                        }
                        
                    }
                }
                else{
                    if search == "" || player.nick_name.contains(search){
                        NavigationLink{
                            PlayerView(false, player: player)
                        } label: {
                            PlayerRow(player: player)
                        }
                    }
                }
            }
            .navigationBarTitle("Players")
            .navigationBarItems(trailing:
                    Button{
                        isCreateNew.toggle()
                    } label: {
                        Image(systemName: "plus")
                    })
        }
    }
}

struct PlayerRow: View{
    
    var player : Player
    
    var body: some View{
        HStack{
            Text(player.nick_name)
        }
    }
}

struct PlayersView_Previews: PreviewProvider {
    static var previews: some View {
        PlayersView()
    }
}

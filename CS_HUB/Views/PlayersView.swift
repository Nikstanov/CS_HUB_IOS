//  PlayersView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct PlayersView: View{
    
    @EnvironmentObject var dataManager: APIManager
    @State private var isCreateNew = false
    
    var body: some View{
        if isCreateNew {
            PlayerView(true)
        }
        else{
            List(dataManager.players, id: \.id){ player in
                NavigationLink{
                    PlayerView(false, player: player)
                } label: {
                    PlayerRow(player: player)
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

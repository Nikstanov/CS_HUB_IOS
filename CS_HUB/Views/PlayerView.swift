//
//  PlayerView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct PlayerView: View {
    
    @EnvironmentObject var dataManager: APIManager
    
    private var id:Int
    private var newPlayer: Bool
    private var player: Player
    
    @State private var images : [UIImage] = []
    @State var selectedImageIndex = 0

    init(_ newPlayer: Bool,player :Player = Player(id: 0, full_name: "", nick_name: "", birth_date: Date(), team_name: "")){
        self.newPlayer = newPlayer
        self.id = player.id
        self.player = player
    }
    
    var body: some View {
        VStack{
            if !newPlayer {
                if images.count > 0 {
                    TabView(selection: $selectedImageIndex){
                        ForEach(Array(images.enumerated()), id: \.element){
                            ind, item in
                                Image(uiImage: item)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width:350, height: 200)
                                    .tag(ind)
                        }
                    }
                    .frame(height:300)
                    .tabViewStyle(PageTabViewStyle())
                    .ignoresSafeArea()
                    .onReceive(Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()){
                        _ in
                        withAnimation(.default){
                            if(!newPlayer){
                                selectedImageIndex = (selectedImageIndex + 1) % images.count
                            }
                        }
                    }
                } else {
                    ProgressView()
                }
            }
            else{
                VStack{
                    Image("anonymous")
                        .resizable()
                        .scaledToFit()
                        .frame(width:350, height: 200)
                }
                .frame(height: 300)
                .ignoresSafeArea()
                
            }
            
        }
        .onAppear {
            dataManager.downImage(player_name: player.nick_name){
                image in
                self.images.append(image)
            }
        }
        
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(false)
    }
}

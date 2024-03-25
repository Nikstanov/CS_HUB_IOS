//
//  PlayerView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct PlayerView: View {
    
    @EnvironmentObject var dataManager: APIManager
    @State var birth_date = Date()
    @State var full_name = ""
    @State var nationality = ""
    @State var nick_name = ""
    @State var team_name = ""
    @State var isLiked = false
    @State var newReview = ""
    
    //private var id:Int
    private var newPlayer: Bool
    private var player: Player
    
    @State private var images : [UIImage] = []
    @State var selectedImageIndex = 0
    @State var savingPlayer = false
    
    init(_ newPlayer: Bool,player :Player = Player(id: 0, full_name: "Full name", nick_name: "Nickname", birth_date: Date(), team_name: "team_spirit", nationality: "AE")){
        self.newPlayer = newPlayer
        //self.id = player.id
        self.player = player
    }
    
    var body: some View {
        ScrollView{
            VStack{
                
            VStack{
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
                            .offset(y:100)
                    }
                    .frame(height: 300)
                    .ignoresSafeArea()
                    
                }
                }
                if newPlayer{
                    Group{
                        TextField("", text: $nick_name, prompt: Text(nick_name).font(.system(size:20, weight: .bold)))
                        .foregroundColor(.black)
                        .textFieldStyle(.plain)
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(.black)
                    }
                }
                else{
                    Group{
                        HStack{
                            Text(nick_name).font(.system(size:20, weight: .bold))
                            .foregroundColor(.black)
                            Button(action: {
                                
                                self.isLiked.toggle()
                                if isLiked{
                                    dataManager.addLike(playerName: nick_name)
                                }
                                else{
                                    dataManager.removeLike(playerName: nick_name)
                                }
                                
                            },label:{
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                            })
                        }
                        Rectangle()
                            .frame(width: 350, height: 1)
                            .foregroundColor(.black)
                    }
                }
                Group{
                    TextField("", text: $full_name, prompt: Text(full_name).font(.system(size:20, weight: .bold)))
                    .foregroundColor(.black)
                    .textFieldStyle(.plain)
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(.black)
                }
                Menu{
                    Picker("", selection:
                            $team_name){
                        ForEach(dataManager.teams, id: \.self){
                            team in
                            Text(team.team_name)
                        }
                    }
                } label: {
                    Text(team_name)
                        .font(.system(size:20, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(0.3)
                }
                DatePicker("Select a date",
                           selection: $birth_date, displayedComponents: .date)
                Menu{
                    Picker("", selection:
                            $nationality){
                        ForEach(NSLocale.isoCountryCodes, id: \.self){
                            countrycode in
                            Text(Locale.current.localizedString(forRegionCode: countrycode)
                                 ?? "")
                        }
                    }
                } label: {
                    Text(Locale.current.localizedString(forRegionCode: nationality)
                         ?? "country")
                        .font(.system(size:20, weight: .bold))
                        .foregroundColor(.black)
                        .opacity(0.3)
                }
                if savingPlayer{
                    ProgressView()
                }
                else{
                    Button{
                        self.savingPlayer.toggle()
                        dataManager.savePlayer(player: Player(id: player.id, full_name: full_name, nick_name: nick_name, birth_date: birth_date, team_name: team_name, nationality: nationality)){
                            error in
                            if error != "" {
                                
                            }
                            self.savingPlayer.toggle()
                        }
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
                }
                
                if !newPlayer{
                    VStack{
                        Group{
                            TextField("", text: $newReview, prompt: Text("New review").font(.system(size:20, weight: .bold)))
                            .foregroundColor(.black)
                            .textFieldStyle(.plain)
                            Rectangle()
                                .frame(width: 350, height: 1)
                                .foregroundColor(.black)
                            Button{
                                dataManager.saveComment(text: newReview, playerName: nick_name)
                                newReview = ""
                            } label: {
                                Text("Save review")
                            }
                        }
                        Text("Reviews:").bold()
                        if dataManager.reviews.count > 0{
                            ForEach(dataManager.reviews, id: \.self){
                                item in
                                    VStack{
                                        Text(item.name).bold().multilineTextAlignment(.leading)
                                        Text(item.text).multilineTextAlignment(.leading)
                                    }
                            }
                        }
                    }
                }
            }
            }
        }
        .frame(width: 350)
        .onAppear {
            dataManager.downImage(player_name: player.nick_name){
                image in
                self.images.append(image)
            }
            dataManager.unsubscribeReview()
            
            self.birth_date = player.birth_date
            self.nick_name = player.nick_name
            self.full_name = player.full_name
            self.team_name = player.team_name
            self.nationality = player.nationality
            self.isLiked = dataManager.liked_players.contains(nick_name)
            
            dataManager.subscribeReviews(playerName: nick_name)
        }
        
        
    }
}

struct ReviewRow: View{
    
    var review: Review
    
    var body: some View{
        VStack{
            Text(review.name)
            Text(review.text)
        }
        //.background(Color.gray)
        .frame(width: 350, height:200)
    }
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView(false)
    }
}





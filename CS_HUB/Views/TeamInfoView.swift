//
//  TeamInfoView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct TeamInfoView: View {
    
    @EnvironmentObject var dataManager: APIManager
    
    @State var id : Int
    @State var team_name : String
    @State var year_created_at : Int
    
    var body: some View {
        VStack{
            Text(team_name)
                .font(.system(size:40, weight: .bold, design: .rounded))
            
            Group{
                Stepper("Creation year: " + String(year_created_at), onIncrement: {
                    if(self.year_created_at < 2024){
                        self.year_created_at += 1
                    }
                },
                        onDecrement: {
                    if(self.year_created_at > 1901){
                        self.year_created_at -= 1
                    }
                    
                })
                .foregroundColor(.black)
                .textFieldStyle(.plain)
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
        .frame(width:350)
    }
}

struct TeamInfoView_Previews: PreviewProvider {
    static var previews: some View {
        TeamInfoView(id: 0, team_name: "someTeam", year_created_at: 2002)
    }
}

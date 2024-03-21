//
//  TeamsView.swift
//  CS_HUB
//
//  Created by Nikstanov on 20.03.24.
//

import SwiftUI

struct TeamsView: View{
    
    @EnvironmentObject var dataManager: APIManager
    @State private var isCreateNew = false
    
    var body: some View{
        if isCreateNew {
            
        }
        else{
            List(dataManager.teams, id: \.id){ team in
                NavigationLink{
                    TeamInfoView(id: team.id, team_name: team.team_name, year_created_at: team.year_created_at)
                } label: {
                    TeamRow(team: team)
                }
            }
            .navigationTitle("Teams")
            .navigationBarItems(trailing:
                    Button{
                        isCreateNew.toggle()
                    } label: {
                        Image(systemName: "plus")
                    })
        }
    }
}

struct TeamRow: View{
    
    var team : Team
    
    var body: some View{
        HStack{
            Text(team.team_name + " " + String(team.year_created_at))
        }
    }
}

struct TeamsView_Previews: PreviewProvider {
    static var previews: some View {
        TeamsView()
    }
}

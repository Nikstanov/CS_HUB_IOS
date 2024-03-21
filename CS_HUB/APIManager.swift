//
//  APIManager.swift
//  CS_HUB
//
//  Created by Nikstanov on 13.03.24.
//


import Foundation
import SwiftUI
import Firebase
import FirebaseStorage
import FirebaseDatabase

class APIManager : ObservableObject{
    
    @Published var teams: [Team] = []
    @Published var players: [Player] = []
    @Published var user = User(id: "0",email: "", firstname: "",lastname: "",country: "")
    
    private func configuration() -> Firestore{
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        return db
    }
    
    init(){
        fetchTeams()
        fetchUser()
        fetchPlayers()
    }
    
    func fetchTeams(){
        let db = configuration()
        let ref = db.collection("teams")
        ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{
                return
            }
            snapshot.documentChanges.forEach{
            diff in
                if(diff.type == .added){
                    let data = diff.document.data()
                    
                    let team_name = data["team_name"] as? String ?? ""
                    let year_created_at = data["year_created_at"] as? Int ?? 0
                    let id = self.teams.count
                    
                    let team = Team(id: id, team_name: team_name, year_created_at: year_created_at)
                    self.teams.append(team)
                }
                if(diff.type == .modified){
                    let data = diff.document.data()
                    
                    
                    let team_name = data["team_name"] as? String ?? ""
                    let year_created_at = data["year_created_at"] as? Int ?? 0
                    
                    for index in 0...self.teams.count {
                        if self.teams[index].team_name == team_name {
                            self.teams[index] = Team(id: index, team_name: team_name, year_created_at: year_created_at)
                            break
                        }
                    }
                }
                if(diff.type == .removed){
                    // todo
                }
            }
        }
    }
    
    func fetchPlayers(){
        let db = configuration()
        let ref = db.collection("players")
        ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{
                return
            }
            snapshot.documentChanges.forEach{
            diff in
                if(diff.type == .added){
                    let data = diff.document.data()
                    
                    let id = self.players.count
                    let full_name = data["full_name"] as? String ?? ""
                    let nick_name = data["nick_name"] as? String ?? ""
                    let birth_date = (data["birth_date"] as? Timestamp ?? Timestamp()).dateValue()
                    let team_name = data["team_name"] as? String ?? ""
                    
                    let player = Player(id: id, full_name: full_name, nick_name: nick_name, birth_date: birth_date, team_name: team_name)
                    self.players.append(player)
                }
                if(diff.type == .modified){
                    
                }
                if(diff.type == .removed){
                    // todo
                }
            }
        }
    }

    func fetchUser(){
        let db = configuration()
        guard Auth.auth().currentUser != nil else {return}
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        ref.getDocument(completion: {
            snapshot, error in
            guard error == nil else{
                return
            }
            if let snapshot = snapshot {
                guard snapshot.data() != nil else {return}
                let data = snapshot.data()!
                
                let id = snapshot.documentID
                let email = data["email"] as? String ?? ""
                let firstname = data["firstname"] as? String ?? ""
                let lastname = data["lastname"] as? String ?? ""
                let county = data["country"] as? String ?? ""
                
                self.user = User(id: id, email : email, firstname: firstname, lastname: lastname, country: county)
            }
        })
    }
    
    func saveTeam(team: Team){
        let db = configuration()
        let ref = db.collection("users").document(team.team_name.lowercased().replacingOccurrences(of: " ", with: "_"))
        
        ref.setData(["id" : teams.count, "team_name" : team.team_name, "year_created_at" : team.year_created_at]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveUser(id: String){
        let db = configuration()
        guard Auth.auth().currentUser != nil else {return}
        let ref = db.collection("users").document(id)
        ref.setData(["email" : user.email, "firstname" : user.firstname, "lastname" : user.lastname, "country" : user.country]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        fetchUser()
    }
    
    func createUser(email: String, password: String, firstname: String, lastname: String, country: String,  completion: @escaping (String) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password){
            result, error in
            guard error == nil else{
                completion(error!.localizedDescription)
                print(error!.localizedDescription)
                return
            }
            self.user = User(id: result!.user.uid, email: email, firstname: firstname, lastname: lastname, country: country)
            self.saveUser(id: result!.user.uid)
        }
    }

    func downImage(player_name: String, completion: @escaping (UIImage) -> Void) {

            let imageRef = Storage.storage()
            let loc = imageRef.reference().child(player_name)
            loc.listAll{(result,error) in
                if error != nil{
                    print("Ooops : ", error!)
                    return
                }
                if let images = result {
                    print("number of Images: ", images.items.count)
                    for item in images.items {
                        print("images url : " , item)
                        item.getData(maxSize: 15 * 1024 * 1024) { data, error in
                            if let error = error {
                                print("\(error)")
                            }
                            DispatchQueue.main.async {
                                if let theData = data, let image = UIImage(data: theData) {
                                    completion(image)
                                }
                            }
                        }
                    }
                }
            }
        }
}

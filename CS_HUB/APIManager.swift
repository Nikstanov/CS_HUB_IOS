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
import Network

class APIManager : ObservableObject{
    
    @Published var teams: [Team] = []
    @Published var players: [Player] = []
    @Published var user = User(id: "0",email: "", firstname: "",lastname: "",country: "")
    @Published var liked_players = Set<String>()
    @Published var reviews:[Review] = []
    
    var PlayersDownloaded = false
    var reviewListener : ListenerRegistration?
    var likesListener : ListenerRegistration?
    
    private func configuration() -> Firestore{
        var db: Firestore!
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        db = Firestore.firestore()
        return db
    }
    
    init(){
        NotificationCenter.default.addObserver(forName: UIApplication.willTerminateNotification, object: nil, queue: .main){
            _ in
            UserDefaults.standard.set(self.players, forKey: "players")
        }
        /*
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                
            }
            else{
                 
            }
        }
         */
        if let savedData = UserDefaults.standard.value(forKey: "players") as? [Player] {
            players = savedData
        }
        
        fetchTeams()
        fetchUser()
        fetchPlayers()
        Auth.auth().addStateDidChangeListener {
            auth, user in
            if user != nil {
                self.fetchUser()
                self.fetchLikedPlayers()
            }
            else{
                self.likesListener?.remove()
            }
        }
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
                    let nationality = data["nationality"] as? String ?? ""
                    
                    let player = Player(id: id, full_name: full_name, nick_name: nick_name, birth_date: birth_date, team_name: team_name, nationality: nationality)
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
    
    func saveUser(newUser : User){
        let db = configuration()
        guard Auth.auth().currentUser != nil else {return}
        let ref = db.collection("users").document(user.id)
        ref.setData(["email" : newUser.email, "firstname" : newUser.firstname, "lastname" : newUser.lastname, "country" : newUser.country]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        fetchUser()
    }
    
    func unfecthLikedPlayers(){
        self.liked_players.removeAll()
        likesListener?.remove()
    }
    
    func fetchLikedPlayers(){
        let db = configuration()
        let userId = Auth.auth().currentUser!.uid
        let ref = db.collection("users").document(userId).collection("liked_players")
        likesListener?.remove()
        likesListener = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{
                return
            }
            snapshot.documentChanges.forEach{
            diff in
                if(diff.type == .added){
                    let team_name = diff.document.documentID
                    self.liked_players.insert(team_name)
                }
                if(diff.type == .modified){
                }
                if(diff.type == .removed){
                    let team_name = diff.document.documentID
                    self.liked_players.remove(team_name)
                }
            }
        }
    }
    
    func savePlayer(player: Player, completion: @escaping (String) -> Void){
        let db = configuration()
        let ref = db.collection("players").document(player.nick_name)
        ref.setData(["birth_date" : player.birth_date, "full_name" : player.full_name, "nationality" : player.nationality, "team_name" : player.team_name, "nick_name": player.nick_name]) { error in
            if let error = error {
                print(error.localizedDescription)
                completion(error.localizedDescription)
                return
            }
            completion("")
        }
    }
    
    func addLike(playerName:String){
        let db = configuration()
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid).collection("liked_players").document(playerName)
        
        ref.setData([:]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func saveComment(text:String, playerName:String){
        let db = configuration()
        let ref = db.collection("players").document(playerName).collection("reviews").document(user.id)
        
        ref.setData(["text":text, "name":(user.firstname + " " + user.lastname)]) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeLike(playerName:String){
        let db = configuration()
        db.collection("users").document(user.id).collection("liked_players").document(playerName).delete()
    }
    
    func unsubscribeReview(){
        reviews.removeAll()
        reviewListener?.remove()
    }
    
    func subscribeReviews(playerName : String){
        reviews.removeAll()
        
        let db = configuration()
        let ref = db.collection("players").document(playerName).collection("reviews")
        reviewListener = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else{
                return
            }
            snapshot.documentChanges.forEach{
            diff in
                if(diff.type == .added){
                    let data = diff.document.data()
                    
                    let text = data["text"] as? String ?? ""
                    let name = data["name"] as? String ?? ""
                    let id = diff.document.documentID
                    
                    let review = Review(id: self.reviews.count,userId:id ,text:text, name: name)
                    self.reviews.append(review)
                }
                if(diff.type == .modified){
                }
                if(diff.type == .removed){
                    let id = diff.document.documentID
                    
                    for index in 0...self.reviews.count {
                        if self.reviews[index].userId == id {
                            self.reviews.remove(at: index)
                            break
                        }
                    }
                }
            }
        }
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
            self.saveUser(newUser: self.user)
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

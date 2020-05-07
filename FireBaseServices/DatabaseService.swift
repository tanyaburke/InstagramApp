//
//  DatabaseService.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

class DatabaseService {
  
  static let itemsCollection = "items" // collection
  static let usersCollection = "users"
  
  
  private let db = Firestore.firestore()
  
  public func createItem(displayName: String,
                         completion: @escaping (Result<String, Error>) -> ()) {
    guard let user = Auth.auth().currentUser else { return }
    
    // generate a document for the "items" collection
    let documentRef = db.collection(DatabaseService.itemsCollection).document()
    
    
    
    db.collection(DatabaseService.itemsCollection)
      .document(documentRef.documentID)
      .setData(["itemId":documentRef.documentID,
                "sellerName": displayName,"sellerId": user.uid
        
      ]) { (error) in
                
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(documentRef.documentID))
      }
    }
    
  }
  
  public func createDatabaseUser(authDataResult: AuthDataResult,
                                 completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let email = authDataResult.user.email else {
      return
    }
    db.collection(DatabaseService.usersCollection)
      .document(authDataResult.user.uid)
      .setData(["email" : email,
                "userId": authDataResult.user.uid]) { (error) in
      
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
  func updateDatabaseUser(displayName: String,
                          photoURL: String,
                          completion: @escaping (Result<Bool, Error>) -> ()) {
    guard let user = Auth.auth().currentUser else { return }
    db.collection(DatabaseService.usersCollection)
      .document(user.uid).updateData(["photoURL" : photoURL,
                                      "displayName" : displayName]) { (error) in
            if let error = error {
              completion(.failure(error))
            } else {
              completion(.success(true))
      }
    }
  }
  
  public func delete(item: Item,
                     completion: @escaping (Result<Bool, Error>) -> ()) {
    db.collection(DatabaseService.itemsCollection).document(item.itemId).delete { (error) in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(true))
      }
    }
  }
  
    
  public func fetchUserItems(userId: String, completion: @escaping (Result<[Item], Error>) -> ()) {
    db.collection(DatabaseService.itemsCollection).whereField(Constants.sellerId, isEqualTo: userId).getDocuments { (snapshot, error) in
      if let error = error {
        completion(.failure(error))
      } else if let snapshot = snapshot {
        let items = snapshot.documents.map { Item($0.data()) }
        completion(.success(items))
      }
    }
  }

}



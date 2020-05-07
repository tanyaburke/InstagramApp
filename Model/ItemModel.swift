//
//  ItemModel.swift
//  InstagramLab
//
//  Created by Tanya Burke on 5/7/20.
//  Copyright © 2020 Tanya Burke. All rights reserved.
//

struct Item {
 
  
  let itemId: String // documentId
  //let listedDate: Date
  let sellerName: String
  let sellerId: String
  let imageURL: String
}

extension Item {
  init(_ dictionary: [String: Any]) {
    
    self.itemId = dictionary["itemId"] as? String ?? "no item id"
    //self.listedDate = dictionary["listedDate"] as? Date ?? Date()
    self.sellerName = dictionary["sellerName"] as? String ?? "no seller name"
    self.sellerId = dictionary["sellerId"] as? String ?? "no seller id"
    self.imageURL = dictionary["imageURL"] as? String ?? "no image url"
  }
}

struct Constants {
    static let sellerId = "sellerId"
}

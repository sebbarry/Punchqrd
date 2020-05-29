//
//  BusinessName.swift
//  QR 2.0
//
//  Created by Sebastian Barry on 5/27/20.
//  Copyright © 2020 Sebastian Barry. All rights reserved.
//

import Foundation

//creating a new business from this class. everytime a user adds a new business, an instance of this object is created.
class BusinessName {
    
    var name : String
    var points : Float
    var code : Int
    
    init(inputName : String?, pointsAdded : Float?, redemptionCode : Int?) {
        self.name = inputName!
        self.code = redemptionCode!
        self.points = pointsAdded!

    }
}

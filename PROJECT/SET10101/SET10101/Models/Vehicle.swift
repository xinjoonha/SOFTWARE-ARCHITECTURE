//
//  Vehicle.swift
//  SET10101
//
//  Created by 신준하 on 11/22/24.
//

import Foundation
import FirebaseFirestore

struct Vehicle: Identifiable, Codable
{
    let id: String
    let coordinates: GeoPoint
    let status: String
}

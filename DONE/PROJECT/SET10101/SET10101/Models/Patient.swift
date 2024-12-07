//
//  Patient.swift
//  SET10101
//
//  Created by 신준하 on 11/22/24.
//

import Foundation
import FirebaseFirestore

struct Patient: Identifiable, Codable
{
    let id: String
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let address: String
}

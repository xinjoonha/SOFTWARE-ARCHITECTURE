//
//  Dispatch.swift
//  SET10101
//
//  Created by 신준하 on 11/22/24.
//

import Foundation
import FirebaseFirestore

struct Dispatch: Identifiable, Codable
{
    let id: String //document ID
    let date: Date
    let patientId: String //patient's ID
    var status: String
    let condition: String
}

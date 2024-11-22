//
//  ContentView.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct ContentView: View
{
    @State private var currentStatus: String = "Available" // Shared status
    
    var body: some View
    {
        TabView
        {
            Status(currentStatus: $currentStatus, communications: Communications())
                .tabItem
                {
                    Image(systemName: "figure.mixed.cardio")
                    Text("Status")
                }
            
            DispatchDetails(currentStatus: $currentStatus)
                .tabItem
                {
                    Image(systemName: "newspaper.fill")
                    Text("Dispatch")
                }

            CalloutUpdate(currentStatus: $currentStatus)
                .tabItem
                {
                    Image(systemName: "square.and.pencil")
                    Text("Update")
                }
        }
    }
}

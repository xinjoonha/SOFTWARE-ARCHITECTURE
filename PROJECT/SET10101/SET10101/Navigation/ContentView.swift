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
            DispatchDetails(currentStatus: $currentStatus)
                .tabItem
                {
                    Image(systemName: "list.dash")
                    Text("Dispatch")
                }

            CalloutUpdate(currentStatus: $currentStatus)
                .tabItem
                {
                    Image(systemName: "square.and.pencil")
                    Text("Update")
                }

            Status(currentStatus: $currentStatus)
                .tabItem
                {
                    Image(systemName: "person")
                    Text("Status")
                }
        }
    }
}

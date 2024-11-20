//
//  ContentView.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct ContentView: View
{
    var body: some View
    {
        TabView
        {
            DispatchDetails()
                .tabItem
                {
                    Image(systemName: "newspaper")
                    Text("Details")
                }

            CalloutUpdate()
                .tabItem
                {
                    Image(systemName: "square.and.pencil")
                    Text("Update")
                }
        }
    }
}

#Preview
{
    ContentView()
}

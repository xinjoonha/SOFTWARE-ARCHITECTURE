//
//  DispatchDetails.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct DispatchDetails: View
{
    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            Text("Dispatch Details")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            HStack
            {
                Text("Patient Name:")
                    .fontWeight(.semibold)
                Text("John Doe")
            }

            HStack
            {
                Text("NHS Number:")
                    .fontWeight(.semibold)
                Text("123456789")
            }

            HStack
            {
                Text("Address:")
                    .fontWeight(.semibold)
                Text("123 Main Street, Edinburgh")
            }

            HStack
            {
                Text("Condition:")
                    .fontWeight(.semibold)
                Text("Chest Pain")
            }

            Spacer()

            Button(action:
            {
                print("Start Rescue button tapped")
                startRescue()
            })
            {
                Text("Start Rescue")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.top, 16)
        }
        .padding()
    }
    
    private func startRescue()
    {
        print("Rescue started")
        // Add backend or database logic here
    }
}

#Preview
{
    DispatchDetails()
}

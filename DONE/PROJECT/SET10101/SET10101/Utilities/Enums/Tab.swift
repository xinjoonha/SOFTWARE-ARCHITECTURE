//
//  Tab.swift
//  SET10101
//
//  Created by 신준하 on 11/20/24.
//

import SwiftUI

struct TabItem: Identifiable
{
    var id = UUID()
    var icon: String
    var tab: Tab
}

var tabItems =
[
    TabItem(icon: "house.fill", tab: .dispatchDetails),
    TabItem(icon: "chart.bar.fill", tab: .calloutUpdate)
]

enum Tab: String
{
    case dispatchDetails
    case calloutUpdate
    case null
}

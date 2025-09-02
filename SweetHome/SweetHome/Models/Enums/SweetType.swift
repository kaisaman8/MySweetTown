//
//  SweetType.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import Foundation

enum SweetType: String, CaseIterable {
    case candy = "candy"
    case chocolate = "chocolate"
    case cookie = "cookie"
    case cake = "cake"
    case icecream = "icecream"
    case donut = "donut"
    case lollipop = "lollipop"
    case gummy = "gummy"
    
    var displayName: String {
        switch self {
        case .candy:
            return "Candy"
        case .chocolate:
            return "Chocolate"
        case .cookie:
            return "Cookie"
        case .cake:
            return "Cake"
        case .icecream:
            return "Ice Cream"
        case .donut:
            return "Donut"
        case .lollipop:
            return "Lollipop"
        case .gummy:
            return "Gummy"
        }
    }
    
    var iconName: String {
        switch self {
        case .candy:
            return "🍬"
        case .chocolate:
            return "🍫"
        case .cookie:
            return "🍪"
        case .cake:
            return "🍰"
        case .icecream:
            return "🍦"
        case .donut:
            return "🍩"
        case .lollipop:
            return "🍭"
        case .gummy:
            return "🐻"
        }
    }
}

enum SweetRarity: String, CaseIterable {
    case common = "common"
    case uncommon = "uncommon"
    case rare = "rare"
    case epic = "epic"
    case legendary = "legendary"
    
    var displayName: String {
        switch self {
        case .common:
            return "Common"
        case .uncommon:
            return "Uncommon"
        case .rare:
            return "Rare"
        case .epic:
            return "Epic"
        case .legendary:
            return "Legendary"
        }
    }
    
    var color: String {
        switch self {
        case .common:
            return "gray"
        case .uncommon:
            return "green"
        case .rare:
            return "blue"
        case .epic:
            return "purple"
        case .legendary:
            return "orange"
        }
    }
    
    var probability: Double {
        switch self {
        case .common:
            return 0.50  // 50%
        case .uncommon:
            return 0.30  // 30%
        case .rare:
            return 0.15  // 15%
        case .epic:
            return 0.04  // 4%
        case .legendary:
            return 0.01  // 1%
        }
    }
}

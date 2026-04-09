//
//  AlarmItem.swift
//  Frequence
//
//  Created by kasra zarif yazdian akbari on 01/04/26.
//

import Foundation

struct AlarmItem: Identifiable, Hashable {
    let id = UUID()
    var time: Date
    var name: String
    var schedule: Set<Int>
    var snoozeTime: Int
    var isActive: Bool
    
    // THIS is where you will store the name of the specific .metal shader for this card
    var shaderName: String
}

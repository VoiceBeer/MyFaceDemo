//
//  FacialExpression.swift
//  MyFaceDemo
//
//  Created by VoiceBeer on 2017/9/4.
//  Copyright © 2017年 VoiceBeer. All rights reserved.
//

import Foundation

// UI-independent representation of a facial expression

struct FacialExpression
{
    enum Eyes: Int {
        case open
        case closed
        case squinting
    }
    
    enum Mouth: Int {
        case frown
        case smirk
        case neutral
        case grin
        case smile
        
        var sadder: Mouth {
            return Mouth(rawValue: rawValue - 1) ?? .frown
        }
        var happier: Mouth {
            return Mouth(rawValue: rawValue + 1) ?? .smile
        }
    }
    
    let eyes: Eyes
    let mouth: Mouth
    
    var sadder: FacialExpression {
        return FacialExpression(eyes: self.eyes, mouth: self.mouth.sadder)
    }
    var happier: FacialExpression {
        return FacialExpression(eyes: self.eyes, mouth: self.mouth.happier)
    }
    
    
    
}

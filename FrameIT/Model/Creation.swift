//
//  Creation.swift
//  FrameIT
//
//  Created by Sara Babaei on 3/10/20.
//  Copyright © 2020 Sara Babaei. All rights reserved.
//

import Foundation
import UIKit

class Creation{
    var image: UIImage
    var colorSwatch: ColorSwatch
    
    static var defaultImage: UIImage{
        return UIImage.init(named: "FrameIT-placeholder")!
    }
    
    static var defaultColorSwatch: ColorSwatch{
        return ColorSwatch.init(caption: "Simoly Yellow", color: .yellow)
    }
    
    init() {
        image = Creation.defaultImage
        colorSwatch = Creation.defaultColorSwatch
    }
    
    convenience init(colorSwatch: ColorSwatch?){
        self.init()
        if let userColorSwatch = colorSwatch {
            self.colorSwatch = userColorSwatch
        }
    }
    
    func reset(colorSwatch: ColorSwatch?){
        image = Creation.defaultImage
        if let userColorSwatch = colorSwatch{
            self.colorSwatch = userColorSwatch
        }
        else{
            self.colorSwatch = Creation.defaultColorSwatch
        }
    }
}

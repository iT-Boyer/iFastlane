//
//  File.swift
//  
//
//  Created by boyer on 2022/10/16.
//

import Foundation
import Fastlane
//https://appetize.io
extension Fastfile
{
    
    func appetizeLane(path:String){
        
        appetize(apiToken: "tok_wkvivs35obwvkt4pmpyaavj6gu",path: .userDefined(path))
    }
}

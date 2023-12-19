//
//  ImmersiveModel.swift
//  Marvel
//
//  Created by  吴 熠 on 2023/12/18.
//

import Foundation
import Observation
import SwiftUI

enum FlowState {
    case none
    case intro
    case immersive
}

@Observable
class ImmersiveViewModel {
    var flowState = FlowState.none
    
    func reset() {
        flowState = FlowState.none
    }
}




enum ImmersiveState {
    case open
    case dismiss
}

@Observable
class ImmersiveStateModel {
    var immersiveState = ImmersiveState.dismiss
    
    
}

//
//  AnimationPlayTool.swift
//  Marvel
//
//  Created by  吴 熠 on 2023/12/17.
//

import Foundation
import RealityKit
import RealityKitContent

struct AnimationPlayTool {
    static func playAnimations(rootEntity: Entity, targetEntityName: String, repeatCount: Int = 0) async {
        let sceneEntity = await rootEntity.findEntity(named: targetEntityName)
        guard let animationResource = await sceneEntity?.availableAnimations.first else { return }
        if repeatCount == 0 {
            await sceneEntity?.playAnimation(animationResource.repeat())
        } else {
            await sceneEntity?.playAnimation(animationResource.repeat(count: repeatCount))
        }
    }
}


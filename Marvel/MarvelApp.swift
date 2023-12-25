//
//  MarvelApp.swift
//  Marvel
//
//  Created by  吴 熠 on 2023/12/17.
//

import SwiftUI

@main
struct MarvelApp: App {
    @State private var viewModel = ImmersiveViewModel()
    @State private var immersiveStateModel = ImmersiveStateModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(immersiveStateModel)
        }.windowStyle(.plain)

        ImmersiveSpace(id: aiBotScene) {
            ImmersiveView()
                .environment(viewModel)
                .environment(immersiveStateModel)
            
        }
        
        WindowGroup(id: heroGroupScene) {
            HeroGroupView()
        }
    }
}

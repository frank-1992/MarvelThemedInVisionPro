//
//  ContentView.swift
//  Marvel
//
//  Created by  吴 熠 on 2023/12/17.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(ImmersiveStateModel.self) private var immersiveStateModel

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
//    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State var labelText = "Show AI Assistant"
    
    var body: some View {
        @Bindable var immersiveStateModel = immersiveStateModel
        VStack {
            Model3D(named: "Scene", bundle: realityKitContentBundle)
                .padding(.top, 100)

            Text("Hello, I'm Javris!")
                .padding(.bottom, 50)


            Button(action: {
                if immersiveStateModel.immersiveState == .open {
                    immersiveStateModel.immersiveState = .dismiss
                } else {
                    immersiveStateModel.immersiveState = .open
                }
            }) {
                Text(labelText)
            }
        }
        .padding()
        .onChange(of: immersiveStateModel.immersiveState) { _, newValue in
            Task {
                if newValue == .open {
                    switch await openImmersiveSpace(id: aiBotScene) {
                    case .opened:
                        labelText = "Dismiss AI Assistant"
                        immersiveStateModel.immersiveState = .open
                    case .error, .userCancelled:
                        fallthrough
                    @unknown default:
                        labelText = "Show AI Assistant"
                        immersiveStateModel.immersiveState = .dismiss
                    }
                } else {
                    labelText = "Show AI Assistant"
                    immersiveStateModel.immersiveState = .dismiss
                }
            }
        }
    }
    
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(ImmersiveStateModel())
}

//
//  ImmersiveView.swift
//  Marvel
//
//  Created by  吴 熠 on 2023/12/17.
//

import SwiftUI
import RealityKit
import RealityKitContent
import Combine

struct ImmersiveView: View {
    
    @Environment(ImmersiveStateModel.self) private var immersiveStateModel
    @Environment(ImmersiveViewModel.self) private var viewModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    @State public var showAttachmentButtons = false
    
    @State private var inputText = ""
    @State private var showTextField = false
    @State private var rootRealityContent: RealityViewContent? = nil
    
    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var immersiveStateModel = immersiveStateModel
        RealityView { content, attachments in
            if let scene = try? await Entity(named: aiBotScene, in: realityKitContentBundle) {
                let characterEntity = AnchorEntity(.head)
                characterEntity.position = [0.70, 0, -1]
                let radians = -40 * Float.pi / 180
                ImmersiveView.rotateEntityAroundYAxis(entity: characterEntity, angle: radians)
                characterEntity.addChild(scene)
                content.add(characterEntity)
                rootRealityContent = content
                await AnimationPlayTool.playAnimations(rootEntity: scene, targetEntityName: "SkinnedMeshes", repeatCount: 1)
                withAnimation(.easeInOut(duration: 0.3)) {
                    showAttachmentButtons = true
                }
                ImmersiveView.showAttachIntroduction(with: characterEntity, attachments: attachments)
                viewModel.flowState = .intro
            }
        } update: { _, _ in
            
        } attachments: {
            Attachment(id: "interaction") {
                VStack {
                    Text(inputText)
                        .frame(maxWidth: 600, alignment: .leading)
                        .font(.extraLargeTitle2)
                        .fontWeight(.regular)
                        .padding(40)
                        .glassBackgroundEffect()
                    if showAttachmentButtons {
                        HStack(spacing: 20) {
                            Button(action: {
                                viewModel.flowState = .immersive
                            }) {
                                Text("Let's start")
                                    .font(.largeTitle)
                                    .fontWeight(.regular)
                                    .padding()
                                    .cornerRadius(8)
                            }
                            .padding()
                            .buttonStyle(.bordered)
                            
                            Button(action: {
                                viewModel.flowState = .none
                            }) {
                                Text("No")
                                    .font(.largeTitle)
                                    .fontWeight(.regular)
                                    .padding()
                                    .cornerRadius(8)
                            }
                            .padding()
                            .buttonStyle(.bordered)
                        }
                        .glassBackgroundEffect()
                        .opacity(showAttachmentButtons ? 1 : 0)
                    }
                }
                .opacity(showTextField ? 1 : 0)
            }
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded {
            _ in
            if viewModel.flowState == .none {
                viewModel.flowState = .intro
            }
        })
        .onChange(of: viewModel.flowState) { oldValue, newValue in
            switch newValue {
            case .none:
                dismissImmersiveView()
            case .intro:
                playIntroSequence()
            case .immersive:
                showHeroStage()
            }
        }
        .onChange(of: immersiveStateModel.immersiveState) { oldValue, newValue in
            switch newValue {
            case .dismiss:
                dismissImmersiveView()
            case .open:
                break
            }
        }
    }
    //Hello, I am Jarvis, your AI assistant. Do you need to start the service today?
    
    func showHeroStage()  {
        
        let entity =  AnchorEntity()
        let boxMesh =  MeshResource.generateSphere(radius: 0.5)
        
        let material = SimpleMaterial(color: .blue, isMetallic: true)
        let boxEntity =  ModelEntity(mesh: boxMesh, materials: [material])
        entity.addChild(boxEntity)
        rootRealityContent?.add(boxEntity)
        
        Task {
            if let heroContainerEntity = try? await Entity(named: heroContainerScene, in: realityKitContentBundle) {
                rootRealityContent?.add(heroContainerEntity)
            }
        }
    }
    
    func dismissImmersiveView() {
        Task {
            showAttachmentButtons = false
            inputText = ""
            showTextField = false
            viewModel.reset()
            immersiveStateModel.immersiveState = .dismiss
            await dismissImmersiveSpace()
        }
    }
    
    func playIntroSequence() {
        Task {
            // show dialog box
            if !showTextField {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showTextField.toggle()
                }
            }
            let texts = [
                "Hello, I am Jarvis. \nYour AI assistant. Do you need to start the service today?",
            ]

            await animatePromptText(text: texts[0])

            withAnimation(.easeInOut(duration: 0.3)) {
                showAttachmentButtons = true
            }

            await waitForButtonTap(using: tapSubject)

            withAnimation(.easeInOut(duration: 0.3)) {
                showAttachmentButtons = false
            }

            Task {
                await animatePromptText(text: texts[1])
            }
        }
    }
    
    
    func animatePromptText(text: String) async {
        inputText = ""
        let words = text.split(separator: " ")
        for word in words {
            inputText.append(word + " ")
            let milliseconds = (1 + UInt64.random(in: 0 ... 1)) * 100
            try? await Task.sleep(for: .milliseconds(milliseconds))
        }
    }
    
    static func showAttachIntroduction(with parent: Entity, attachments: RealityViewAttachments) {
        guard let attachmentEntity = attachments.entity(for: "interaction") else { return }
        attachmentEntity.position = SIMD3<Float>(0, 0.35, 0)
        let radians = 40 * Float.pi / 180
        ImmersiveView.rotateEntityAroundYAxis(entity: attachmentEntity, angle: radians)
        parent.addChild(attachmentEntity)
    }
    
    let tapSubject = PassthroughSubject<Void, Never>()
    @State var cancellable: AnyCancellable?
    func waitForButtonTap(using buttonTapPublisher: PassthroughSubject<Void, Never>) async {
        await withCheckedContinuation { continuation in
            let cancellable = tapSubject.first().sink(receiveValue: { _ in
                continuation.resume()
            })
            self.cancellable = cancellable
        }
    }
    
    static func rotateEntityAroundYAxis(entity: Entity, angle: Float) {
        // Get the current transform of the entity
        var currentTransform = entity.transform

        // Create a quaternion representing a rotation around the Y-axis
        let rotation = simd_quatf(angle: angle, axis: [0, 1, 0])

        // Combine the rotation with the current transform
        currentTransform.rotation = rotation * currentTransform.rotation

        // Apply the new transform to the entity
        entity.transform = currentTransform
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
        .environment(ImmersiveViewModel())
        .environment(ImmersiveStateModel())
}

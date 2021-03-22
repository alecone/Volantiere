//
//  VolantiereApp.swift
//  Volantiere
//
//  Created by Alexandru Cone on 24/02/21.
//

import SwiftUI

class GlobalIP: ObservableObject {
    @Published var ip: String = ""
    @Published var loaded: Bool = false
}

@main
struct VolantiereApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject var raspberries = Raspberries()
    @StateObject var IP = GlobalIP()
    var socket: TCPClient = TCPClient()
    
    var body: some Scene {
        WindowGroup {
            LogInView(socket: socket)
                .environmentObject(raspberries)
                .environmentObject(IP)
        }
        .onChange(of: scenePhase) { (newScenePhase) in
            switch newScenePhase {
            case .active:
                print("scene is now active!")
            case .inactive:
                print("scene is now inactive!")
            case .background:
                print("scene is now in the background!")
            @unknown default:
                print("Apple must have added something new!")
            }
        }
    }
}

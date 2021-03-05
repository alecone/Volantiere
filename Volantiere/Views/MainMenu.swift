//
//  MainMenu.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

struct MainMenu: View {
    @State private var goToLogIn = false
    var body: some View {
        NavigationView {
            Text("MainMenu")
                .toolbar {
                    Button(action: {
                        print("Going to disconnect from server and try go go to LogInView")
                        goToLogIn = true
                    }) {
                        Image(systemName: "pip.exit")
                    }
                }
        }
    }
}

struct MainMenu_Previews: PreviewProvider {
    static var previews: some View {
        MainMenu()
    }
}

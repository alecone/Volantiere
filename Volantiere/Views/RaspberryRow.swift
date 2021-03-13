//
//  RaspberryRow.swift
//  Volantiere
//
//  Created by Alexandru Cone on 06/03/21.
//

import SwiftUI

struct RaspberryRow: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var raspberries: Raspberries
    @EnvironmentObject var IP: GlobalIP
    var raspberry: Raspberry
    
    @State private var showDeleteDialog: Bool = false
    @State private var navigateToLogIn: Bool = false
    @State private var editedName: String?
    
    var body: some View {
        HStack {
            Button(action: {}, label: {
                Text(raspberry.ip)
            })
            .onTapGesture(perform: setIPFromRecent)
            Spacer()
            Button(action: {}) {
                Image(systemName: "xmark.bin")
            }
            .onTapGesture(perform: deleteButtonPressed)
            .alert(isPresented: self.$showDeleteDialog, content: {
                deleteRaspberry(toDelete: raspberry)
            })
        }
    }

    func deleteRaspberry(toDelete raspberry: Raspberry) -> Alert {
        // Show alert in order to ask if user is sure
        func delete(_ raspberry: Raspberry) -> Void {
            print("Going to delete \(raspberry.name)")
            JSONHelper.deleteRaspberry(to: raspberry)
            
            // Update list
            raspberries.raspberries = JSONHelper.loadRaspberries()
        }
        
        return Alert(title: Text("Are you sure to delete it?"), primaryButton: .default(Text("Yes"), action: {delete(raspberry)}), secondaryButton: .cancel())
    }
    
    func setIPFromRecent() -> Void {
        IP.ip = raspberry.ip
        IP.loaded = true
        isPresented = false
    }
    
    func deleteButtonPressed() -> Void {
        self.showDeleteDialog = true
    }
}

//struct RaspberryRow_Previews: PreviewProvider {
//    static var previews: some View {
//        RaspberryRow(raspberry: Raspberry(id: UUID(), name: "Prova", ip: "192.168.1.1"))
//    }
//}

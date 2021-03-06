//
//  RecentRaspberries.swift
//  Volantiere
//
//  Created by Alexandru Cone on 26/02/21.
//

import SwiftUI

struct RecentRaspberries: View {
    @State private var raspies = JSONHelper.loadRaspberries()
    @State private var showDeleteDialog: Bool = false
    @State private var showEditDialog: Bool = false
    @State private var editedName: String?
    private var raspberryToEdit: Raspberry?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(raspies) { name in
                    Section(header: Text(name.name)) {
                        HStack {
                            Text(name.ip)
                            Spacer()
                            Button(action: {
                                self.showEditDialog = true
                            }) {
                                Image(systemName: "pencil.circle")
                            }
                            .textFieldAlert(isPresented: self.$showEditDialog, content: editRaspberryName)
                            Button(action: {
                                self.showDeleteDialog = true
                            }) {
                                Image(systemName: "xmark.bin")
                            }
                            .alert(isPresented: self.$showDeleteDialog, content: {
                                deleteRaspberry(toDelete: name)
                            })
                        }
                    }
                }
                
            }
            .navigationBarTitle("Recent Raspberries")
            .listStyle(GroupedListStyle())
        }
    }
    
    func nameReady() -> Void {
        // Delete the older and save this new one
        print("Raspberry name will change from \(self.raspberryToEdit?.name ?? "NOT SELECTED") to \(self.$editedName)")
    }
    
    func editRaspberryName() -> TextFieldAlert {
        // Call alertTextField
        return TextFieldAlert(title: "Rename Raspberry", message: "Insert new name", text: self.$editedName, isPresented: self.$showEditDialog, caller: nameReady)
    }
    
    func deleteRaspberry(toDelete raspberry: Raspberry) -> Alert {
        // Show alert in order to ask if user is sure
        func delete(_ raspberry: Raspberry) -> Void {
            print("Going to delete \(raspberry.name)")
            JSONHelper.deleteRaspberry(to: raspberry)
            
            // Update list
            self.raspies = JSONHelper.loadRaspberries()
        }
        
        return Alert(title: Text("Are you sure to delete it?"), primaryButton: .default(Text("Yes"), action: {delete(raspberry)}), secondaryButton: .cancel())
    }
}

struct RecentRaspberries_Previews: PreviewProvider {
    static var previews: some View {
        RecentRaspberries()
    }
}

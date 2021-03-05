//
//  JSONHelper.swift
//  VolantiereMD
//
//  Created by Alexandru Cone on 14/02/21.
//

import Foundation

/// Raspberry struct
struct Raspberry: Hashable, Codable, Identifiable {
    var id: UUID
    var name: String
    var ip: String
}

let fileName: String = "saved_raspberry.json"

/// Helper for saving Raspberry devices into json file
struct JSONHelper {
    
    /// Checks if document exists in Documents path
    /// - Returns: Bool
    ///     - True: file already exists
    ///     - False: file does not exist
    static func doesDocumentDirectoryFilesExist() -> Bool{
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        var ret: Bool = false

        if let url = documentsURL {
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: url.path)
                for file in contents {
                    if file == fileName{
                        ret = true
                        break
                    }
                }
            } catch {
                print("Could not retrieve contents of the document directory.")
            }
        }
        return ret
    }
    
    /// Load save raspberry list from file
    /// - Returns: list of Raspberry struct
    static func loadRaspberries() -> [Raspberry]{
        let data: Data
        var loadedData: [Raspberry] = [Raspberry]()

        let exist: Bool = doesDocumentDirectoryFilesExist()
        if !exist {
            let raspsEmpty: [Raspberry] = [Raspberry]()
            saveRaspberries(save: raspsEmpty)
        }
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let url = documentsURL {
            do {
                let srcURL = url.appendingPathComponent(fileName)
                data = try Data(contentsOf: srcURL)
            } catch {
                fatalError("Couldn't load \(fileName) from main bundle:\n\(error)")
            }

            do {
                let decoder = JSONDecoder()
                loadedData = try decoder.decode([Raspberry].self, from: data)
            } catch {
                fatalError("Couldn't parse \(fileName) as \([Raspberry].self):\n\(error)")
            }
        }
        return loadedData
    }
    
    /// Saves a list of Raspberry struct into file
    /// - Parameter raspberries: list of raspberries
    /// - Returns: Void
    static func saveRaspberries(save raspberries: [Raspberry]) -> Void {

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

        if let url = documentsURL {
            let fileURL = url.appendingPathComponent(fileName)
            do {
                let encoder = JSONEncoder()
                try encoder.encode(raspberries).write(to: fileURL)
            } catch {
                fatalError("Couldn't save into \(fileName) array \([Raspberry].self):\n\(error)")
            }
        }
    }
    
    
    /// Checks if a Raspberry is alredy present in known raspberry file
    /// - Parameter raspberry: raspberry to check if already saved in file
    /// - Returns: Bool
    static func raspberryAlreadySaved(check raspberry: Raspberry) -> Bool {
        
        let savedRapberries: [Raspberry] = loadRaspberries()
        var alreadySaved: Bool = false
        
        for rasp in savedRapberries {
            if rasp.ip == raspberry.ip {
                alreadySaved = true
                break
            }
        }
        
        return alreadySaved
    }
    
    /// Saves a Raspberry device to file
    /// - Parameter raspberry: raspberry to save
    /// - Returns: Void
    static func saveRaspberry(new raspberry: Raspberry) -> Void {
        
        var savedRapberries: [Raspberry] = loadRaspberries()
        var alreadySaved: Bool = false
        
        for rasp in savedRapberries {
            if rasp.ip == raspberry.ip {
                alreadySaved = true
                break
            }
        }
        if !alreadySaved{
            savedRapberries.append(raspberry)
            saveRaspberries(save: savedRapberries)
        }
    }
    
    /// Deletes a Raspberry from file
    /// - Parameter delete: raspberry to delete
    /// - Returns: Void
    static func deleteRaspberry(to delete: Raspberry) -> Void {
        
        var savedRaspberries: [Raspberry] = loadRaspberries()
        var match: Bool = false
        
        if savedRaspberries.count > 0 {
            var index: Int = 0
            for (i, raspberry) in savedRaspberries.enumerated() {
                if raspberry.ip == delete.ip {
                    match = true
                    index = i
                    break
                }
            }
            if match {
                savedRaspberries.remove(at: index)
                saveRaspberries(save: savedRaspberries)
            }
        }
    }
}

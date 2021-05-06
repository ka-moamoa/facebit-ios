//
//  ShareUtil.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//

import Foundation
import UIKit

class ShareUtil {
    static func saveJSON<T: Codable>(from obj: T, fileName: String) -> URL? {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .millisecondsSince1970
            
            let json = try encoder.encode(obj)
            let jsonString = String(data: json, encoding: .utf8)
            
            if let dbPath = AppDatabase.dbFolderPath {
                let path = dbPath.appendingPathComponent("\(fileName).json")
                
                try jsonString?.write(
                    to: path,
                    atomically: true,
                    encoding: .utf8
                )
                
                return path
            }
            
            
        } catch {
            GeneralLogger.error("unable to save JSON for \(T.self): \(error.localizedDescription)")
        }
        
        return nil
    }
    
    static func share(path: URL) {
        #if targetEnvironment(macCatalyst)
            GeneralLogger.info("opening \(path.absoluteString) in macOS")
            UIApplication.shared.open(path)

    
        #elseif os(iOS) || os(watchOS) || os(tvOS)
            GeneralLogger.info("sharing \(path.absoluteString) from iOS")
            let av = UIActivityViewController(
                activityItems: [path],
                applicationActivities: nil
            )
            UIApplication
                .shared
                .windows.first?
                .rootViewController?
                .present(av, animated: true, completion: nil)
        #else
        GeneralLogger.error("Sharing \(path.absoluteString) in unhandled OS!")
        #endif
    }
}

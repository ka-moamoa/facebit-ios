//
//  ShareUtil.swift
//  FaceBit Companion
//
//  Created by blaine on 3/17/21.
//
//  @copyright Copyright (c) 2022 Ka Moamoa
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the license.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

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

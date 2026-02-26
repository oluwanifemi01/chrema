//
//  Chrema_AppApp.swift
//  Chrema
//
//  Created by Oluwanifemi Oloyede on 2/18/26.
//

import SwiftUI
import Firebase

@main
struct Chrema: App {
    // Register app delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

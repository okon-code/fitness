//
//  ShareSheet.swift
//  Fitnes
//
//  Nativní systémové menu UIActivityViewController pro sdílení aplikace a tréninků s přáteli.
//

import SwiftUI
import UIKit

/// UIViewControllerRepresentable obalující nativní systémový dialog UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    var excludedActivityTypes: [UIActivity.ActivityType]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Není potřeba dynamická aktualizace
    }
}

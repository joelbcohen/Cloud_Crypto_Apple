//
//  CloudCryptoComplication.swift
//  Cloud Crypto Watch App
//
//  Created by Joel Cohen on 11/20/25.
//

import SwiftUI
import WidgetKit

// MARK: - Complication Entry

struct CloudCryptoComplicationEntry: TimelineEntry {
    let date: Date
    let isRegistered: Bool
}

// MARK: - Complication Timeline Provider

struct CloudCryptoComplicationProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> CloudCryptoComplicationEntry {
        CloudCryptoComplicationEntry(date: Date(), isRegistered: false)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CloudCryptoComplicationEntry) -> Void) {
        let entry = CloudCryptoComplicationEntry(
            date: Date(),
            isRegistered: loadRegistrationStatus()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CloudCryptoComplicationEntry>) -> Void) {
        let currentDate = Date()
        let isRegistered = loadRegistrationStatus()
        
        let entry = CloudCryptoComplicationEntry(
            date: currentDate,
            isRegistered: isRegistered
        )
        
        // Update timeline once per hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
    
    private func loadRegistrationStatus() -> Bool {
        return UserDefaults.standard.bool(forKey: "is_registered")
    }
}

// MARK: - Complication View

struct CloudCryptoComplicationView: View {
    let entry: CloudCryptoComplicationEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCircular:
            circularView
        case .accessoryCorner:
            cornerView
        case .accessoryInline:
            inlineView
        case .accessoryRectangular:
            rectangularView
        default:
            circularView
        }
    }
    
    // MARK: - Circular Small
    
    private var circularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            VStack(spacing: 2) {
                Image(systemName: entry.isRegistered ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.system(size: 20))
                    .foregroundColor(entry.isRegistered ? .green : .gray)
                
                Text(entry.isRegistered ? "REG" : "---")
                    .font(.system(size: 10, weight: .bold))
            }
        }
    }
    
    // MARK: - Corner
    
    private var cornerView: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            Text(entry.isRegistered ? "REG" : "---")
                .font(.system(size: 14, weight: .bold))
                .widgetLabel {
                    Image(systemName: "bitcoinsign.circle")
                }
        }
    }
    
    // MARK: - Inline
    
    private var inlineView: some View {
        HStack(spacing: 4) {
            Image(systemName: "bitcoinsign.circle")
            Text(entry.isRegistered ? "Registered" : "Not Registered")
        }
    }
    
    // MARK: - Rectangular
    
    private var rectangularView: some View {
        ZStack {
            AccessoryWidgetBackground()
            
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cloud Crypto")
                        .font(.system(size: 12, weight: .semibold))
                    
                    Text(entry.isRegistered ? "Registered" : "Not Registered")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: entry.isRegistered ? "checkmark.circle.fill" : "xmark.circle")
                    .font(.system(size: 20))
                    .foregroundColor(entry.isRegistered ? .green : .gray)
            }
            .padding(8)
        }
    }
}

// MARK: - Widget Configuration

// @main - Commented out because this should be in a separate Widget Extension target
// If you have a Widget Extension target, move this file there and uncomment @main
struct CloudCryptoComplication: Widget {
    let kind: String = "CloudCryptoComplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: CloudCryptoComplicationProvider()
        ) { entry in
            CloudCryptoComplicationView(entry: entry)
        }
        .configurationDisplayName("Cloud Crypto")
        .description("Shows your registration status")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

// MARK: - Preview

#Preview(as: .accessoryCircular) {
    CloudCryptoComplication()
} timeline: {
    CloudCryptoComplicationEntry(date: Date(), isRegistered: true)
    CloudCryptoComplicationEntry(date: Date(), isRegistered: false)
}

import WidgetKit
import SwiftUI
import Intents

/// SnapBeam Widget Provider
/// Displays the latest shared photo from your loved ones
struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), photoData: nil, caption: "Waiting for photo...")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, photoData: nil, caption: "Waiting for photo...")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get data from shared UserDefaults
        let defaults = UserDefaults(suiteName: "group.app.snapbeam.photo")
        let photoBase64 = defaults?.string(forKey: "last_photo")
        let caption = defaults?.string(forKey: "last_caption") ?? "Waiting for photo..."
        
        // Decode base64 photo
        var photoData: Data? = nil
        if let base64 = photoBase64, let data = Data(base64Encoded: base64) {
            photoData = data
        }
        
        // Create entry
        let entry = SimpleEntry(
            date: Date(),
            configuration: configuration,
            photoData: photoData,
            caption: caption
        )
        
        // Schedule next update in 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

/// Widget timeline entry
struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let photoData: Data?
    let caption: String
}

/// Widget view
struct SnapBeamWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                if let photoData = entry.photoData,
                   let uiImage = UIImage(data: photoData) {
                    // Show photo
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } else {
                    // Placeholder
                    LinearGradient(
                        colors: [Color(red: 0.388, green: 0.4, blue: 0.945), Color(red: 0.925, green: 0.282, blue: 0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                        Text("Waiting for photo...")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.top, 8)
                    }
                }
                
                // Caption overlay
                VStack {
                    Spacer()
                    HStack {
                        Text(entry.caption)
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Spacer()
                    }
                    .padding(12)
                    .background(
                        LinearGradient(
                            colors: [Color.black.opacity(0.6), Color.clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                }
            }
        }
    }
}

/// Main widget configuration
struct SnapBeamWidget: Widget {
    let kind: String = "SnapBeamWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SnapBeamWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SnapBeam")
        .description("See the latest shared photo from your loved ones.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

/// Widget preview for widget gallery
struct SnapBeamWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SnapBeamWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                photoData: nil,
                caption: "Waiting for photo..."
            ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            SnapBeamWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                photoData: nil,
                caption: "Waiting for photo..."
            ))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
            SnapBeamWidgetEntryView(entry: SimpleEntry(
                date: Date(),
                configuration: ConfigurationIntent(),
                photoData: nil,
                caption: "Waiting for photo..."
            ))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}

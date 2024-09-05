//
//  PhotoGalleryView.swift
//  Tracking Transience
//
//  Created by James Edmond on 9/4/24.
//

import SwiftUI
import SwiftData

struct PhotoGalleryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Photo.timestamp, order: .reverse) private var photos: [Photo]

    @State private var currentWeekPhotos: [Photo] = []
    @State private var timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 5), spacing: 10) {
                ForEach(currentWeekPhotos.prefix(30), id: \.id) { photo in
                    Image(uiImage: UIImage(data: photo.image)!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width / 5 - 10, height: geometry.size.width / 5 - 10)
                        .clipped()
                }
            }
            .padding()
            .background(Color.black)
            .onReceive(timer) { _ in
                // Change to the next set of photos every 5 seconds
                updateWeekPhotos()
            }
        }
    }

    private func updateWeekPhotos() {
        // Group photos by week and update `currentWeekPhotos` accordingly
        let groupedByWeek = Dictionary(grouping: photos) { Calendar.current.component(.weekOfYear, from: $0.timestamp) }
        if let currentWeek = groupedByWeek.keys.sorted(by: >).first {
            currentWeekPhotos = groupedByWeek[currentWeek] ?? []
        }
    }
}

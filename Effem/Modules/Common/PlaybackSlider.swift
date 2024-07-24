//
//  PlaybackSlider.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/1/23.
//

import SwiftUI

struct PlaybackSlider: View {
    @Environment(MediaPlaybackManager.self) private var mediaPlaybackManager
    
    @State var height: Double = 5
    @State var lastCoordinateValue: Double = 0.0
    private var sliderRange: ClosedRange<Double> = 0...1
    
    var body: some View {
        @Bindable var mediaPlaybackManager = mediaPlaybackManager
        
        GeometryReader { geometry in
            let minValue = geometry.size.width * 0.015
            let maxValue = geometry.size.width
            
            let scaleFactor = (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound)
            let lower = sliderRange.lowerBound
            let sliderVal = (mediaPlaybackManager.progress - lower) * scaleFactor + minValue
            
            ZStack {
                Capsule()
                    .foregroundStyle(.gray)
                    .frame(width: geometry.size.width, height: height)
                
                HStack {
//                    // TODO: corners should be all when the progress is near the end
                    UnevenRoundedRectangle(cornerRadii: RectangleCornerRadii(topLeading: height / 2, bottomLeading: height / 2, bottomTrailing: height / 2, topTrailing: height / 2), style: .circular)
                        .foregroundStyle(.white)
                        .frame(width: sliderVal, height: height)
                    
                    Spacer()
                }
            }
            .offset(y: (geometry.size.height - height) / 4)
            .frame(height: geometry.size.height * 2)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in
                        withAnimation { height = 5 }
                        mediaPlaybackManager.userStoppedMovingSlider()
                    }
                    .onChanged { v in
                        withAnimation { height = 12 }
                        mediaPlaybackManager.userIsMovingSlider()
                        
                        if (abs(v.translation.width) < 0.1) {
                            self.lastCoordinateValue = sliderVal
                        }
                        if v.translation.width > 0 {
                            let nextCoordinateValue = min(maxValue, self.lastCoordinateValue + v.translation.width)
                            mediaPlaybackManager.progress = ((nextCoordinateValue - minValue) / scaleFactor)  + lower
                        } else {
                            let nextCoordinateValue = max(minValue, self.lastCoordinateValue + v.translation.width)
                            mediaPlaybackManager.progress = ((nextCoordinateValue - minValue) / scaleFactor) + lower
                        }
                    }
            )
        }
        .frame(height: 24)
        .accessibilityRepresentation { Slider(value: $mediaPlaybackManager.progress)}
        .onAppear { mediaPlaybackManager.listenToProgress() }
        .onDisappear { mediaPlaybackManager.stopListeningToProgress() }
    }
}

#Preview {
    ZStack {
        Color.black
        PlaybackSlider()
            .environment(MediaPlaybackManager.shared)
    }
}

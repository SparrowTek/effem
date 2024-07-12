//
//  CommonImage.swift
//  Effem
//
//  Created by Thomas Rademaker on 11/2/23.
//

import SwiftUI

enum ImageType {
    case url(url: String?, sfSymbol: String?)
    case asset(Image)
    case diskURL(path: URL, sfSymbol: String?)
    case data(Data?, sfSymbol: String?)
}

struct CommonImage: View {
    let image: ImageType
    
    var body: some View {
        switch image {
        case .url(let imageURL, let symbol):
            AsyncImage(url: URL(string: imageURL ?? ""), content: {
                $0
                    .resizable()
                    .scaledToFill()
            }, placeholder: {
                CommonSystemImage(systemName: symbol)
            })
        case .asset(let image):
            image
                .resizable()
        case .diskURL(let path, let symbol):
            if let imageData = try? Data(contentsOf: path),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                CommonSystemImage(systemName: symbol)
            }
        case .data(let data, let symbol):
            if let data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
            } else {
                CommonSystemImage(systemName: symbol)
            }
        }
    }
}

fileprivate struct CommonSystemImage: View {
    var systemName: String?
    
    var body: some View {
        if let systemName {
            Text(" ")
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity)
                .background(.white)
                .overlay(
                    Image(systemName: systemName)
                        .resizable()
                        .scaledToFit()
                        .padding()
                        .bold()
                        .tint(.black)
                )
        } else {
            ZStack {
                Rectangle()
                    .fill(.gray)
                    .overlay(Material.ultraThin)
                ProgressView()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        CommonImage(image: .url(url: "", sfSymbol: "person"))
            .frame(width: 30)
            .clipShape(Circle())
    }
}

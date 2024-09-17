//
//  CollapsibleViewItem.swift
//  TestApp
//
//  Created by Dominic Valencia on 9/17/24.
//

import SwiftUI
import RealmSwift

struct CollapsibleItemView: View {
    let car: Car
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleHeader(car: car, onTap: onTap)
            
            if isExpanded {
                CollapsibleDetails(car: car)
                    .padding([.leading, .trailing, .bottom])
            }
        }
        .background(Color(red: 0.808, green: 0.808, blue: 0.808))
        .padding(.bottom, 8)
    }
}

struct CollapsibleHeader: View {
    let car: Car
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                CarImage(imageName: "\(car.make.replacingOccurrences(of: " ", with: "_"))")
                CarInfo(car: car)
                Spacer()
            }
            .padding()
            .background(Color(red: 0.808, green: 0.808, blue: 0.808))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CarImage: View {
    let imageName: String
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 40)
    }
}

struct CarInfo: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(car.make)
                .font(.bold(.title2)())
                .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
            
            Text("Price: \(car.customerPrice, specifier: "%.2f")")
                .font(.bold(.subheadline)())
                .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
            
            RatingView(rating: car.rating)
                .padding([.top, .bottom], 1)
        }
        .padding(10)
    }
}

struct RatingView: View {
    let rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(Color(hue: 0.053, saturation: 0.92, brightness: 0.948))
            }
        }
    }
}

struct CollapsibleDetails: View {
    let car: Car
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            DetailSection(title: "Pros:", items: car.prosList)
            DetailSection(title: "Cons:", items: car.consList)
        }
    }
}

struct DetailSection: View {
    let title: String
    let items: RealmSwift.List<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.bold(.caption)())
                .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
            
            ForEach(items, id: \.self) { item in
                if !item.isEmpty {
                    Text("• \(item)")
                        .font(.bold(.caption)())
                        .padding([.leading])
                }
            }
        }
    }
}


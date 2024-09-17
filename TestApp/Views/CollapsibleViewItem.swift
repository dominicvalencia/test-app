//
//  CollapsibleViewItem.swift
//  TestApp
//
//  Created by Dominic Valencia on 9/17/24.
//

import SwiftUI

struct CollapsibleItemView: View {
    let car: Car
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Button(action: onTap) {
                HStack {
                    Image("\(car.make.replacingOccurrences(of: " ", with: "_"))")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 40)
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("\(car.make)")
                            .font(.bold(.title2)())
                            .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
                        
                        Text("Price: \(car.customerPrice, specifier: "%.2f")")
                            .font(.bold(.subheadline)())
                            .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
                        
                        HStack {
                            ForEach(1...5, id: \.self) { star in
                                Image(systemName: star <= car.rating ? "star.fill" : "star")
                                    .foregroundColor(Color(hue: 0.053, saturation: 0.92, brightness: 0.948))
                            }
                        }
                        .padding([.top, .bottom], 1)
                        
                    }
                    .padding(10)
                    
                    Spacer()
                }
                .background(Color(red: 0.808, green: 0.808, blue: 0.808))
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pros:")
                        .font(.bold(.caption)())
                        .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
                    ForEach(car.prosList, id: \.self) { pro in
                        if !pro.isEmpty {
                            Text("• \(pro)")
                                .font(.bold(.caption)())
                                .padding([.leading])
                        }
                    }
                    
                    Text("Cons:")
                        .font(.bold(.caption)())
                        .foregroundColor(Color(red: 0.471, green: 0.471, blue: 0.471))
                    ForEach(car.consList, id: \.self) { con in
                        if !con.isEmpty {
                            Text("• \(con)")
                                .font(.bold(.caption)())
                                .padding([.leading])
                        }
                    }
                }
                .padding([.leading, .trailing, .bottom])
            }
        }
        .background(Color(red: 0.808, green: 0.808, blue: 0.808))
        .padding(.bottom, 8)
    }
}

//
//  ContentView.swift
//  TestApp
//
//  Created by Dominic Valencia on 9/16/24.
//

import SwiftUI
import Foundation
import RealmSwift

struct ContentView: View {
    @State private var filterText1 = ""
    @State private var filterText2 = ""
    @State private var expandedItem: UUID? = nil
    @State private var isLoading = true
    
    @StateObject private var carViewModel = CarViewModel()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(.circular)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        HStack {
                            Text("GUIDOMIA")
                                .font(.bold(.title)())
                                .foregroundStyle(.white)
                                .padding()
                            
                            Spacer()
                            
                            Button(action: {
                            }) {
                                Image(systemName: "line.horizontal.3")
                                    .foregroundColor(Color.white)
                                    .font(.title)
                                    .padding()
                            }
                        }
                        .background(Color(hue: 0.053, saturation: 0.92, brightness: 0.948))
                        
                        Image("Tacoma")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Filter")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .padding([.leading, .top])
                            
                            VStack(spacing: 16) {
                                TextField("Any Make", text: $filterText1)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Any Model", text: $filterText2)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .padding([.leading, .trailing, .bottom])
                        }
                        .background(Color(hue: 0.0, saturation: 0.029, brightness: 0.481))
                        .cornerRadius(8)
                        .padding([.leading, .trailing, .top, .bottom])
                        
                        ForEach(Array(carViewModel.filteredCars(filterMake: filterText1, filterModel: filterText2).enumerated()), id: \.1.id) { index, car in
                            VStack(spacing: 0) {
                                CollapsibleItemView(car: car, isExpanded: self.expandedItem == car.id) {
                                    withAnimation {
                                        self.expandedItem = self.expandedItem == car.id ? nil : car.id
                                    }
                                }
                                
                                if index < carViewModel.filteredCars(filterMake: filterText1, filterModel: filterText2).count - 1 {
                                    SeparatorView()
                                }
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            carViewModel.loadInitialDataIfNeeded { isLoaded in
                isLoading = !isLoaded
                if isLoaded {
                    DispatchQueue.main.async {
                        let filteredCars = carViewModel.filteredCars(filterMake: filterText1, filterModel: filterText2)
                        if let firstCar = filteredCars.first {
                            self.expandedItem = firstCar.id
                        }
                    }
                }
            }
        }
    }
}

struct SeparatorView: View {
    var body: some View {
        Rectangle()
            .fill(Color(hue: 0.053, saturation: 0.92, brightness: 0.948))
            .frame(height: 2)
            .padding(10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  WeatherSwiftUI
//
//  Created by César González on 27/12/21.
//

import SwiftUI
import WeatherChallenge

struct WeatherView: View {
    
    @State private var darkMode = false
    @ObservedObject var viewModel: WeatherViewModel
    var body: some View {
        ZStack {
            if let imageName = viewModel.backgroundImageName {
                BackgroundImage(imageName: imageName)
            } else {
                LinearGradient(gradient: Gradient(colors: [darkMode ? .black : .blue, darkMode ? .gray : Color("lightBlue")]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }
            ZStack {
                VStack {
                    Spacer()
                    Text(viewModel.cityName)
                        .font(.system(size: 60, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 4, x: 1, y: 5)
                        .lineLimit(nil)
                    HStack {
                        VStack(alignment: .leading, spacing: 6.0) {
                            Text(viewModel.latitude)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                .shadow(color: .black, radius: 2, x: 1, y: 5)
                            
                            Text(viewModel.longitude)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                .shadow(color: .black, radius: 2, x: 1, y: 5)
                        }
                        Spacer()
                    }
                    
                    Text(viewModel.temperature)
                        .font(.system(size: 50, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .shadow(color: .black, radius: 4, x: 1, y: 5)
                        .padding()
                    Image(systemName: viewModel.weatherIcon)
                        .renderingMode(.original)
                        .font(.system(size: 120))
                        .shadow(color: .black, radius: 4, x: 1, y: 5)
                        .padding()
                    Text(viewModel.weatherDescription)
                        .font(.system(size: 40, design: .rounded))
                        .foregroundColor(.white)
                        .shadow(color: .black, radius: 4, x: 1, y: 5)
                        .padding()
                    if viewModel.backgroundImageName == nil {
                        Spacer()
                        HStack {
                            changeModeButton
                            Spacer()
                            changeLocationButton
                        }
                    }
                    Spacer()
                }.onAppear(perform: {
                    viewModel.reload()
                })
                .padding()
                
            }
        }
    }
    
    var changeLocationButton: some View {
        Button(action: {
            viewModel.reload()
        }, label: {
            Image(systemName: "arrow.counterclockwise.circle.fill")
                .foregroundColor(.white)
                .font(.system(size: 45, weight: .bold))
                .frame(width: 50, height: 50)
                .shadow(radius: 10)
        })
    }
    
    var changeModeButton: some View {
        Button(action: {
            darkMode.toggle()
        }, label: {
            let imageName = darkMode ? "circle.lefthalf.fill" : "circle.righthalf.fill"
            let color = darkMode ? Color.white : Color.secondary
            Image(systemName: imageName)
                .foregroundColor(color)
                .font(.system(size: 45, weight: .bold))
                .frame(width: 50, height: 50)
                .shadow(radius: 4)
        })
        .padding(20)
    }
}

struct BackgroundImage: View {
    var imageName: String
    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFill()
            .overlay(
                Color.black
                    .opacity(0.3)
            )
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let client = URLSessionHTTPClient(session: URLSession.shared)
        let loader = RemoteWeatherLoader(client: client)
        WeatherView(viewModel: WeatherViewModel(loader: loader))
    }
}

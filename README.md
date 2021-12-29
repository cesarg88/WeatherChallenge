# Fever Weather Challenge

This project was created with the intention to demonstrate clean architecture and separation of concerns by creating isolated independent modules that can be easily reusable across platforms.

## The WeatherChallenge Framework

a client agnostic framework which contains all necessary elements to fetch Weather from a datasource. This isolated framework is reusable across platform and is backed by unit tests to guarantee its proper behavior.
Inside the framework, the API module is in charge of making the actual remote request to fetch weather data from a given location in coords.

## The Weather iOS Module

The Presenter type Uses de framework to retrieve weather from a location and transform this received data to an UI friendly data model.
This presenter does not know nor care about concrete implementations of its clients and that's why it does not import UIKit making it reusable across platform i.e iOS, appleWatchOS, tvOS or even macOS.

The composer takes care of the threading feature by making use of decorator pattern to add behavior to the loader class without modifying it (respecting the open/ close solid principle). This helps the loader to not care to return received data on a main thread which is an UIKit concrete implementation.

This module is also supported by a set of unit testing to guarantee proper UI behavior 

## The Weather SwiftUI Module

An small module created only to practice SwiftUI framework

## Usage

clone te repo, open the project with Xcode and select the desired target for run/testing

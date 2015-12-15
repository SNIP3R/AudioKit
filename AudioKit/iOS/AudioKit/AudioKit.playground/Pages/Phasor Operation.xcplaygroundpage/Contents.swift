//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
//:
//: ---
//:
//: ## phasor
//: ### This is an example of building a sound generator from scratch
import XCPlayground
import AudioKit

let audiokit = AKManager.sharedInstance

let frequency = AKP.phasor(frequency: 0.5.ak) * 1600
let amplitude = AKP.phasor(frequency: 0.5.ak) - 1

let oscillator = AKP.sine(frequency: frequency, amplitude: amplitude)
let lowPassFilter = AKP.lowPassFilter(oscillator, cutoffFrequency: 1600.ak)
//: Set up the nodes
let generator = AKNode.generator(lowPassFilter)

audiokit.audioOutput = generator
audiokit.start()

let plotView = AKAudioOutputPlot.createView()
XCPlaygroundPage.currentPage.liveView = plotView
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

//: [TOC](Table%20Of%20Contents) | [Previous](@previous) | [Next](@next)
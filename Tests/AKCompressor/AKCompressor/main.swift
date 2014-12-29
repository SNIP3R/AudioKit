//
//  main.swift
//  AudioKit
//
//  Customized by Nick Arner and Aurelius Prochazka on 12/27/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

import Foundation

class Instrument : AKInstrument {

    var auxilliaryOutput = AKAudio()

    override init() {
        super.init()
        let filename = "CsoundLib64.framework/Sounds/PianoBassDrumLoop.wav"

        let audio = AKFileInput(filename: filename)
        connect(audio)

        let mono = AKMixedAudio(signal1: audio.leftOutput, signal2: audio.rightOutput, balance: 0.5.ak)
        connect(mono)

        auxilliaryOutput = AKAudio.globalParameter()
        assignOutput(auxilliaryOutput, to:mono)
    }
}

class Processor : AKInstrument {

    init(audioSource: AKAudio) {
        super.init()

        let compressionRatio = AKLinearControl(firstPoint: 0.5.ak, secondPoint: 2.ak, durationBetweenPoints: 11.ak)
        connect(compressionRatio)

        let attackTime = AKLinearControl(firstPoint: 0.ak, secondPoint: 1.ak, durationBetweenPoints: 11.ak)
        connect(attackTime)

        let operation = AKCompressor(input: audioSource, controllingInput: audioSource)
        operation.compressionRatio = compressionRatio
        operation.attackTime = attackTime
        connect(operation)

        let output = AKBalance(input: operation, comparatorAudioSource: audioSource)
        connect(output)

        connect(AKAudioOutput(audioSource:output))
    }
}

let instrument = Instrument()
let processor = Processor(audioSource: instrument.auxilliaryOutput)
AKOrchestra.addInstrument(instrument)
AKOrchestra.addInstrument(processor)

AKOrchestra.testForDuration(10)

processor.play()
instrument.play()

while(AKManager.sharedManager().isRunning) {} //do nothing
println("Test complete!")
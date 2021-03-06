//
//  AKTanhDistortion.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright (c) 2016 Aurelius Prochazka. All rights reserved.
//

import AVFoundation

/// Distortion using a modified hyperbolic tangent function.
///
/// - parameter input: Input node to process
/// - parameter pregain: Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
/// - parameter postgain: Gain applied after waveshaping
/// - parameter postiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
/// - parameter negativeShapeParameter: Like the positive shape parameter, only for the negative part.
///
public class AKTanhDistortion: AKNode, AKToggleable {

    // MARK: - Properties


    internal var internalAU: AKTanhDistortionAudioUnit?
    internal var token: AUParameterObserverToken?

    private var pregainParameter: AUParameter?
    private var postgainParameter: AUParameter?
    private var postiveShapeParameterParameter: AUParameter?
    private var negativeShapeParameterParameter: AUParameter?

    /// Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    public var pregain: Double = 2.0 {
        willSet(newValue) {
            if pregain != newValue {
                pregainParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Gain applied after waveshaping
    public var postgain: Double = 0.5 {
        willSet(newValue) {
            if postgain != newValue {
                postgainParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Shape of the positive part of the signal. A value of 0 gets a flat clip.
    public var postiveShapeParameter: Double = 0.0 {
        willSet(newValue) {
            if postiveShapeParameter != newValue {
                postiveShapeParameterParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }
    /// Like the positive shape parameter, only for the negative part.
    public var negativeShapeParameter: Double = 0.0 {
        willSet(newValue) {
            if negativeShapeParameter != newValue {
                negativeShapeParameterParameter?.setValue(Float(newValue), originator: token!)
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this distortion node
    ///
    /// - parameter input: Input node to process
    /// - parameter pregain: Determines the amount of gain applied to the signal before waveshaping. A value of 1 gives slight distortion.
    /// - parameter postgain: Gain applied after waveshaping
    /// - parameter postiveShapeParameter: Shape of the positive part of the signal. A value of 0 gets a flat clip.
    /// - parameter negativeShapeParameter: Like the positive shape parameter, only for the negative part.
    ///
    public init(
        _ input: AKNode,
        pregain: Double = 2.0,
        postgain: Double = 0.5,
        postiveShapeParameter: Double = 0.0,
        negativeShapeParameter: Double = 0.0) {

        self.pregain = pregain
        self.postgain = postgain
        self.postiveShapeParameter = postiveShapeParameter
        self.negativeShapeParameter = negativeShapeParameter

        var description = AudioComponentDescription()
        description.componentType         = kAudioUnitType_Effect
        description.componentSubType      = 0x64697374 /*'dist'*/
        description.componentManufacturer = 0x41754b74 /*'AuKt'*/
        description.componentFlags        = 0
        description.componentFlagsMask    = 0

        AUAudioUnit.registerSubclass(
            AKTanhDistortionAudioUnit.self,
            asComponentDescription: description,
            name: "Local AKTanhDistortion",
            version: UInt32.max)

        super.init()
        AVAudioUnit.instantiateWithComponentDescription(description, options: []) {
            avAudioUnit, error in

            guard let avAudioUnitEffect = avAudioUnit else { return }

            self.avAudioNode = avAudioUnitEffect
            self.internalAU = avAudioUnitEffect.AUAudioUnit as? AKTanhDistortionAudioUnit

            AudioKit.engine.attachNode(self.avAudioNode)
            input.addConnectionPoint(self)
        }

        guard let tree = internalAU?.parameterTree else { return }

        pregainParameter                = tree.valueForKey("pregain")                as? AUParameter
        postgainParameter               = tree.valueForKey("postgain")               as? AUParameter
        postiveShapeParameterParameter  = tree.valueForKey("postiveShapeParameter")  as? AUParameter
        negativeShapeParameterParameter = tree.valueForKey("negativeShapeParameter") as? AUParameter

        token = tree.tokenByAddingParameterObserver {
            address, value in

            dispatch_async(dispatch_get_main_queue()) {
                if address == self.pregainParameter!.address {
                    self.pregain = Double(value)
                } else if address == self.postgainParameter!.address {
                    self.postgain = Double(value)
                } else if address == self.postiveShapeParameterParameter!.address {
                    self.postiveShapeParameter = Double(value)
                } else if address == self.negativeShapeParameterParameter!.address {
                    self.negativeShapeParameter = Double(value)
                }
            }
        }
        pregainParameter?.setValue(Float(pregain), originator: token!)
        postgainParameter?.setValue(Float(postgain), originator: token!)
        postiveShapeParameterParameter?.setValue(Float(postiveShapeParameter), originator: token!)
        negativeShapeParameterParameter?.setValue(Float(negativeShapeParameter), originator: token!)
    }
    
    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    public func start() {
        self.internalAU!.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    public func stop() {
        self.internalAU!.stop()
    }
}

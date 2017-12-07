//
//  AUv3InstrumentHost.swift
//  AUInstHostTest
//
//  Created by acb on 04/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Foundation
import AVFoundation

class AUv3InstrumentHost {

    private let engine: AVAudioEngine = {
        let engine = AVAudioEngine()
        return engine
    }()
    private var instrumentAU: AVAudioUnitMIDIInstrument? = nil {
        didSet(oldValue) {
            if let oldValue = oldValue {
                self.engine.disconnectNodeOutput(oldValue)
                self.engine.detach(oldValue)
            }
            if let newInst = self.instrumentAU {
                self.engine.attach(newInst)
                self.engine.connect(newInst, to: self.engine.mainMixerNode, format: newInst.outputFormat(forBus: 0))
            }
        }
    }

    fileprivate func startEngineIfNeeded() {
        if !self.engine.isRunning {
            do {
                try engine.start()
                print("audio engine started")
            } catch {
                print("oops \(error)")
                print("could not start audio engine")
            }
        }
    }
}

extension AUv3InstrumentHost: InstrumentHost {
    var auAudioUnit: AUAudioUnit? { return self.instrumentAU?.auAudioUnit }
        
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()) {
        let flags = AudioComponentFlags(rawValue: desc.componentFlags)
        let canLoadInProcess = flags.contains(AudioComponentFlags.canLoadInProcess)
        print("Can load in process = \(canLoadInProcess)")
        let loadOptions: AudioComponentInstantiationOptions = canLoadInProcess ? .loadInProcess : .loadOutOfProcess
        AVAudioUnitMIDIInstrument.instantiate(with: desc, options: loadOptions) { [weak self] avAudioUnit, error in
            if let e = error {
                print("Failed to load instrument: \(e)")
                completion(false)
            } else if let unit = avAudioUnit as? AVAudioUnitMIDIInstrument {
                DispatchQueue.main.async {
                    self?.instrumentAU = unit
                    print("Loaded")
                    completion(true)
                }
            } else {
                fatalError()
            }
        }
    }
        
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8) {
        guard let inst = self.instrumentAU else { return }
        self.startEngineIfNeeded()
        inst.startNote(note, withVelocity: velocity, onChannel: 0)
    }
    
    func noteOff(_ note: UInt8) {
        guard let inst = self.instrumentAU else { return }
        inst.stopNote(note, onChannel: 0)
    }
    
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()) {
        guard let au = self.auAudioUnit else { completion(nil) ; return }
        au.requestViewController { (vc) in
            completion(vc.map(InterfaceInstance.viewController))
        }
    }
}

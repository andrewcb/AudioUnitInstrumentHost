//
//  AudioService.swift
//  AudioUnitInstrumentHost
//
//  Created by acb on 07/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Foundation
import AVFoundation

class AudioService: NSObject {
    
    /*
     The AudioUnitv3 hosting code does not always work reliably with commercial softsynths, and can crash when changing presets. Until this improves, the AUv2 code, whilst uglier, is more solid.
     */
    var host: InstrumentHost = AUv2InstrumentHost()
    
    // We use the AVFoundation API for loading these, as it works, and the data translates to the AudioUnitv2 methods
    func getListOfInstruments() -> [AVAudioUnitComponent] {
        var desc = AudioComponentDescription()
        desc.componentType = kAudioUnitType_MusicDevice
        desc.componentSubType = 0
        desc.componentManufacturer = 0
        desc.componentFlags = 0
        desc.componentFlagsMask = 0
        return AVAudioUnitComponentManager.shared().components(matching: desc)
    }
    
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool)->()) {
        host.loadInstrument(fromDescription: desc, completion: completion)
    }
    
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()) {
        self.host.requestInstrumentInterface(completion)
    }
    
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8) {
        host.noteOn(note, withVelocity: velocity)
    }
    
    func noteOff(_ note: UInt8) {
        host.noteOff(note)
    }    
}


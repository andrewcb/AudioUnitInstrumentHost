//
//  AUv2InstrumentHost.swift
//  AUInstHostTest
//
//  Created by acb on 04/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Foundation
import AudioToolbox
import CoreAudio


class AUv2InstrumentHost {
    let graph: AudioUnitGraph
    let outNode: AUNode
    var synthNode: AUNode?
    var synthUnit: AudioUnitInstance?
    
    init() {
        do {
            self.graph = try AudioUnitGraph()
            self.outNode = try graph.addNode(withType: kAudioUnitType_Output, subType: kAudioUnitSubType_DefaultOutput, manufacturer: kAudioUnitManufacturer_Apple)
            try graph.open()
        } catch {
            fatalError("Failed to initialise graph: \(error)")
        }
    }
}

extension AUv2InstrumentHost: InstrumentHost {
    
    var auAudioUnit: AUAudioUnit? { return nil }
    
    func loadInstrument(fromDescription desc: AudioComponentDescription, completion: @escaping (Bool) -> ()) {
        do {
            if let oldNode = self.synthNode {
                try graph.stop()
                try graph.disconnect(node: self.outNode, element: 0)
                try graph.remove(node: oldNode)
                self.synthUnit = nil
                self.synthNode = nil
                try graph.uninitialize()
            }
            self.synthNode = try graph.addNode(withType: kAudioUnitType_MusicDevice, subType: desc.componentSubType, manufacturer: desc.componentManufacturer)
            if let synthNode = self.synthNode {
                try graph.connect(node: synthNode, element: 0, toNode: self.outNode, element: 0)
                if !(try graph.isInitialised()) {
                    try graph.initialize()
                }
                
                try graph.start()
                self.synthUnit = try graph.getAudioUnit(for: synthNode)
                
                completion(true)
            }
        } catch {
            print("Failed to load synth node: \(error)")
            completion(false)
        }
    }
    
    func noteOn(_ note: UInt8, withVelocity velocity: UInt8) {
        if let synthUnit = self.synthUnit {
            do {
                try synthUnit.sendMIDIEvent(0x90, note, velocity, atSampleOffset: 0)
            } catch {
                print("noteOn error: \(error)")
            }
        }
    }
    
    func noteOff(_ note: UInt8) {
        if let synthUnit = self.synthUnit {
            do {
                try synthUnit.sendMIDIEvent(0x80, note, 0, atSampleOffset: 0)
            } catch {
                print("noteOn error: \(error)")
            }
        }
    }
    
    func requestInstrumentInterface(_ completion: @escaping (InterfaceInstance?)->()) {
        let view = loadViewForAudioUnit(self.synthUnit!.auRef, CGSize(width: 0, height: 0))
        completion(view.map(InterfaceInstance.view))
    }
}

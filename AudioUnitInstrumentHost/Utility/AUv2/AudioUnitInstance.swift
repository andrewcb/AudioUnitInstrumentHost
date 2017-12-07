//
//  AudioUnitInstance.swift
//  AUInstHostTest
//
//  Created by acb on 07/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Foundation
import AudioToolbox
import CoreAudio

// Encapsulate an AudioUnit. Internally, this is weakly typed, and, say, attempting to send MIDI to a non-instrument will probably cause a runtime error, but this is a very thin wrapper.
struct AudioUnitInstance {
    var auRef: AudioUnit
    
    func sendMIDIEvent(_ statusByte: UInt8, _ data1: UInt8, _ data2: UInt8, atSampleOffset offset: UInt32) throws {
        let status = MusicDeviceMIDIEvent(self.auRef, UInt32(statusByte), UInt32(data1), UInt32(data2), offset)
        if status != noErr { throw NSError(osstatus:status) }
    }
}

//
//  AudioUnitGraph.swift
//  AUInstHostTest
//
//  Created by acb on 07/12/2017.
//  Copyright © 2017 acb. All rights reserved.
//

import Foundation
import AudioToolbox
import CoreAudio

// Minimal Swiftifications


struct AudioUnitGraph {
    var auRef: AUGraph
    
    init() throws {
        var maybeResult: AUGraph?
        let status = NewAUGraph(&maybeResult)
        guard let result = maybeResult else { throw NSError(osstatus:status) }
        self.auRef = result
    }
    
    func addNode(withType type: OSType, subType: OSType, manufacturer: OSType) throws -> AUNode {
        var node = AUNode()
        var cd = AudioComponentDescription(
            componentType: type,
            componentSubType: subType,
            componentManufacturer: manufacturer,
            componentFlags: 0,componentFlagsMask: 0)
        let status = AUGraphAddNode(self.auRef, &cd, &node)
        if status == noErr {
            return node
        } else {
            throw NSError(osstatus:status)
        }
    }
    
    func remove(node: AUNode) throws {
        let status = AUGraphRemoveNode(self.auRef, node)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func open() throws {
        let status = AUGraphOpen(self.auRef)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func getAudioUnit(for node: AUNode) throws -> AudioUnitInstance {
        var maybeUnit: AudioUnit? = nil
        let status = AUGraphNodeInfo(self.auRef, node, nil, &maybeUnit)
        guard let unit = maybeUnit else { throw NSError(osstatus:status) }
        return AudioUnitInstance(auRef: unit)
    }
    
    func connect(node fromNode: AUNode, element fromElement: AudioUnitElement, toNode: AUNode, element toElement: AudioUnitElement) throws {
        let status = AUGraphConnectNodeInput(self.auRef, fromNode, fromElement, toNode, toElement)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func disconnect(node destNode: AUNode, element: AudioUnitElement) throws {
        let status = AUGraphDisconnectNodeInput(self.auRef, destNode, element)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func initialize() throws {
        let status = AUGraphInitialize(self.auRef)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func uninitialize() throws {
        let status = AUGraphUninitialize(self.auRef)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func start() throws {
        let status = AUGraphStart(self.auRef)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func stop() throws {
        let status = AUGraphStop(self.auRef)
        if status != noErr { throw NSError(osstatus:status) }
    }
    
    func isInitialised() throws -> Bool {
        var result = DarwinBoolean(false)
        let status = AUGraphIsInitialized(self.auRef, &result)
        if status != noErr { throw NSError(osstatus:status) }
        return result.boolValue
    }
    
    func isRunning() throws -> Bool {
        var result = DarwinBoolean(false)
        let status = AUGraphIsRunning(self.auRef, &result)
        if status != noErr { throw NSError(osstatus:status) }
        return result.boolValue
    }
}

//
//  Manager+ModWheelDelegate.swift
//  AudioKitSynthOne
//
//  Created by AudioKit Contributors on 5/25/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

// Mod Wheel Settings Pop Over Delegate

extension Manager: ModWheelDelegate {

    func didSelectRouting(newDestination: Int) {
        activePreset.modWheelRouting = Double(newDestination)

        switch activePreset.modWheelRouting {
        case 0:
            // Cutoff
            conductor.updateSingleUI(.cutoff, control: nil, value: Conductor.sharedInstance.getSynthParameter(.cutoff))
        case 1:
            // LFO 1 Rate
            modWheelPad.setVerticalValue01(Double(Conductor.sharedInstance.getDependentParameter(.lfo1Rate)))
        case 2:
            // LFO 2 Rate
            modWheelPad.setVerticalValue01(Double(Conductor.sharedInstance.getDependentParameter(.lfo2Rate)))
        default:
            break
        }

    }
}

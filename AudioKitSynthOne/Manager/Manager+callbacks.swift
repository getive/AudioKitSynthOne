//
//  Manager+callbacks.swift
//  AudioKitSynthOne
//
//  Created by Aurelius Prochazka on 6/8/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension Manager {
    
    func setupCallbacks() {
        let c = Conductor.sharedInstance

        octaveStepper.callback = { value in
            self.keyboardView.firstOctave = Int(value) + 2
        }

        configKeyboardButton.callback = { _ in
            self.configKeyboardButton.value = 0
            self.performSegue(withIdentifier: "SegueToKeyboardSettings", sender: self)
        }

        midiButton.callback = { _ in
            self.midiButton.value = 0
            self.performSegue(withIdentifier: "SegueToMIDI", sender: self)
        }

        modWheelSettings.callback = { _ in
            self.modWheelSettings.value = 0
            self.performSegue(withIdentifier: "SegueToMOD", sender: self)
        }

        midiLearnToggle.callback = { _ in

            // Toggle MIDI Learn Knobs in subview
            for knob in self.midiKnobs { knob.midiLearnMode = self.midiLearnToggle.isSelected }

            // Update display label
            if self.midiLearnToggle.isSelected {
                let message = NSLocalizedString("MIDI Learn: Touch a knob to assign", comment: "MIDI Learn Instructions")
                self.updateDisplay(message)
            } else {
                let message = NSLocalizedString("MIDI Learn Off", comment: "MIDI Learn Instructions")
                self.updateDisplay(message)
                self.saveAppSettingValues()
            }
        }

        holdButton.callback = { value in
            self.keyboardView.holdMode = !self.keyboardView.holdMode
            if value == 0.0 {
                self.stopAllNotes()
            }
        }

        monoButton.callback = { value in
            let monoMode = value > 0 ? true : false
            self.keyboardView.polyphonicMode = !monoMode
            c.setSynthParameter(.isMono, value)
            self.conductor.updateSingleUI(.isMono, control: self.monoButton, value: value)
        }

        keyboardToggle.callback = { value in
            if value == 1 {
                self.keyboardToggle.setTitle("Hide", for: .normal)
            } else {
                self.keyboardToggle.setTitle("Show", for: .normal)

                // Add panel to bottom
                if self.bottomChildPanel == self.topChildPanel {
                    self.bottomChildPanel = self.bottomChildPanel?.rightPanel()
                }
                guard let bottom = self.bottomChildPanel else { return }
                self.switchToChildPanel(bottom, isOnTop: false)
            }

            // Animate Keyboard
            let newConstraintValue: CGFloat = (value == 1.0) ? 0 : -299
            UIView.animate(withDuration: Double(0.4), animations: {
                self.keyboardBottomConstraint.constant = newConstraintValue
                self.view.layoutIfNeeded()
            })

            self.appSettings.showKeyboard = self.keyboardToggle.value
            self.saveAppSettings()
        }

        modWheelPad.callback = { value in
            switch self.activePreset.modWheelRouting {
            case 0:
                // Cutoff
                let newValue = 1 - value
                let scaledValue = Double.scaleRangeLog2(newValue, rangeMin: 120, rangeMax: 7_600)
                c.setSynthParameter(.cutoff, scaledValue * 3)
                c.updateSingleUI(.cutoff, control: self.modWheelPad, value: c.getSynthParameter(.cutoff))
            case 1:
                // LFO 1 Rate
                c.setDependentParameter(.lfo1Rate, value, self.conductor.lfo1RateModWheelID)
            case 2:
                // LFO 2 Rate
                c.setDependentParameter(.lfo2Rate, value, self.conductor.lfo2RateModWheelID)
            default:
                break
            }
        }

        pitchBend.callback = { value01 in
            c.setDependentParameter(.pitchbend, value01, Conductor.sharedInstance.pitchBendID)
        }
        pitchBend.completionHandler = {  _, touchesEnded, reset in
            if touchesEnded && !reset {
                self.pitchBend.resetToCenter()
            }
            if reset {
                c.setDependentParameter(.pitchbend, 0.5, Conductor.sharedInstance.pitchBendID)
            }
        }
    }
}

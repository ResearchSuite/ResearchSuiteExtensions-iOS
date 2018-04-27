//
//  RSEnhancedMultipleChoiceCellWithNumericScaleAccessoryController.swift
//  ResearchSuiteExtensions
//
//  Created by James Kizer on 4/26/18.
//

import UIKit
import ResearchKit

open class RSEnhancedMultipleChoiceCellWithNumericScaleAccessoryController: RSEnhancedMultipleChoiceBaseCellController {
    
    var answerFormat: RSEnhancedScaleAnswerFormat {
        return (self.auxiliaryItem?.answerFormat as? RSEnhancedScaleAnswerFormat)!
    }

    open override func viewForAuxiliaryItem(item: ORKFormItem, cell: RSEnhancedMultipleChoiceCell) -> UIView? {
        
        guard let auxItem = self.auxiliaryItem,
            let answerFormat = auxItem.answerFormat as? RSEnhancedScaleAnswerFormat,
            let sliderView = RSSliderView.newView(minimumValue: answerFormat.minimum, maximumValue: answerFormat.maximum) else {
                return nil
        }
        
        assert(auxItem == item)
        
        sliderView.minValueLabel.text = answerFormat.minValueLabel
        sliderView.maxValueLabel.text = answerFormat.maxValueLabel
        sliderView.minValueDescriptionLabel.text = answerFormat.minimumValueDescription
        sliderView.neutralValueDescriptionLabel.text = answerFormat.neutralValueDescription
        sliderView.maxValueDescriptionLabel.text = answerFormat.maximumValueDescription
        sliderView.textLabel.text = item.text
        
        sliderView.onValueChanged = { value in
            
            if value >= answerFormat.minimum && value <= answerFormat.maximum {
                sliderView.currentValueLabel.text = "\(value)"
                
                let numericResult = ORKNumericQuestionResult(identifier: item.identifier)
                numericResult.numericAnswer = NSNumber(value: value)
                self.validatedResult = numericResult
            }
            else {
                self.validatedResult = nil
            }
        }
        
        if let result = self.validatedResult as? ORKNumericQuestionResult,
            let numericAnswer = result.numericAnswer {
            sliderView.setValue(value: numericAnswer.intValue, animated: false)
        }
        else {
            sliderView.setValue(value: answerFormat.defaultValue, animated: false)
        }
        
        sliderView.setNeedsLayout()
        
        return sliderView
        
    }
    
}
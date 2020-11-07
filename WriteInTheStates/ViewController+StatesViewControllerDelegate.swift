import UIKit

extension ViewController: StatesViewControllerDelegate
{
    func statesViewController(_ statesViewController: StatesViewController,
                              didChangeTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)
    {
        statesViewController.view.isUserInteractionEnabled = false
        
        let newConstraintConstant = previousContainerViewTopConstraint + translationPoint.y
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50.0
        
        if (newConstraintConstant >= fullHeightTopConstraint - constraintPadding/2) {
            containerViewTopConstraint.constant = newConstraintConstant
            animateBackgroundFade(withCurrentTopConstraint: newConstraintConstant)
        }
    }
    
    private func animateTopConstraint(constant: CGFloat, withVelocity velocity: CGPoint)
    {
        let previousConstraint = containerViewTopConstraint.constant
        let distance = previousConstraint - constant
        let springVelocity = max(1 / (abs(velocity.y / distance)), 0.08)
        let springDampening = CGFloat(0.6)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: springDampening,
                       initialSpringVelocity: springVelocity,
                       options: [.curveLinear],
                       animations: {
                        self.containerViewTopConstraint.constant = constant
                        self.previousContainerViewTopConstraint = constant
                        self.animateBackgroundFade(withCurrentTopConstraint: constant)
                        self.view.layoutIfNeeded()
                       },
                       completion: nil)
    }
    
    private func animateBackgroundFade(withCurrentTopConstraint currentTopConstraint: CGFloat)
    {
        let expandedHeight = ExpansionState.height(forState: .expanded, inContainer: view.bounds)
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let expandedTopConstraint = view.bounds.height - expandedHeight
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        
        let totalDistance = (expandedTopConstraint - fullHeightTopConstraint)
        let currentDistance = (expandedTopConstraint - currentTopConstraint)
        var progress = currentDistance / totalDistance
        
        progress = max(0.0, progress)
        progress = min(shadowViewAlpha, progress)
        shadowView.alpha = progress
    }
    
    func statesViewController(_ statesViewController: StatesViewController,
                              didEndTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)
    {
        let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
        let expandedHeight = ExpansionState.height(forState: .expanded, inContainer: view.bounds)
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let compressedTopConstraint = view.bounds.height - compressedHeight
        let expandedTopConstraint = view.bounds.height - expandedHeight
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50.0
        let velocityThreshold: CGFloat = 50.0
        statesViewController.view.isUserInteractionEnabled = true
        
        if velocity.y > velocityThreshold
        {
            if previousContainerViewTopConstraint == fullHeightTopConstraint
            {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding
                {
                    statesViewController.expansionState = .expanded
                    animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
                }
                else
                {
                    statesViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            }
            else if previousContainerViewTopConstraint == expandedTopConstraint
            {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding 
                {
                    statesViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } 
                else 
                {
                    statesViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } 
            else 
            {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding 
                {
                    statesViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } 
                else 
                {
                    statesViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            }
        } 
        else 
        {
            if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding 
            {
                statesViewController.expansionState = .fullHeight
                animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
            } 
            else if containerViewTopConstraint.constant < compressedTopConstraint - constraintPadding 
            {
                statesViewController.expansionState = .expanded
                animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
            } 
            else 
            {
                statesViewController.expansionState = .compressed
                animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
            }
        }
    }
}

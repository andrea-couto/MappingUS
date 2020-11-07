import UIKit

protocol StatesViewControllerDelegate: class
{
    func statesViewController(_ statesViewController: StatesViewController,
                              didChangeTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)
    
    func statesViewController(_ statesViewController: StatesViewController,
                              didEndTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)
}

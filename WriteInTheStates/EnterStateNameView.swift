import UIKit

class EnterStateNameView: UIView
{
    @IBOutlet private weak var stateNameTextField: UITextField!
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        xibSetup()
    }
}

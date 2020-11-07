import UIKit

enum ExpansionState
{
    case compressed
    case expanded
    case fullHeight
    
    static func height(forState state: ExpansionState, inContainer container: CGRect) -> CGFloat
    {
        switch state
        {
            case .compressed:
                return 120
            case .expanded:
                return 300
            case .fullHeight:
                return container.height - 35
        }
    }
}

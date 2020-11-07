import UIKit

class StatesViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate
{
    @IBOutlet private weak var headerViewTitleLabel: UILabel!
    internal var panGestureRecognizer: UIPanGestureRecognizer?

    var expansionState: ExpansionState = .compressed
    {
        didSet
        {
            if expansionState != oldValue
            {
                configure(forExpansionState: expansionState)
            }
        }
    }

    weak var delegate: StatesViewControllerDelegate?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupGestureRecognizers()
        configureAppearance()
        configure(forExpansionState: expansionState)
    }

    private func configureAppearance()
    {
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
    }

    private func configure(forExpansionState expansionState: ExpansionState)
    {
        switch expansionState
        {
            case .compressed:
                animateHeaderTitle(toAlpha: 0.0)
            case .expanded:
                animateHeaderTitle(toAlpha: 1.0)
            case .fullHeight:
                animateHeaderTitle(toAlpha: 1.0)
        }
    }

    private func animateHeaderTitle(toAlpha alpha: CGFloat)
    {
        UIView.animate(withDuration: 0.1)
        {
            self.headerViewTitleLabel.alpha = alpha
        }
    }

    private func setupGestureRecognizers()
    {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panGestureDidMove(sender:)))
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self

        view.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer
    }

    @objc private func panGestureDidMove(sender: UIPanGestureRecognizer)
    {
        let translationPoint = sender.translation(in: view.superview)
        let velocity = sender.velocity(in: view.superview)

        switch sender.state
        {
            case .changed:
                delegate?.statesViewController(self, didChangeTranslationPoint: translationPoint, withVelocity: velocity)
            case .ended:
                delegate?.statesViewController(self,
                                               didEndTranslationPoint: translationPoint,
                                               withVelocity: velocity)
            default:
                return
        }
    }
}

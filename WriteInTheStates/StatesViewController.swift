import UIKit

class StatesViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate
{
    @IBOutlet weak var statesTableView: UITableView!
    
    // TODO: - cant close the states drawer unless at top of tableview
    internal var panGestureRecognizer: UIPanGestureRecognizer?
    let cellReuseIdentifier = "cell"
    private var shouldHandleGesture: Bool = true

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
        statesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        statesTableView.delegate = self
        statesTableView.dataSource = self
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
                statesTableView.panGestureRecognizer.isEnabled = false
                animateHeaderTitle(toAlpha: 0.0)
            case .expanded:
                statesTableView.panGestureRecognizer.isEnabled = false
                animateHeaderTitle(toAlpha: 1.0)
            case .fullHeight:
                animateHeaderTitle(toAlpha: 1.0)
                if statesTableView.contentOffset.y > 0.0
                {
                    panGestureRecognizer?.isEnabled = false
                }
                else
                {
                    panGestureRecognizer?.isEnabled = true
                }
                statesTableView.panGestureRecognizer.isEnabled = true
        }
    }

    private func animateHeaderTitle(toAlpha alpha: CGFloat)
    {
        UIView.animate(withDuration: 0.1)
        {
            [weak self]
            in
            self?.statesTableView.alpha = alpha
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
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGestureRecognizer.velocity(in: view.superview)
        statesTableView.panGestureRecognizer.isEnabled = true

        if otherGestureRecognizer == statesTableView.panGestureRecognizer
        {
            switch expansionState
            {
                case .compressed:
                    return false
                case .expanded:
                    return false
                case .fullHeight:
                    if velocity.y > 0.0
                    {
                        if statesTableView.contentOffset.y > 0.0
                        {
                            return true
                        }
                        shouldHandleGesture = true
                        statesTableView.panGestureRecognizer.isEnabled = false
                        return false
                    }
                    else
                    {
                        shouldHandleGesture = false
                        return true
                    }
            }
        }
        return false
    }

    @objc private func panGestureDidMove(sender: UIPanGestureRecognizer)
    {
        guard shouldHandleGesture else { return }
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        guard let panGestureRecognizer = panGestureRecognizer else { return }

        let contentOffset = scrollView.contentOffset.y
        if contentOffset <= 0.0 &&
            expansionState == .fullHeight &&
            panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview).y != 0.0
        {
            shouldHandleGesture = true
            scrollView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
    }
}

extension StatesViewController: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return Constants.stateDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell:UITableViewCell = (statesTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) ?? UITableViewCell()) as UITableViewCell
        cell.textLabel?.text = Array(Constants.stateDictionary.values)[indexPath.row]
        return cell
    }
}

import UIKit
import Macaw
import SWXMLHash

class ViewController: UIViewController
{
    @IBOutlet private weak var svgMap: SVGView!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    
    private var pathArray = [String]()
    var previousContainerViewTopConstraint: CGFloat = 0.0
    let shadowViewAlpha: CGFloat = 0.4

    override func viewDidLoad()
    {
        super.viewDidLoad()
        registerStatesForSelection()
        svgMap.zoom.enable()
        shadowView.alpha = 0.0
        configureStatesViewController()
    }
    
    private func configureStatesViewController()
    {
         let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
         let compressedTopConstraint = view.bounds.height - compressedHeight
         containerViewTopConstraint.constant = compressedTopConstraint
         previousContainerViewTopConstraint = containerViewTopConstraint.constant

         // NB: Handle this in a more clean and production ready fashion.
         if let statesViewController = children.first as? StatesViewController
         {
             statesViewController.delegate = self
         }
     }
    
    private func registerStatesForSelection()
    {
        if let url = Bundle.main.url(forResource: "blank-us-map", withExtension: "svg")
        {
            if let xmlString = try? String(contentsOf: url)
            {
                let xml = SWXMLHash.parse(xmlString)
                enumerate(indexer: xml, level: 0)
                for case let element in pathArray
                {
                    self.registerForSelection(nodeTag: element)
                }
            }
        }
    }
    
    private func enumerate(indexer: XMLIndexer, level: Int)
    {
        for child in indexer.children
        {
            if let element = child.element
            {
                if let idAttribute = element.attribute(by: "id")
                {
                    let text = idAttribute.text
                    pathArray.append(text)
                }
            }
            enumerate(indexer: child, level: level + 1)
        }
    }
    
    private func registerForSelection(nodeTag : String)
    {
        svgMap.node.nodeBy(tag: nodeTag)?.onTap
        {
            [weak self] (touch)
            in
            let nodeShape = self?.svgMap.node.nodeBy(tag: nodeTag) as? Shape
            nodeShape?.fill = Color.blue
        }
    }
}


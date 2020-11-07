import UIKit
import Macaw
import SWXMLHash

class ViewController: UIViewController
{
    @IBOutlet private weak var svgMap: SVGView!
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet private weak var enterStateView: UIView!
    @IBOutlet private weak var enterStateTextField: UITextField!
    
    private var pathArray = [String]()
    private var selectedNode: Shape?
    var previousContainerViewTopConstraint: CGFloat = 0.0
    let shadowViewAlpha: CGFloat = 0.4

    override func viewDidLoad()
    {
        super.viewDidLoad()
        registerStatesForSelection()
        svgMap.zoom.enable()
        shadowView.alpha = 0.0
        configureStatesViewController()
        enterStateView.isHidden = true
        enterStateTextField.delegate = self
    }
    
    func toggleEnterStateView(isHidden: Bool)
    {
        isHidden ? enterStateView.fadeOut() : enterStateView.fadeIn()
    }
    
    private func configureStatesViewController()
    {
         let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
         let compressedTopConstraint = view.bounds.height - compressedHeight
         containerViewTopConstraint.constant = compressedTopConstraint
         previousContainerViewTopConstraint = containerViewTopConstraint.constant

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
            DispatchQueue.main.async
            {
                if nodeTag == "MI" { return }
                self?.selectedNode?.fill = Color.lightGray
                let newNode = self?.svgMap.node.nodeBy(tag: nodeTag) as? Shape
                if !(self?.selectedNode == newNode)
                {
                    self?.selectedNode = newNode
                    self?.selectedNode?.fill = Color.darkOrange
                    self?.toggleEnterStateView(isHidden: false)
                }
                else
                {
                    self?.selectedNode = nil
                    self?.toggleEnterStateView(isHidden: true)
                }
            }
        }
    }
    
    // TODO: - special handling for MI - grab "SP-" & "MI-" to fill as one shape
}
extension ViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        // TODO: - guard there is text in the textfield
        textField.resignFirstResponder()
        // TODO: - append the response to the array of states for that state's key
        // need to convert to pathArray dictionary
        print("TEXT: \(textField.text)")
        // TODO: - fill the state to maybe a purple color so user knows they already answered for that state
        textField.text = ""
        return true
    }
}

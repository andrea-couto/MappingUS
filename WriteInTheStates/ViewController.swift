import UIKit
import Macaw
import SWXMLHash

class ViewController: UIViewController
{
    @IBOutlet private weak var svgMap: SVGView!
    @IBOutlet private weak var enterStateView: UIView!
    @IBOutlet private weak var enterStateTextField: DropDown!
    @IBOutlet private weak var showResultsButton: UIButton!
    
    // TODO:- Need a legend at the bottom with what the colors mean
    // also add a [show results] or something that will change the user answered states to red or green based on if they are correct
    // maybe also a [show states] maybe that will overlay a state map SVG?
    
    private var pathArray = [String]()
    private var selectedNode: Shape?
    
    // TODO: - when a user selects one of these Nodes the textfield should be preFilled with their guess for state name
    private var userAnswered: [String: StateInfo] = [:]
    
    struct StateColors
    {
        static let filledInColor = Color.darkGoldenrod
        static let defaultColor = Color.lightGray
        static let selectedColor = Color.orange
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        registerStatesForSelection()
        svgMap.zoom.enable()
        enterStateTextField.optionArray = Constants.stateDictionary
        enterStateView.isHidden = true
        configureShowResultButton()
        enterStateTextField.didSelect
        {
            [weak self] (selectedStateInfo, index, id)
            in
            guard let selectedNodeTag = self?.selectedNode?.tag.first else { return }
            self?.userAnswered[selectedNodeTag] = selectedStateInfo
            DispatchQueue.main.async
            {
                self?.selectedNode?.fill = StateColors.filledInColor
                for (index, node) in Constants.stateDictionary.enumerated()
                {
                    if node.statAbbreviation == selectedNodeTag
                    {
                        var newNodeInfo = node
                        newNodeInfo.selected = true
                        Constants.stateDictionary[index] = newNodeInfo
                        self?.enterStateTextField.optionArray = Constants.stateDictionary
                        break
                    }
                }
            }
        }
    }
    
    private func configureShowResultButton()
    {
        showResultsButton.backgroundColor = .clear
        showResultsButton.layer.cornerRadius = 5
        showResultsButton.layer.borderWidth = 1
        showResultsButton.layer.borderColor = UIColor.black.cgColor
    }
    
    func toggleEnterStateView(isHidden: Bool)
    {
        isHidden ? enterStateView.fadeOut() : enterStateView.fadeIn()
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
                self?.enterStateTextField.text = ""
                if nodeTag == "MI" { return }
                let newNode = self?.svgMap.node.nodeBy(tag: nodeTag) as? Shape
                if !(self?.selectedNode == newNode)
                {
                    if self?.selectedNode?.fill == StateColors.selectedColor
                    {
                        self?.selectedNode?.fill = StateColors.defaultColor // reset previous node color
                    }
                    self?.selectedNode = newNode
                    self?.selectedNode?.fill = StateColors.selectedColor
                    self?.toggleEnterStateView(isHidden: false)
                }
                else
                {
                    self?.selectedNode?.fill = StateColors.defaultColor
                    self?.selectedNode = nil
                    self?.toggleEnterStateView(isHidden: true)
                }
            }
        }
    }
    
    @IBAction func didTapShowResults()
    {
        // TODO: - handle showing the results to the user
    }
    
    // TODO: - special handling for MI - grab "SP-" & "MI-" to fill as one shape
}

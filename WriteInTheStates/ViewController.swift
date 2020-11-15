import UIKit
import Macaw
import SWXMLHash

class ViewController: UIViewController
{
    @IBOutlet private weak var svgMap: SVGView!
    @IBOutlet private weak var enterStateView: UIView!
    @IBOutlet private weak var enterStateTextField: DropDown!
    @IBOutlet private weak var showResultsButton: UIButton!
    @IBOutlet private weak var showStateButton: UIButton!
    @IBOutlet private weak var startOverButton: UIButton!
    @IBOutlet private weak var getStartedView: UIView!
        
    private var pathArray = [String]()
    private var selectedNode: Shape?
    
    // TODO: - when a user selects one of these Nodes the textfield should be pre-filled with their guess for state name
    private var userAnswered: [String: StateInfo] = [:]
    {
        didSet
        {
            if userAnswered.count > 0
            {
                showResultsButton.isEnabled = true
                showResultsButton.alpha = 1.0
            }
        }
    }
    
    private func getAlternateMichiganShape(currentNodeTag: String) -> Shape?
    {
        var alternateMichiganShape: Shape?
        Constants.michiganTags.forEach
        {
            if $0.nodeTag == currentNodeTag
            {
                alternateMichiganShape = svgMap.node.nodeBy(tag: $0.alternateTag) as? Shape
            }
        }
        return alternateMichiganShape
    }
    
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
        configureButtons()
        
        enterStateTextField.didSelect
        {
            [weak self] (selectedStateInfo, index, id)
            in
            guard let strongSelf = self, let selectedNodeTag = strongSelf.selectedNode?.tag.first else { return }
            strongSelf.userAnswered[selectedNodeTag] = selectedStateInfo
            strongSelf.enterStateTextField.selectedArray = Array(strongSelf.userAnswered.values)
            let alternateMichiganShape = strongSelf.getAlternateMichiganShape(currentNodeTag: selectedNodeTag)
            DispatchQueue.main.async
            {
                self?.selectedNode?.fill = StateColors.filledInColor
                alternateMichiganShape?.fill = StateColors.filledInColor
            }
        }
    }
    
    private func configureButtons()
    {
        showResultsButton.backgroundColor = .clear
        showResultsButton.layer.cornerRadius = 5
        showResultsButton.layer.borderWidth = 1
        showResultsButton.layer.borderColor = UIColor.black.cgColor
        showResultsButton.isEnabled = false
        showResultsButton.alpha = 0.5
        
        startOverButton.backgroundColor = .clear
        startOverButton.layer.cornerRadius = 5
        startOverButton.layer.borderWidth = 1
        startOverButton.layer.borderColor = UIColor.black.cgColor
        
        showStateButton.backgroundColor = .clear
        showStateButton.layer.cornerRadius = 5
        showStateButton.layer.borderWidth = 1
        showStateButton.layer.borderColor = UIColor.black.cgColor
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
                self?.enterStateTextField.searchText = ""
                if nodeTag == "MI" { return }
                // if the tapped node is michigan
                let alternateMichiganShapeForTappedNode = self?.getAlternateMichiganShape(currentNodeTag: nodeTag)
                // or the last tapped node is michigan
                var alternateMichiganShapeForLastSelectedNode: Shape?
                if alternateMichiganShapeForTappedNode == nil
                {
                    alternateMichiganShapeForLastSelectedNode = self?.getAlternateMichiganShape(currentNodeTag: self?.selectedNode?.tag.first ?? "")
                }
                let newNode = self?.svgMap.node.nodeBy(tag: nodeTag) as? Shape
                if !(self?.selectedNode == newNode)
                {
                    if self?.selectedNode?.fill == StateColors.selectedColor
                    {
                        alternateMichiganShapeForLastSelectedNode?.fill = StateColors.defaultColor
                        self?.selectedNode?.fill = StateColors.defaultColor // reset previous node color
                    }
                    self?.selectedNode = newNode
                    alternateMichiganShapeForTappedNode?.fill = StateColors.selectedColor
                    self?.selectedNode?.fill = StateColors.selectedColor
                    self?.toggleEnterStateView(isHidden: false)
                    self?.getStartedView.isHidden = true
                }
                else
                {
                    alternateMichiganShapeForTappedNode?.fill = StateColors.defaultColor
                    self?.selectedNode?.fill = StateColors.defaultColor
                    self?.selectedNode = nil
                    self?.toggleEnterStateView(isHidden: true)
                }
            }
        }
    }
    
    @IBAction func didTapShowResults()
    {
        for item in userAnswered
        {
            if let node = svgMap.node.nodeBy(tag: item.key) as? Shape
            {
                let alternateMichiganShape = getAlternateMichiganShape(currentNodeTag: node.tag.first ?? "")
                if (node.tag.first == item.value.stateAbbreviation) ||
                    (alternateMichiganShape?.tag.first == item.value.stateAbbreviation)
                {
                    node.fill = Color.green
                    alternateMichiganShape?.fill = Color.green
                }
                else
                {
                    node.fill = Color.red
                    alternateMichiganShape?.fill = Color.red
                }
            }
        }
    }
    
    @IBAction func didTapShowState()
    {
        guard let selectedNode = selectedNode else { return }
        let stateInfoForSelectedNode = Constants.stateDictionary.first(where: { $0.stateAbbreviation == selectedNode.tag.first })
        enterStateTextField.text = stateInfoForSelectedNode?.stateName
        enterStateTextField.searchText = stateInfoForSelectedNode?.stateName ?? ""
    }
    
    @IBAction func didTapStartOver()
    {
        for item in userAnswered
        {
            if let node = svgMap.node.nodeBy(tag: item.key) as? Shape
            {
                let alternateMichiganShape = getAlternateMichiganShape(currentNodeTag: node.tag.first ?? "")
                node.fill = StateColors.defaultColor
                alternateMichiganShape?.fill = StateColors.defaultColor
            }
        }
        userAnswered = [:]
        selectedNode = nil
        enterStateTextField.selectedArray = []
    }
}

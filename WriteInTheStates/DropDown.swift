import UIKit

class DropDown: UITextField
{
    var arrow : Arrow!
    var table : UITableView!
    var shadow : UIView!
    
    @IBInspectable var rowHeight: CGFloat = 30
    @IBInspectable var rowBackgroundColor: UIColor = .white
    @IBInspectable var selectedRowColor: UIColor = .init(rgb: 0xC6902B)
    @IBInspectable var hideOptionsWhenSelect = true
    @IBInspectable  var isSearchEnable: Bool = true
    {
        didSet
        {
            addGesture()
        }
    }
    
    @IBInspectable var borderColor: UIColor =  UIColor.lightGray
    {
        didSet
        {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var listHeight: CGFloat = 150
    
    @IBInspectable var borderWidth: CGFloat = 0.0
    {
        didSet
        {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 5.0
    {
        didSet
        {
            layer.cornerRadius = cornerRadius
        }
    }
    
    private  var tableheightX: CGFloat = 100
    private  var dataArray = [StateInfo]()
    private  var imageArray = [String]()
    private  var parentController:UIViewController?
    private  var pointToParent = CGPoint(x: 0, y: 0)
    private var backgroundView = UIView()
    private var keyboardHeight:CGFloat = 0
    
    var optionArray = [StateInfo]()
    {
        didSet
        {
            self.dataArray = self.optionArray
        }
    }
    
    var optionIds : [Int]?
    
    var searchText = String()
    {
        didSet
        {
            if searchText == ""
            {
                self.dataArray = self.optionArray
            }
            else
            {
                self.dataArray = optionArray.filter
                {
                    return $0.stateName.range(of: searchText, options: .caseInsensitive) != nil
                }
            }
            reSizeTable()
            self.table.reloadData()
        }
    }
    
    @IBInspectable var arrowSize: CGFloat = 15
    {
        didSet
        {
            let center =  arrow.superview!.center
            arrow.frame = CGRect(x: center.x - arrowSize / 2, y: center.y - arrowSize/2, width: arrowSize, height: arrowSize)
        }
    }
    
    @IBInspectable var arrowColor: UIColor = .black
    {
        didSet
        {
            arrow.arrowColor = arrowColor
        }
    }
    
    @IBInspectable var checkMarkEnabled: Bool = true
    @IBInspectable var handleKeyboard: Bool = true
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupUI()
        self.delegate = self
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        setupUI()
        self.delegate = self
    }
    
    
    private var didSelectCompletion: (StateInfo, Int ,Int) -> () = {selectedText, index , id  in }
    private var TableWillAppearCompletion: () -> () = { }
    private var TableDidAppearCompletion: () -> () = { }
    private var TableWillDisappearCompletion: () -> () = { }
    private var TableDidDisappearCompletion: () -> () = { }
    
    func setupUI()
    {
        let size = self.frame.height
        let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        self.rightView = rightView
        self.rightViewMode = .always
        let arrowContainerView = UIView(frame: rightView.frame)
        self.rightView?.addSubview(arrowContainerView)
        let center = arrowContainerView.center
        arrow = Arrow(origin: CGPoint(x: center.x - arrowSize/2, y: center.y - arrowSize/2), size: arrowSize)
        arrowContainerView.addSubview(arrow)
        
        self.backgroundView = UIView(frame: .zero)
        self.backgroundView.backgroundColor = .clear
        addGesture()
        if isSearchEnable && handleKeyboard
        {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil)
            {
                (notification)
                in
                if self.isFirstResponder
                {
                    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
                    let keyboardFrame:NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    self.keyboardHeight = keyboardRectangle.height
                    if !self.isSelected
                    {
                        self.showList()
                    }
                }
                
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil)
            {
                (notification)
                in
                if self.isFirstResponder
                {
                    self.keyboardHeight = 0
                }
            }
        }
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    fileprivate func addGesture ()
    {
        let gesture =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        if isSearchEnable
        {
            self.rightView?.addGestureRecognizer(gesture)
        }
        else
        {
            self.addGestureRecognizer(gesture)
        }
        let gesture2 =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        self.backgroundView.addGestureRecognizer(gesture2)
    }
    
    func getConvertedPoint(_ targetView: UIView, baseView: UIView?)->CGPoint
    {
        var pnt = targetView.frame.origin
        if nil == targetView.superview
        {
            return pnt
        }
        var superView = targetView.superview
        while superView != baseView
        {
            pnt = superView!.convert(pnt, to: superView!.superview)
            if nil == superView!.superview
            {
                break
            }
            else
            {
                superView = superView!.superview
            }
        }
        return superView!.convert(pnt, to: baseView)
    }
    
    func showList()
    {
        if parentController == nil
        {
            parentController = self.parentViewController
        }
        backgroundView.frame = parentController?.view.frame ?? backgroundView.frame
        pointToParent = getConvertedPoint(self, baseView: parentController?.view)
        parentController?.view.insertSubview(backgroundView, aboveSubview: self)
        TableWillAppearCompletion()
        if listHeight > rowHeight * CGFloat( dataArray.count)
        {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }
        else
        {
            self.tableheightX = listHeight
        }
        table = UITableView(frame: CGRect(x: pointToParent.x ,
                                          y: pointToParent.y + self.frame.height ,
                                          width: self.frame.width,
                                          height: self.frame.height))
        shadow = UIView(frame: table.frame)
        shadow.backgroundColor = .clear
        
        table.dataSource = self
        table.delegate = self
        table.alpha = 0
        table.separatorStyle = .none
        table.layer.cornerRadius = 3
        table.backgroundColor = rowBackgroundColor
        table.rowHeight = rowHeight
        parentController?.view.addSubview(shadow)
        parentController?.view.addSubview(table)
        self.isSelected = true
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height+5
        if height < (keyboardHeight+tableheightX)
        {
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.9,
                       delay: 0,
                       usingSpringWithDamping: 0.4,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations:
                        {
                            () -> Void
                            in
                            
                            self.table.frame = CGRect(x: self.pointToParent.x,
                                                      y: y,
                                                      width: self.frame.width,
                                                      height: self.tableheightX)
                            self.table.alpha = 1
                            self.shadow.frame = self.table.frame
                            self.shadow.dropShadow()
                            self.arrow.position = .up
                        },
                       completion:
                        {
                            (finish) -> Void
                            in
                            self.layoutIfNeeded()
                        })
    }
    
    func hideList()
    {
        TableWillDisappearCompletion()
        UIView.animate(withDuration: 1.0,
                       delay: 0.4,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations:
                        {
                            () -> Void
                            in
                            self.table.frame = CGRect(x: self.pointToParent.x,
                                                      y: self.pointToParent.y+self.frame.height,
                                                      width: self.frame.width,
                                                      height: 0)
                            self.shadow.alpha = 0
                            self.shadow.frame = self.table.frame
                            self.arrow.position = .down
                        },
                       completion:
                        {
                            (didFinish) -> Void
                            in
                            self.shadow.removeFromSuperview()
                            self.table.removeFromSuperview()
                            self.backgroundView.removeFromSuperview()
                            self.isSelected = false
                            self.TableDidDisappearCompletion()
                        })
    }
    
    @objc func touchAction()
    {
        isSelected ?  hideList() : showList()
    }
    
    func reSizeTable()
    {
        if listHeight > rowHeight * CGFloat( dataArray.count)
        {
            self.tableheightX = rowHeight * CGFloat(dataArray.count)
        }
        else
        {
            self.tableheightX = listHeight
        }
        let height = (self.parentController?.view.frame.height ?? 0) - (self.pointToParent.y + self.frame.height + 5)
        var y = self.pointToParent.y+self.frame.height+5
        if height < (keyboardHeight+tableheightX)
        {
            y = self.pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations:
                        {
                            () -> Void
                            in
                            self.table.frame = CGRect(x: self.pointToParent.x,
                                                      y: y,
                                                      width: self.frame.width,
                                                      height: self.tableheightX)
                            self.shadow.frame = self.table.frame
                            self.shadow.dropShadow()
                        },
                       completion:
                        {
                            (didFinish) -> Void
                            in
                            self.layoutIfNeeded()
                        })
    }
    
    //MARK: Actions Methods
    func didSelect(completion: @escaping (_ selectedText: StateInfo, _ index: Int , _ id:Int ) -> ())
    {
        didSelectCompletion = completion
    }
    
    func listWillAppear(completion: @escaping () -> ())
    {
        TableWillAppearCompletion = completion
    }
    
    func listDidAppear(completion: @escaping () -> ())
    {
        TableDidAppearCompletion = completion
    }
    
    func listWillDisappear(completion: @escaping () -> ())
    {
        TableWillDisappearCompletion = completion
    }
    
    func listDidDisappear(completion: @escaping () -> ())
    {
        TableDidDisappearCompletion = completion
    }
}

//MARK: UITextFieldDelegate
extension DropDown : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        superview?.endEditing(true)
        return false
    }
    
    func  textFieldDidBeginEditing(_ textField: UITextField)
    {
        textField.text = ""
        self.dataArray = self.optionArray
        touchAction()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        return isSearchEnable
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        if string != ""
        {
            self.searchText = self.text! + string
        }
        else
        {
            let subText = self.text?.dropLast()
            self.searchText = String(subText!)
        }
        if !isSelected
        {
            showList()
        }
        return true
    }
}
///MARK: UITableViewDataSource
extension DropDown: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cellIdentifier = "DropDownCell"
        let stateInfoForCell = dataArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        cell.backgroundColor = stateInfoForCell.selected ? .lightGray : .white
        if self.imageArray.count > indexPath.row
        {
            cell.imageView!.image = UIImage(named: imageArray[indexPath.row])
        }
        let strokeEffect: [NSAttributedString.Key : Any] =
        [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        let strokeString = NSAttributedString(string: "\(stateInfoForCell.stateName)", attributes: strokeEffect)
        cell.textLabel?.attributedText = stateInfoForCell.selected ? strokeString : NSAttributedString(string: "\(stateInfoForCell.stateName)")
        
        cell.selectionStyle = .none
        cell.textLabel?.font = self.font
        cell.textLabel?.textAlignment = self.textAlignment
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = .byWordWrapping
        return cell
    }
}

//MARK: UITableViewDelegate
extension DropDown: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let selectedIndex = (indexPath as NSIndexPath).row
        let selectedText = self.dataArray[selectedIndex].stateName
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.5,
                       animations:
                        {
                            () -> Void
                            in
                            tableView.cellForRow(at: indexPath)?.alpha = 1.0
                            tableView.cellForRow(at: indexPath)?.backgroundColor = self.selectedRowColor
                        },
                       completion:
                        {
                            (didFinish) -> Void
                            in
                            self.text = "\(selectedText)"
                            tableView.reloadData()
                        })
        if hideOptionsWhenSelect
        {
            touchAction()
            self.endEditing(true)
        }
        if let selectedIndex = optionArray.firstIndex(where: {$0.stateName == selectedText})
        {
            if let id = optionIds?[selectedIndex]
            {
                didSelectCompletion(optionArray[selectedIndex], selectedIndex, id )
            }
            else
            {
                didSelectCompletion(optionArray[selectedIndex], selectedIndex, 0)
            }
        }
    }
}

//MARK: Arrow
enum Position
{
    case left
    case down
    case right
    case up
}

class Arrow: UIView
{
    let shapeLayer = CAShapeLayer()
    var arrowColor:UIColor = .black
    {
        didSet
        {
            shapeLayer.fillColor = arrowColor.cgColor
        }
    }
    
    var position: Position = .down
    {
        didSet
        {
            switch position
            {
            case .left:
                self.transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
                break
                
            case .down:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
                break
                
            case .right:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
                break
                
            case .up:
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                break
            }
        }
    }
    
    init(origin: CGPoint, size: CGFloat )
    {
        super.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        
        // Get size
        let size = self.layer.frame.width
        
        // Create path
        let bezierPath = UIBezierPath()
        
        // Draw points
        let qSize = size/4
        
        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
        bezierPath.close()
        shapeLayer.path = bezierPath.cgPath
        if #available(iOS 12.0, *)
        {
            self.layer.addSublayer (shapeLayer)
        }
        else
        {
            self.layer.mask = shapeLayer
        }
    }
}

extension UIView
{
    func dropShadow(scale: Bool = true)
    {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 1, height: 1)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func viewBorder(borderColor : UIColor, borderWidth : CGFloat?)
    {
        self.layer.borderColor = borderColor.cgColor
        if let borderWidth_ = borderWidth
        {
            self.layer.borderWidth = borderWidth_
        }
        else
        {
            self.layer.borderWidth = 1.0
        }
    }
    
    var parentViewController: UIViewController?
    {
        var parentResponder: UIResponder? = self
        while parentResponder != nil
        {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController
            {
                return viewController
            }
        }
        return nil
    }
}

import UIKit

class DropDown: UITextField
{
    var arrow : Arrow!
    var table : UITableView?
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
            dataArray = optionArray
        }
    }
    var selectedArray = [StateInfo]()
    
    var optionIds : [Int]?
    
    var searchText = String()
    {
        didSet
        {
            if searchText == ""
            {
                dataArray = optionArray
            }
            else
            {
                self.dataArray = optionArray.filter
                {
                    return $0.stateName.range(of: searchText, options: .caseInsensitive) != nil
                }
            }
            reSizeTable()
            table?.reloadData()
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
        delegate = self
    }
    
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)!
        setupUI()
        delegate = self
    }
    
    
    private var didSelectCompletion: (StateInfo, Int ,Int) -> () = {selectedText, index , id  in }
    private var TableWillAppearCompletion: () -> () = { }
    private var TableDidAppearCompletion: () -> () = { }
    private var TableWillDisappearCompletion: () -> () = { }
    private var TableDidDisappearCompletion: () -> () = { }
    
    func setupUI()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        let size = frame.height
        let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: size, height: size))
        self.rightView = rightView
        self.rightViewMode = .always
        let arrowContainerView = UIView(frame: rightView.frame)
        self.rightView?.addSubview(arrowContainerView)
        let center = arrowContainerView.center
        arrow = Arrow(origin: CGPoint(x: center.x - arrowSize/2, y: center.y - arrowSize/2), size: arrowSize)
        arrowContainerView.addSubview(arrow)
        
        backgroundView = UIView(frame: .zero)
        backgroundView.backgroundColor = .clear
        addGesture()
        if isSearchEnable && handleKeyboard
        {
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil)
            {
                [weak self] (notification)
                in
                if self?.isFirstResponder ?? false
                {
                    let userInfo:NSDictionary = notification.userInfo! as NSDictionary
                    let keyboardFrame:NSValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                    let keyboardRectangle = keyboardFrame.cgRectValue
                    self?.keyboardHeight = keyboardRectangle.height
                    if !(self?.isSelected ?? false)
                    {
                        self?.showList()
                    }
                }
                
            }
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil)
            {
                [weak self] (notification)
                in
                if self?.isFirstResponder ?? false
                {
                    self?.keyboardHeight = 0
                }
            }
        }
    }
    
    @objc func deviceRotated()
    {
        if table != nil
        {
            hideList()
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
            rightView?.addGestureRecognizer(gesture)
        }
        else
        {
            addGestureRecognizer(gesture)
        }
        let gesture2 =  UITapGestureRecognizer(target: self, action:  #selector(touchAction))
        backgroundView.addGestureRecognizer(gesture2)
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
            parentController = parentViewController
        }
        backgroundView.frame = parentController?.view.frame ?? backgroundView.frame
        pointToParent = getConvertedPoint(self, baseView: parentController?.view)
        parentController?.view.insertSubview(backgroundView, aboveSubview: self)
        TableWillAppearCompletion()
        if listHeight > rowHeight * CGFloat( dataArray.count)
        {
            tableheightX = rowHeight * CGFloat(dataArray.count)
        }
        else
        {
            tableheightX = listHeight
        }
        let table = UITableView(frame: CGRect(x: pointToParent.x ,
                                          y: pointToParent.y + self.frame.height ,
                                          width: frame.width,
                                          height: frame.height))
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
        isSelected = true
        let height = (parentController?.view.frame.height ?? 0) - (pointToParent.y + frame.height + 5)
        var y = pointToParent.y + frame.height+5
        if height < (keyboardHeight+tableheightX)
        {
            y = pointToParent.y - tableheightX
        }
        self.table = table
        UIView.animate(withDuration: 0.3,
                       animations:
                        {
                            [weak self] () -> Void
                            in
                            guard let strongSelf = self else { return }
                            strongSelf.table?.frame = CGRect(x: strongSelf.pointToParent.x,
                                                             y: y,
                                                             width: strongSelf.frame.width,
                                                             height: strongSelf.tableheightX)
                            strongSelf.table?.alpha = 1
                            strongSelf.shadow.frame = strongSelf.table?.frame ?? .zero
                            strongSelf.shadow.dropShadow()
                            strongSelf.arrow.position = .up
                        },
                       completion:
                        {
                            [weak self] (finish) -> Void
                            in
                            self?.layoutIfNeeded()
                        })
    }
    
    func hideList()
    {
        TableWillDisappearCompletion()
        UIView.animate(withDuration: 0.3,
                       animations:
                        {
                            [weak self] () -> Void
                            in
                            guard let strongSelf = self else { return }
                            strongSelf.table?.frame = CGRect(x: strongSelf.pointToParent.x,
                                                            y: strongSelf.pointToParent.y + strongSelf.frame.height,
                                                            width: strongSelf.frame.width,
                                                            height: 0)
                            strongSelf.shadow.alpha = 0
                            strongSelf.shadow.frame = strongSelf.table?.frame ?? .zero
                            strongSelf.arrow.position = .down
                        },
                       completion:
                        {
                            (didFinish) -> Void
                            in
                            self.shadow.removeFromSuperview()
                            self.table?.removeFromSuperview()
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
        guard table != nil else { return }
        if listHeight > rowHeight * CGFloat( dataArray.count)
        {
            tableheightX = rowHeight * CGFloat(dataArray.count)
        }
        else
        {
            tableheightX = listHeight
        }
        let height = (parentController?.view.frame.height ?? 0) - (pointToParent.y + frame.height + 5)
        var y = pointToParent.y + frame.height+5
        if height < (keyboardHeight+tableheightX)
        {
            y = pointToParent.y - tableheightX
        }
        UIView.animate(withDuration: 0.2,
                       delay: 0.1,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseInOut,
                       animations:
                        {
                            [weak self] () -> Void
                            in
                            guard let strongSelf = self else { return }
                            strongSelf.table?.frame = CGRect(x: strongSelf.pointToParent.x,
                                                             y: y,
                                                             width: strongSelf.frame.width,
                                                             height: strongSelf.tableheightX)
                            strongSelf.shadow.frame = strongSelf.table?.frame ?? .zero
                            strongSelf.shadow.dropShadow()
                        },
                       completion:
                        {
                            [weak self] (didFinish) -> Void
                            in
                            self?.layoutIfNeeded()
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
            searchText = text! + string
        }
        else
        {
            let subText = text?.dropLast()
            searchText = String(subText!)
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
        cell.backgroundColor = selectedArray.contains(where: { $0.stateName == stateInfoForCell.stateName }) ? .lightGray : .white
        if imageArray.count > indexPath.row
        {
            cell.imageView!.image = UIImage(named: imageArray[indexPath.row])
        }
        let strokeEffect: [NSAttributedString.Key : Any] =
        [
            NSAttributedString.Key.strikethroughStyle: NSUnderlineStyle.single.rawValue
        ]
        let strokeString = NSAttributedString(string: "\(stateInfoForCell.stateName)", attributes: strokeEffect)
        cell.textLabel?.attributedText = selectedArray.contains(where: { $0.stateName == stateInfoForCell.stateName }) ? strokeString : NSAttributedString(string: "\(stateInfoForCell.stateName)")
        cell.textLabel?.textColor = .black        
        cell.selectionStyle = .none
        cell.textLabel?.font = font
        cell.textLabel?.textAlignment = textAlignment
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
        let selectedText = dataArray[selectedIndex].stateName
        tableView.cellForRow(at: indexPath)?.alpha = 0
        UIView.animate(withDuration: 0.5,
                       animations:
                        {
                            [weak self] () -> Void
                            in
                            tableView.cellForRow(at: indexPath)?.alpha = 1.0
                            tableView.cellForRow(at: indexPath)?.backgroundColor = self?.selectedRowColor
                        },
                       completion:
                        {
                            [weak self] (didFinish) -> Void
                            in
                            self?.text = "\(selectedText)"
                            tableView.reloadData()
                        })
        if hideOptionsWhenSelect
        {
            touchAction()
            endEditing(true)
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
                transform = CGAffineTransform(rotationAngle: -CGFloat.pi/2)
            case .down:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi*2)
            case .right:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi/2)
            case .up:
                transform = CGAffineTransform(rotationAngle: CGFloat.pi)
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
        let size = layer.frame.width
        let bezierPath = UIBezierPath()
        let qSize = size/4
        bezierPath.move(to: CGPoint(x: 0, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size, y: qSize))
        bezierPath.addLine(to: CGPoint(x: size/2, y: qSize*3))
        bezierPath.addLine(to: CGPoint(x: 0, y: qSize))
        bezierPath.close()
        shapeLayer.path = bezierPath.cgPath
        if #available(iOS 12.0, *)
        {
            layer.addSublayer (shapeLayer)
        }
        else
        {
            layer.mask = shapeLayer
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
        layer.borderColor = borderColor.cgColor
        if let borderWidth_ = borderWidth
        {
            layer.borderWidth = borderWidth_
        }
        else
        {
            layer.borderWidth = 1.0
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

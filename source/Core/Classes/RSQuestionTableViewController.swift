//
//  RSQuestionTableViewController.swift
//  Pods
//
//  Created by James Kizer on 4/6/17.
//
//

import UIKit
import ResearchKit

public protocol RSQuestionTableViewControllerAdaptor: UITableViewDataSource, UITableViewDelegate {
    func configure(tableView: UITableView)
}

open class RSQuestionTableViewController: ORKStepViewController, RSQuestionTableViewControllerAdaptor {
    
//, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var textLabel: UILabel!
    @IBOutlet weak var topPaddingView: UIView!
    @IBOutlet weak var bottomPaddingView: UIView!
    @IBOutlet public weak var skipButton: RSLabelButton!
    @IBOutlet public weak var continueButton: RSBorderedButton!
    @IBOutlet public weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIStackView!
    @IBOutlet weak var footerContainer: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!

    var rawFooterHeight: CGFloat?
    
    var tableViewStep: RSQuestionTableViewStep?
    var border: CALayer?
    open var adaptor: RSQuestionTableViewControllerAdaptor!
    
    open var skipped = false
    
    override convenience init(step: ORKStep?) {
        self.init(step: step, result: nil)
    }
    
    override convenience init(step: ORKStep?, result: ORKResult?) {
        
        let framework = Bundle(for: RSQuestionTableViewController.self)
        self.init(nibName: "RSQuestionTableViewController", bundle: framework)
        self.step = step
        self.restorationIdentifier = step!.identifier
        
        self.adaptor = self.createAdaptor(viewController: self, step: step, result: result)
    }
    
    deinit {
        self.adaptor = nil
    }
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()

        assert(self.step is RSStep)
        
        let step = self.step as! RSStep
        
        self.titleLabel.text = step.title
        self.textLabel.text = step.text
        
        if let attributedTitle = step.attributedTitle {
            self.titleLabel.attributedText = attributedTitle
        }
        
        if let attributedText = step.attributedText {
            self.textLabel.attributedText = attributedText
        }
        
        if let buttonText = step.buttonText {
            self.setContinueButtonTitle(
                title: NSLocalizedString(buttonText, comment: "")
            )
        }
        else {
            let title = NSLocalizedString(
                self.hasNextStep() ? "Next" : "Done",
                comment: ""
            )
            self.continueButton.setTitle(title, for: .normal)
        }

        self.skipButton.isHidden = !step.isOptional
        
        self.skipButton.isHidden = !step.isOptional
        
        if let skipButtonText = step.skipButtonText {
            self.setSkipButtonTitle(
                title: NSLocalizedString(skipButtonText, comment: "")
            )
        }
        else {
            self.setSkipButtonTitle(
                title: NSLocalizedString("Skip this question", comment: "")
            )
        }
        
        //hold this strongly
        
        self.tableView.dataSource = self.adaptor
        self.tableView.delegate = self.adaptor
        self.adaptor.configure(tableView: self.tableView)
        
    }
    
    open func createAdaptor(viewController: RSQuestionTableViewController, step: ORKStep?, result: ORKResult?) -> RSQuestionTableViewControllerAdaptor {
        return self
    }
    
    open func configure(tableView: UITableView) {
        
    }
    
    open func updateHeader(width: CGFloat) {
        self.titleLabel.invalidateIntrinsicContentSize()
        self.textLabel.invalidateIntrinsicContentSize()
        
        let titleSize = self.titleLabel.sizeThatFits(CGSize(width: self.titleLabel.bounds.width, height: CGFloat(MAXFLOAT)))
        let textSize = self.textLabel.sizeThatFits(CGSize(width: self.textLabel.bounds.width, height: CGFloat(MAXFLOAT)))
        
        let header: UIView = self.tableView.tableHeaderView!
        
        header.frame.size.height =
            titleSize.height +
            textSize.height +
            self.topPaddingView.frame.height +
            self.bottomPaddingView.frame.height

        if let border = self.border {
            border.removeFromSuperlayer()
        }
        
        //add bottom border to header
        let border:CALayer = CALayer()
        border.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
        border.borderWidth = 1.0
        border.frame = CGRect(x: 0, y:header.frame.height-1, width: header.frame.width, height: 0.5)
        
        self.border = border
        header.layer.addSublayer(border)
        
        self.tableView.tableHeaderView = header
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if self.step?.title == nil {
            self.titleLabel.frame.size.height = 0
        }
        
        if self.step?.text == nil {
            self.textLabel.frame.size.height = 0
        }
        
        self.updateHeader(width: self.view.frame.size.width)
        
        
        if let footer = self.tableView.tableFooterView {
            //add top boarder to header
            let topBorder:CALayer = CALayer()
            topBorder.borderColor = UIColor(white: 0.8, alpha: 1.0).cgColor
            topBorder.borderWidth = 1.0
            topBorder.frame = CGRect(x: 0, y:0, width: footer.frame.width, height: 0.5)
            
            footer.layer.addSublayer(topBorder)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }

    
    override open func viewWillLayoutSubviews() {
        self.updateHeader(width: self.view.frame.width)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        super.viewWillDisappear(animated)
    }
    
    open func setSkipButtonTitle(title: String) {
        self.skipButton.setTitle(title, for: .normal)
    }
    
    open func setContinueButtonTitle(title: String) {
        self.continueButton.setTitle(title, for: .normal)
    }
    
    //Note that we want the table view to be as large as the screen,
    //should return one more than actual data source
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    @objc open func keyboardWillShow(notification: NSNotification) {
        
        if let userInfo = notification.userInfo,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.intValue,
            let keyboardFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {

            let internalKeyboardFrameEnd = self.view.convert(keyboardFrameEnd, from: nil)
            let curveOption = UIView.AnimationOptions.init(rawValue: UInt(curve))

            UIView.animate(withDuration: duration, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState, curveOption], animations: { [unowned self] in
                
                self.tableViewBottomConstraint.constant = internalKeyboardFrameEnd.size.height
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
        
        
    }
    
    @objc open func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let curve = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.intValue {
            let curveOption = UIView.AnimationOptions.init(rawValue: UInt(curve))
            
            UIView.animate(withDuration: duration, delay: 0, options: [UIView.AnimationOptions.beginFromCurrentState, curveOption], animations: { [unowned self] in
                
                self.tableViewBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
                
            }, completion: nil)
            
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "default")
        cell.textLabel?.text = "Default Cell"
        cell.detailTextLabel?.text = "You should override cellForRowAt"
        
//        printResponderChain(self)
        
        return cell
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
//        printResponderChain(self)
    }

//    open func printResponderChain(_ responder: UIResponder?) {
//        
//        guard let responder = responder else {
//            return
//        }
//        
//        print("responder is \(responder)")
//        printResponderChain(responder.next)
//    }
    
    open func clearAnswer() {
        self.skipped = true
        self.tableView.indexPathsForSelectedRows?.forEach( { indexPath in
            self.tableView.deselectRow(at: indexPath, animated: false)
        })
    }
    
    open func notifyDelegateAndMoveForward() {
        if let delegate = self.delegate {
            delegate.stepViewControllerResultDidChange(self)
        }
        self.goForward()
    }

    open func validate() -> Bool {
        return true
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        if self.validate() {
            self.notifyDelegateAndMoveForward()
        }
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        self.clearAnswer()
        self.notifyDelegateAndMoveForward()
    }
    
    override open var result: ORKStepResult? {
        
        return super.result
        
    }
    
    
    
    
}

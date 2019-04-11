//
//  FeedbackView.swift
//  iosApp
//
//  Created by Kevin Schildhorn on 4/4/19.
//  Copyright © 2019 Kevin Galligan. All rights reserved.
//

import UIKit
import main

protocol FeedbackDialogDelegate{
    func finishedFeedback(sessionId:String, rating:Int, comment: String)
}

public enum FeedbackRating {
    case good
    case ok
    case bad
}

class FeedbackView: UIView, FeedbackInteractionDelegate {
    
    private var alertViewController: FeedbackAlertViewController?
    private var commentView: FeedbackCommentSubView?
    private var ratingView: FeedbackRatingSubView?
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var baseView: UIView!
    
    private let animationTime = 0.4
    
    private var sessionId:Int?
    private var rating:FeedbackRating?
    private var comments:String?
    
    // MARK: - Initialization
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initRatingView()
        initCommentView()
        doneButton.isEnabled = false
        doneButton.backgroundColor = UIColor.lightGray
    }
    
    public static func createFeedbackView() -> FeedbackView? {
        var feedbackView: FeedbackView?
        var commentView: FeedbackCommentSubView?
        var ratingView: FeedbackRatingSubView?
        
        let nibName = "FeedbackView"
        let views = Bundle.main.loadNibNamed(nibName, owner: nil, options: nil)!
        for v in views{
            if let fView = v as? FeedbackView {
                feedbackView = fView
            }else if let cView = v as? FeedbackCommentSubView {
                commentView = cView
            }else if let sView = v as? FeedbackRatingSubView {
                ratingView = sView
            }
        }
        feedbackView?.commentView = commentView
        feedbackView?.ratingView = ratingView
        return feedbackView
    }

    public func setAlertView(alertView: FeedbackAlertViewController) {
        alertViewController = alertView
    }
    
    private func initRatingView() {
        ratingView?.setFeedbackHandler(handler: self)
        addFeedbackSubview(ratingView,hidden: false)
    }
    
    private func initCommentView() {
        addFeedbackSubview(commentView,hidden: true)
    }
    
    private func addFeedbackSubview(_ v:UIView?,hidden:Bool){
        if let realSelectionView = v {
            if !realSelectionView.isDescendant(of: baseView) {
                baseView.addSubview(realSelectionView)
                
                let x = hidden ? baseView.frame.width : 0
                realSelectionView.frame = CGRect(x: x,y: 0,width: baseView.frame.width,height: baseView.frame.height)
            }
        }
    }
    
    
    
    public func setSessionInfo(sessionId: Int,sessionTitle:String){
        self.sessionId = sessionId
        ratingView?.setSessionTitle(title: sessionTitle)
    }
    
    // MARK: - Interaction

    private func finishAndClose(){
        comments = commentView?.getComment()
        alertViewController?.closeWithFeedback(sessionId: String(sessionId!),rating: rating!,comments: comments!)
    }
    
    @IBAction func BackButtonPressed(_ sender: Any) {
        alertViewController?.close()
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishAndClose()
    }
    
    internal func feedbackSelected(rating:FeedbackRating){
        self.rating = rating
        doneButton.isEnabled = true
        doneButton.backgroundColor = UIColor.blue

    }
    
    internal func requestCommentView(){
        showCommentView()
    }
    
    
    
    // MARK: - Showing SubViews
    
    private func showCommentView(){
        animateOut(ratingView!)
        animateIn(commentView!)
    }
    
    func animateIn(_ v:UIView) {
        v.frame.origin.x = v.frame.width
        
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut, animations: {
            v.frame.origin.x = 0
        },completion: { finished in
            if finished {
                self.commentView?.setFocus()
            }
        })
    }
    
    func animateOut(_ v:UIView) {
        
        UIView.animate(withDuration: animationTime, delay: 0, options: .curveEaseInOut, animations: {
            v.frame.origin.x -= v.frame.width
        })
    }
}

protocol FeedbackInteractionDelegate {
    func feedbackSelected(rating:FeedbackRating)
    func requestCommentView()
}



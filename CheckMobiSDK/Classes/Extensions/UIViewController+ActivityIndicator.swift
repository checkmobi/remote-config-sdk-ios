//
//  UIViewController+ActivityIndicator.swift
//  CheckMobiSDK
//
//  Copyright (c) 2019 checkmobi. All rights reserved.
//

import Foundation
import UIKit

fileprivate let overlayViewTag = 999
fileprivate let activityIndicatorTag = 1000

extension UIViewController {
    public func displayActivityIndicator(shouldDisplay: Bool) -> Void {
        if shouldDisplay {
            setActivityIndicator()
        } else {
            removeActivityIndicator()
        }
    }
    
    private func setActivityIndicator() -> Void {
        guard !isDisplayingActivityIndicatorOverlay() else { return }
        guard let parentViewForOverlay = navigationController?.view ?? view else { return }
        
        //configure overlay
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.5
        overlay.tag = overlayViewTag
        
        //configure activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = activityIndicatorTag
        
        //add subviews
        overlay.addSubview(activityIndicator)
        parentViewForOverlay.addSubview(overlay)
        
        //add overlay constraints
        if #available(iOS 9.0, *) {
            overlay.heightAnchor.constraint(equalTo: parentViewForOverlay.heightAnchor).isActive = true
        }
        if #available(iOS 9.0, *) {
            overlay.widthAnchor.constraint(equalTo: parentViewForOverlay.widthAnchor).isActive = true
        }
        
        //add indicator constraints
        if #available(iOS 9.0, *) {
            activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        }
        if #available(iOS 9.0, *) {
            activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
        }
        activityIndicator.startAnimating()
    }
    
    private func removeActivityIndicator() -> Void {
        let activityIndicator = getActivityIndicator()
        
        if let overlayView = getOverlayView() {
            UIView.animate(withDuration: 0.2, animations: {
                overlayView.alpha = 0.0
                activityIndicator?.stopAnimating()
            }) { (finished) in
                activityIndicator?.removeFromSuperview()
                overlayView.removeFromSuperview()
            }
        }
    }
    
    private func isDisplayingActivityIndicatorOverlay() -> Bool {
        if let _ = getActivityIndicator(), let _ = getOverlayView() {
            return true
        }
        return false
    }
    
    private func getActivityIndicator() -> UIActivityIndicatorView? {
        return (navigationController?.view.viewWithTag(activityIndicatorTag) ?? view.viewWithTag(activityIndicatorTag)) as? UIActivityIndicatorView
    }
    
    private func getOverlayView() -> UIView? {
        return navigationController?.view.viewWithTag(overlayViewTag) ?? view.viewWithTag(overlayViewTag)
    }
}

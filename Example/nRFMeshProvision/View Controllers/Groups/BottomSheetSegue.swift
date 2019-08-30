//
//  BottomSheetSegue.swift
//  nRFMeshProvision_Example
//
//  Created by Aleksander Nowakowski on 29/08/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit

class BottomSheetSegue: UIStoryboardSegue {

    private var selfRetainer: BottomSheetSegue? = nil
    
    override func perform() {
        selfRetainer = self
        destination.transitioningDelegate = self
        destination.modalPresentationStyle = .overCurrentContext
        // To display the BottomSheet above the TabBar, present
        // the sheet from the TabBarController itself.
        let tabBarController = source.navigationController?.parent
        tabBarController?.present(destination, animated: true)
    }
}

extension BottomSheetSegue: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return Presenter()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        selfRetainer = nil
        return Dismisser()
    }
    
}

extension BottomSheetSegue {
    
    private class Presenter: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.5
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let toView = transitionContext.view(forKey: .to)!
            let toViewController = transitionContext.viewController(forKey: .to)!
            let fromViewController = transitionContext.viewController(forKey: .from)!
            
            // Configure the layout.
            do {
                toView.translatesAutoresizingMaskIntoConstraints = false
                container.addSubview(toView)
                
                if #available(iOS 11.0, *) {
                    container.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: 0).isActive = true
                    container.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0).isActive = true
                    container.safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0).isActive = true
                } else {
                    container.bottomAnchor.constraint(equalTo: toView.bottomAnchor, constant: 0).isActive = true
                    container.leadingAnchor.constraint(equalTo: toView.leadingAnchor, constant: 0).isActive = true
                    container.trailingAnchor.constraint(equalTo: toView.trailingAnchor, constant: 0).isActive = true
                }
                
                if let navigationController = toViewController as? UINavigationController,
                    let bottomSheet = navigationController.topViewController as? BottomSheetViewController {
                    let navBarHeight = navigationController.navigationBar.frame.height
                    let subtitleCellHeight = 56
                    let itemsCount = min(5, bottomSheet.models.count)
                    let height = navBarHeight + CGFloat(itemsCount * subtitleCellHeight)
                    toView.heightAnchor.constraint(equalToConstant: height).isActive = true
                } else {
                    // Respect `toViewController.preferredContentSize.height` if non-zero.
                    if toViewController.preferredContentSize.height > 0 {
                        toView.heightAnchor.constraint(equalToConstant: toViewController.preferredContentSize.height).isActive = true
                    }
                }
            }
            
            // Apply some styling.
            do {
                toView.layer.masksToBounds = true
                toView.layer.cornerRadius = 20
                if #available(iOS 11.0, *) {
                    if container.safeAreaInsets.bottom == 0 {
                        toView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                    }
                }
            }
            
            // Perform the animation.
            do {
                container.layoutIfNeeded()
                let originalOriginY = toView.frame.origin.y
                toView.frame.origin.y += container.frame.height - toView.frame.minY
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0, options: [], animations: {
                    toView.frame.origin.y = originalOriginY
                    fromViewController.view.alpha = 0.5
                }) { completed in
                    transitionContext.completeTransition(completed)
                }
            }
        }
    }

    private class Dismisser: NSObject, UIViewControllerAnimatedTransitioning {
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.2
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let container = transitionContext.containerView
            let fromView = transitionContext.view(forKey: .from)!
            let toViewController = transitionContext.viewController(forKey: .to)!
            
            UIView.animate(withDuration: 0.2, animations: {
                fromView.frame.origin.y += container.frame.height - fromView.frame.minY
                toViewController.view.alpha = 1.0
            }) { completed in
                transitionContext.completeTransition(completed)
            }
        }
    }
    
}
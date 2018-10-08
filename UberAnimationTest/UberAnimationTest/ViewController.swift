//
//  ViewController.swift
//  UberAnimationTest
//
//  Created by 李家斌 on 2018/10/8.
//  Copyright © 2018 李家斌. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    fileprivate var rootViewController: UIViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSplashViewController()
//        showSplashViewControllerNoPing()
    }

    func showSplashViewControllerNoPing() {
        if rootViewController is SplashViewController {
            return
        }
        
        rootViewController?.willMove(toParent: nil)
        rootViewController?.removeFromParent()
        rootViewController?.view.removeFromSuperview()
        rootViewController?.didMove(toParent: nil)
        
        let splashViewController = SplashViewController(tileViewFileName: "Chimes")
        rootViewController = splashViewController
        splashViewController.pulsing = true
        
        splashViewController.willMove(toParent: self)
        addChild(splashViewController)
        view.addSubview(splashViewController.view)
        splashViewController.didMove(toParent: self)
    }
    
    func showSplashViewController() {
        showSplashViewControllerNoPing()
        
        delay(3.00) {
            self.showMenuNavigationViewController()
        }
    }
    
    /// Displays the MapViewController
    func showMenuNavigationViewController() {
        guard !(rootViewController is MenuNavigationViewController) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nav =  storyboard.instantiateViewController(withIdentifier: "MenuNavigationController") as! UINavigationController
        nav.willMove(toParent: self)
        addChild(nav)
        
        if let rootViewController = self.rootViewController {
            self.rootViewController = nav
            rootViewController.willMove(toParent: nil)
            
            transition(from: rootViewController, to: nav, duration: 0.55, options: [.transitionCrossDissolve, .curveEaseOut], animations: { () -> Void in
                
            }, completion: { _ in
                nav.didMove(toParent: self)
                rootViewController.removeFromParent()
                rootViewController.didMove(toParent: nil)
            })
        } else {
            rootViewController = nav
            view.addSubview(nav.view)
            nav.didMove(toParent: self)
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        switch rootViewController  {
        case is SplashViewController:
            return true
        case is MenuNavigationViewController:
            return false
        default:
            return false
        }
    }
}


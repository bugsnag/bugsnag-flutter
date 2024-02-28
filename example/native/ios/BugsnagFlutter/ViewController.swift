//
//  ViewController.swift
//  BugsnagFlutter
//

import Flutter
import UIKit

class ViewController: UIViewController {
    
    @IBAction func showFlutter() {
        let viewController = FlutterViewController(engine: flutterEngine, nibName: nil, bundle: nil) 
        present(viewController, animated: true, completion: nil)
    }
    
    @IBAction func unhandledError() {
        fatalError("oops!")
    }
}

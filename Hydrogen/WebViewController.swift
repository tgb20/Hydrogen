//
//  WebViewController.swift
//  Hydrogen
//
//  Created by Jacob Bashista on 10/27/17.
//  Copyright © 2017 Jacob Bashista. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    @IBOutlet weak var linkWebView: WKWebView!
    
    var urlString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let urlToUse = URL(string: urlString)
        let request = URLRequest(url: urlToUse!)
        linkWebView.load(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

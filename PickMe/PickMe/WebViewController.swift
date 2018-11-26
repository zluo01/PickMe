//
//  WebViewController.swift
//  PickMe
//
//  Created by ShaneTong on 11/25/18.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    var urlString:String?
    var webView:WKWebView?
    
    override func loadView() {
        super.loadView()
        self.webView = WKWebView()
        self.view = self.webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let myUrl = URL(string: urlString!)!
        let myURLRequest = URLRequest(url: myUrl)
        webView!.load(myURLRequest)
        // Do any additional setup after loading the view.
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

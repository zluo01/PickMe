//
//  singleCourseDetails.swift
//  PickMe
//
//  Created by Alan zhang on 2018/11/23.
//  Copyright © 2018 z.luo. All rights reserved.
//

import UIKit

class SingleCourseDetails: UIViewController {
    
    @IBOutlet weak var courseId: UILabel!
    @IBOutlet weak var courseTitle: UILabel!
    @IBOutlet weak var courseDes: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //var course : String!
    var details : [String: String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        courseId.text = details["course_code"]
        courseTitle.text = details["title"]
        courseDes.text = details["description"]
        
        courseId.sizeToFit()
        courseTitle.sizeToFit()
        courseDes.sizeToFit()
        
        scrollView.contentLayoutGuide.bottomAnchor.constraint(equalTo: courseDes.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

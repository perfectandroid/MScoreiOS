//
//  FAQStruct.swift
//  mScoreNew
//
//  Created by Perfect on 06/11/19.
//  Copyright © 2019 PSS. All rights reserved.
//

import Foundation

struct faqStruct
{
    var questions: String!
    var answers:String!
    var expanded:Bool!
    init(questions:String,answers:String,expanded:Bool)
    {
        self.questions = questions
        self.answers = answers
        self.expanded = expanded
    }
}

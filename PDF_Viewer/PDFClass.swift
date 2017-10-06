//
//  PDFClass.swift
//  PDF_Viewer
//
//  Created by Caleb Mitchell on 26/09/17.
//  Copyright © 2017 Caleb Mitchell. All rights reserved.
//

import Foundation
import Quartz


public class PDFClass: PDFDocument {
    
    // Declaring variables
    public var bookmarks: [String]
    public var notes: [Int: String]
    
    
    
    override init(){
        bookmarks = Array()
        notes = [Int: String]()
        super.init()
    }
    
    override init?(url: URL){
        bookmarks = Array()
        notes = [Int: String]()
        super.init(url: url)
    }
    
}

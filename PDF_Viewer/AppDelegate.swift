//
//  AppDelegate.swift
//  PDF_Viewer
//
//  Created by Caleb Mitchell on 26/09/17.
//  Copyright © 2017 Caleb Mitchell. All rights reserved.
//

import Cocoa
import Quartz


// https://stackoverflow.com/questions/28008262/detailed-instruction-on-use-of-nsopenpanel
extension NSOpenPanel {
    var selectURL: [URL]? {
        allowedFileTypes = ["pdf"]
        allowsMultipleSelection = true
        canChooseDirectories = false
        canChooseFiles = true
        return runModal() == NSFileHandlingPanelOKButton ? urls : nil
    }
}


@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    // Outlets linked to GUI elements
    @IBOutlet weak var appWindow: NSWindow!
    @IBOutlet weak var thePDF: PDFView!
    @IBOutlet weak var zoomInButton: NSButton!
    @IBOutlet weak var zoomOutButton: NSButton!
    @IBOutlet weak var resetButton: NSButton!

    
    
    // Local variables
    internal var pdf: PDFDocument
    internal var documents: [PDFClass] = Array<PDFClass>()
    internal var currentPage: Int
    internal var pdfCount: Int
    internal var currentDoc: Int
    internal var exists: Bool
    internal var searchNumber: Int
    internal var searchValues = [AnyObject]()
    
    
    // Initialisation of local variables
    override init(){
        pdf = PDFClass()
        documents = Array()
        currentPage = 1
        pdfCount = 0
        currentDoc = 0
        exists = false
        searchNumber = 0
        searchValues = Array()
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
    @IBAction func openPDF(sender: NSMenuItem) {
        if let url = NSOpenPanel().selectURL {
            thePDF.document = PDFClass(url: url.first!)
            updateWindow(sender: thePDF.document!)
        }
    }
    
    // Updates title of the window
    func updateWindow(sender: PDFDocument){
        appWindow.title = sender.documentURL!.lastPathComponent
    }
    
    
    
    // Zoom in action
    @IBAction func zoomIn(_ sender: NSButton) {
        self.thePDF.zoomIn(sender)
    }
    
    // Zoom out action
    @IBAction func zoomOut(_ sender: NSButton) {
        self.thePDF.zoomOut(sender)
    }
    
    // Reset zoom
    @IBAction func resetZoom(_ sender: NSButton) {
        self.thePDF.autoScales = true
    }
    
    
}



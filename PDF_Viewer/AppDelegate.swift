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
    @IBOutlet weak var prevPage: NSButton!
    @IBOutlet weak var nextPage: NSButton!
    @IBOutlet weak var goToPage: NSTextField!
    @IBOutlet weak var pageNumberField: NSTextField!
    @IBOutlet weak var chooseDocBox: NSComboBox!

    
    
    // Local variables
    internal var pdf: PDFDocument
    internal var documents: [PDFClass] = Array<PDFClass>()
    internal var currentPage: Int
    internal var pdfCount: Int
    internal var currentDoc: Int
    internal var documentOpen: Bool
    internal var searchNumber: Int
    internal var searchValues = [AnyObject]()
    
    
    // Initialisation of local variables
    override init(){
        pdf = PDFClass()
        documents = Array()
        currentPage = 1
        pdfCount = 0
        currentDoc = 0
        documentOpen = false
        searchNumber = 0
        searchValues = Array()
    }
    
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    

    
    // Updates title of the window
    func updateWindow(sender: PDFDocument){
        appWindow.title = sender.documentURL!.lastPathComponent
    }
    
    
    
    //
    //  Action functions for UI objects
    //
    
    // Open documents and start a timer to update page number
    @IBAction func openPDF(sender: NSMenuItem) {
        if let urls = NSOpenPanel().selectURL {
            // update page number every 0.1 seconds
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePageNumber), userInfo: nil, repeats: true)
            thePDF.document = PDFClass(url: urls.first!)
            documentOpen = true
            for doc in urls{
                chooseDocBox.addItem(withObjectValue: doc.lastPathComponent)
                documents.append(PDFClass(url: doc)!)
            }
            chooseDocBox.stringValue = (urls.first?.lastPathComponent)!
        }
    }
    
    // Zoom in action
    @IBAction func zoomIn(_ sender: NSButton) {
        self.thePDF.zoomIn(sender)
    }
    
    // Zoom out action
    @IBAction func zoomOut(_ sender: NSButton) {
        self.thePDF.zoomOut(sender)
    }
    
    // Fits the document view to screen
    @IBAction func resetZoom(_ sender: NSButton) {
        self.thePDF.autoScales = true
    }
    
    // Goes to the previous page
    @IBAction func goToPrevPage(_ sender: NSButton) {
        if(thePDF.canGoToPreviousPage()) {
            thePDF.goToPreviousPage(appWindow)
        }
    }
    
    // Goes to the next page
    @IBAction func goToNextPage(_ sender: NSButton) {
        if(thePDF.canGoToNextPage()) {
            thePDF.goToNextPage(appWindow)
        }
    }
    
    // Goes to page number entered
    @IBAction func goToPageChoice(_ sender: NSTextField) {
        if documentOpen && goToPage.stringValue != ""{
            if let choice = Int(goToPage.stringValue) {
                thePDF.go(to: (thePDF.document?.page(at: choice - 1))!)
                goToPage.stringValue = ""
            }
        }
    }
    @IBAction func PDFSelect(_ sender: NSComboBox) {
        if(chooseDocBox.indexOfSelectedItem >= 0) {
            let index: Int = chooseDocBox.indexOfSelectedItem
            thePDF.document = documents[index]
        }
    }
    
    //
    //  Helper functions
    //
    
    func updatePageNumber() {
        let page = thePDF.currentPage
        let pageNum = (thePDF.document?.index(for: page!))! + 1
        pageNumberField.stringValue = "Page \(pageNum) of \(thePDF.document?.pageCount ?? 0)"
    }
    
}



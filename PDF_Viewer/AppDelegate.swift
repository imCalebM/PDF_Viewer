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
    @IBOutlet weak var localNavDocs: NSSegmentedControl!
    @IBOutlet weak var addNotes: NSButton!
    @IBOutlet var pageNotes: NSTextView!
    @IBOutlet var docNotes: NSTextView!
    @IBOutlet weak var bookmarkPopUp: NSPopUpButton!
    @IBOutlet weak var bookmarkButton: NSButton!
    @IBOutlet weak var aboutWindow: NSView!
    @IBOutlet weak var aboutWindowText: NSTextField!
    @IBOutlet weak var searchBox: NSSearchField!
    @IBOutlet weak var searchCount: NSTextField!
    @IBOutlet weak var totalSearchCount: NSTextField!
    @IBOutlet weak var leftSearch: NSButton!
    @IBOutlet weak var rightSearch: NSButton!

    
    
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
        leftSearch.isHidden = true
        rightSearch.isHidden = true
        let aboutSize: NSSize = CGSize(width: 400, height: 400)
        aboutWindow.window?.setIsVisible(false)
        aboutWindow.setFrameSize(aboutSize)
        aboutWindowText.stringValue = "PDF_Viewer is an application for viewing PDF documents.\n\nThis application provides features for storing notes and bookmarks for individual pages, as well as the entire document.\n\n\n\n\nCreated by Caleb Mitchell for COSC346 at University of Otago"
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    

    
    // Updates title of the window
    func updateWindow(sender: PDFDocument){
        appWindow.title = sender.documentURL!.lastPathComponent
    }
    
    
    

    /*********************************************************
     
                Action functions for UI objects
     
    *********************************************************/
    
    // Open documents and start a timer that calls updatePageNumber
    @IBAction func openPDF(sender: NSMenuItem) {
        if let urls = NSOpenPanel().selectURL {
            thePDF.document = PDFClass(url: urls.first!)
            documentOpen = true
            for doc in urls{
                if chooseDocBox.indexOfItem(withObjectValue: doc.lastPathComponent) == NSNotFound {
                    chooseDocBox.addItem(withObjectValue: doc.lastPathComponent)
                    documents.append(PDFClass(url: doc)!)
                }
            }

            chooseDocBox.stringValue = (urls.first?.lastPathComponent)! // fill combo box
            updateDocument(sender: thePDF.document!)
            resetZoom(resetButton)
            
            // update page number every 0.1 seconds
            _ = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updatePageNumber), userInfo: nil, repeats: true)
        }
    }
    
    // Zoom in action
    @IBAction func zoomIn(_ sender: NSButton) {
        thePDF.zoomIn(sender)
    }
    
    // Zoom out action
    @IBAction func zoomOut(_ sender: NSButton) {
        thePDF.zoomOut(sender)
    }
    
    // Fits the document view to screen
    @IBAction func resetZoom(_ sender: NSButton) {
        thePDF.autoScales = true
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
    
    // Changes displayed document to users selection
    @IBAction func PDFSelect(_ sender: NSComboBox) {
        if(chooseDocBox.indexOfSelectedItem >= 0) {
            let index: Int = chooseDocBox.indexOfSelectedItem
            thePDF.document = documents[index]
            currentDoc = index
            updateDocument(sender: thePDF.document!)
        }
    }
    
    // Changes displayed document to previous or next in open array
    @IBAction func prevOrNextDoc(_ sender: NSSegmentedControl) {
       let index = sender.selectedSegment
        if(index == 0 && currentDoc > 0){
            currentDoc -= 1
            thePDF.document = documents[currentDoc]
        } else if(index == 1 && currentDoc < documents.count - 1){
            currentDoc += 1
            thePDF.document = documents[currentDoc]
        }
        updateDocument(sender: thePDF.document!)
    }
    
    // Stores user's page notes
    @IBAction func addToPageNotes(_ sender: NSButton) {
        if documentOpen {
            // Store the note in the document's dictionary with key value being page number
            print(pageNotes.string!)
            documents[currentDoc].notes[currentPage] = pageNotes.string
        }
    }

    // Stores the user's document notes
    @IBAction func addToDocNotes(_ sender: NSButton) {
        if documentOpen {
            // Store the note in the document's dictionary with key value as 0
            documents[currentDoc].notes[0] = docNotes.string
        }
    }
    
    // Stores the current page in document's bookmarks
    @IBAction func bookmarkPage(_ sender: NSButton) {
        // If a document is open and there isn't already a bookmark for this page
        if documentOpen && bookmarkPopUp.indexOfItem(withTitle: (thePDF.currentPage?.label)!) == -1{
            documents[currentDoc].bookmarks.append((thePDF.currentPage?.label)!)
            bookmarkPopUp.addItem(withTitle: (thePDF.currentPage?.label)!)
        }
    }
    
    // Displays the selected bookmarked page
    @IBAction func goToBookmark(_ sender: NSPopUpButton) {
        let bookmark: String = documents[currentDoc].bookmarks[sender.indexOfSelectedItem]
        print("\(bookmark)")
        let index = Int(bookmark)!
        thePDF.go(to: (thePDF.document?.page(at: index-1))!)
    }
    
    // Finds words in the document matching the search field contents
    @IBAction func search(_ sender: NSSearchField) {
        if documentOpen{
            let searchText: String = searchBox.stringValue
            if(searchText != ""){
                searchValues = (thePDF.document?.findString(searchText, withOptions: 1))!
                if !searchValues.isEmpty {
                    searchCount.stringValue = "1"
                    searchNumber = 0
                    totalSearchCount.stringValue = "/ " + searchValues.endIndex.description
                    rightSearch.isHidden = false
                    leftSearch.isHidden = false
                    findWords()
                } else {
                    searchCount.stringValue = ""
                    totalSearchCount.stringValue = ""
                }
            }
        }
    }
    
    // Moves selection to the previous word in the searchValues array
    @IBAction func previousWord(_ sender: NSButton) {
        if documentOpen {
            if searchNumber > 0 {
                searchNumber -= 1
                findWords()
            }
        }
    }
    
    // Moves selection to next word in the searchValues array
    @IBAction func nextWord(_ sender: NSButton) {
        if documentOpen {
            if searchNumber < searchValues.count - 1 {
                searchNumber += 1
                findWords()
            }
        }
    }
    
    
    @IBAction func openAboutWindow(_ sender: Any) {
        aboutWindow.window?.setIsVisible(true)
    }
    /*********************************************************

                         Helper functions

    **********************************************************/
    
    // Updates the page number text field and notes field
    // - Called every 0.1s by timer
    func updatePageNumber() {
        let page = thePDF.currentPage
        let pageNum = (thePDF.document?.index(for: page!))! + 1
        if pageNum != currentPage {
            currentPage = pageNum
            // If there are notes for the page then display them
            if documents[currentDoc].notes.keys.contains(currentPage) {
                pageNotes.string = documents[currentDoc].notes[currentPage]!
            } else if pageNotes.string != "" {
                pageNotes.string = ""
            }
        }
        pageNumberField.stringValue = "Page \(pageNum) of \(thePDF.document?.pageCount ?? 0)"
    }
    
    // Updates labels and notes
    func updateDocument(sender: PDFDocument) {
        let docTitle = (sender.documentURL?.lastPathComponent)!
        appWindow.title = docTitle
        chooseDocBox.stringValue = docTitle
        bookmarkPopUp.removeAllItems()
        if !documents[currentDoc].bookmarks.isEmpty{
            bookmarkPopUp.addItems(withTitles: documents[currentDoc].bookmarks)
        }
        
        // If there are notes for the document then display them
        if documents[currentDoc].notes.keys.contains(0) {
            docNotes.string = documents[currentDoc].notes[0]!
        } else {
            docNotes.string = ""
        }
    }
    
    // Highlights words found in the search
    func findWords(){
        let selection = searchValues[searchNumber] as! PDFSelection
        thePDF.go(to: selection)
        searchCount.stringValue = (searchNumber+1).description
        searchValues[searchNumber].setColor(NSColor(red: 1, green: 1, blue: 0, alpha: 1))
        thePDF.setCurrentSelection(selection, animate: true)
    }
    
}



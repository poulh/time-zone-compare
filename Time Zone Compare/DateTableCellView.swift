//
//  DateCellView.swift
//  Time Zone Compare
//
//  Created by Poul Hornsleth on 1/9/21.
//

import Cocoa

class DateTableCellView: NSTableCellView {

    @IBOutlet weak var monthLabel: NSTextField!
    @IBOutlet weak var dayLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

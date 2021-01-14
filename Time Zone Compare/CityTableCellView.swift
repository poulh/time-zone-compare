//
//  CityTableCellView.swift
//  Time Zone Compare
//
//  Created by Poul Hornsleth on 1/6/21.
//

import Cocoa

class CityTableCellView: NSTableCellView {

    @IBOutlet weak var cityLabel: NSTextField!
    @IBOutlet weak var countryLabel: NSTextField!
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}

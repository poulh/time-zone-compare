//
//  StackedImageTableCellView.swift
//  Time Zone Compare
//
//  Created by Poul Hornsleth on 1/17/21.
//

import Cocoa

protocol StackedImageTableCellDelegate {
    func onTopImageButtonPressed( _ id: String )
    func onBottomImageButtonPressed( _ id: String )
}

class StackedImageTableCellView: NSTableCellView {

    @IBOutlet weak var topImageButton: NSButton!
    @IBOutlet weak var bottomImageButton: NSButton!
    
    var id : String = ""
    
    var delegate : StackedImageTableCellDelegate?
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
    @IBAction func topImageButtonPressed(_ sender: NSButton) {
        delegate?.onTopImageButtonPressed(id)
    }
    
    @IBAction func bottomImageButtonPressed(_ sender: Any) {
        delegate?.onBottomImageButtonPressed(id)
    }
    
}

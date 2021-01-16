//
//  ViewController.swift
//  Time Zone Compare
//
//  Created by Poul Hornsleth on 1/6/21.
//

import Cocoa
import MapKit

extension Date {
    func prettyTime(timeZone:TimeZone, format:String) -> String {
        let dateFormatter = DateFormatter()
      
        // Then select your timezone.
        // Either by abbreviation or defaulting to the system timezone.
        dateFormatter.timeZone =  timeZone
        dateFormatter.dateFormat = format
        
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!

    
    @IBOutlet weak var searchField: NSSearchField!
    
    
    var currTime : Date = Date()
    var blinkSecond : Bool = true
    var hourFormatOn : String = "H:mm"
    var hourFormatOff : String = "H mm"

    var colonValue = ":"
    var timer : Timer? = nil
    
    var mapItems : [MKMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        searchField.delegate = self
        
        tableView.intercellSpacing = NSSize(width: 0, height: 20)
        
        for i in 0...24 {
            tableView.tableColumn(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "\(i)"))?.width = 30
        }
        startTimer()
        
        // Do any additional setup after loading the view.
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func startTimer() {
        
        // add Timer via RunLoop allows the ':' to blink even during Window resize
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
       
        if let t = timer {
            RunLoop.current.add(t, forMode: .common)
        }
    }
    
    @objc func fireTimer() {
        self.currTime = Date()
        self.blinkSecond = !self.blinkSecond
        DispatchQueue.main.async {
            let s = IndexSet(integersIn: 0..<self.tableView.numberOfRows)
            
            self.tableView.reloadData(forRowIndexes: s, columnIndexes: IndexSet(integer: 1))
        }
    }
}

extension ViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return mapItems.count
    }
}

extension ViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
    
    func tableView(_ tableView: NSTableView, shouldSelect tableColumn: NSTableColumn?) -> Bool {
        return true
    }
    
    func selectionShouldChange(in tableView: NSTableView) -> Bool {
        return true
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = tableColumn?.identifier
        let currRowMapItem = mapItems[row]
        
        if cellIdentifier?.rawValue == "City" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CityCellID"), owner: nil) as? CityTableCellView {
                
                cell.cityLabel?.stringValue = currRowMapItem.placemark.locality ?? "---"
                cell.countryLabel?.stringValue = currRowMapItem.placemark.country ?? "---"

                return cell
            }
        }
        else if cellIdentifier?.rawValue == "Time" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CityCellID"), owner: nil) as? CityTableCellView {
                
                let hourFormat = blinkSecond ? hourFormatOn : hourFormatOff
                cell.cityLabel?.stringValue = currTime.prettyTime(timeZone: currRowMapItem.timeZone!, format: hourFormat)
                cell.countryLabel?.intValue = Int32(currRowMapItem.timeZone?.secondsFromGMT() ?? 0) / Int32(3600)

                return cell
            }
        }
        else if cellIdentifier?.rawValue == "Last" {
            return nil
        }
        else if let hourString = tableColumn?.identifier.rawValue,
                let cellHour = Int32(hourString) {

            let homeRowMapItem = mapItems[0]
            
            let offset = (Int32(currRowMapItem.timeZone!.secondsFromGMT() - homeRowMapItem.timeZone!.secondsFromGMT())) / 3600

            var hour = cellHour + offset
            if hour < 0 {
                hour += 24
            }
            if hour > 23 {
                hour -= 24
            }
            
            var cell : NSTableCellView? = nil
            
            if hour == 0,
               let dateCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "DateCellID"), owner: nil) as? DateTableCellView {
                
                var dateToUse = currTime
                if currRowMapItem.timeZone!.secondsFromGMT() > homeRowMapItem.timeZone!.secondsFromGMT() {
                    dateToUse = dateToUse + (60 * 60 * 24)
                }
                dateCell.monthLabel.stringValue = dateToUse.prettyTime(timeZone: homeRowMapItem.timeZone!, format: "MMM")
                dateCell.dayLabel.stringValue = dateToUse.prettyTime(timeZone: homeRowMapItem.timeZone!, format: "DD")
                cell = dateCell
                
            } else if let hourCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TableCellID"), owner: nil) as? NSTableCellView {
                
                hourCell.textField?.intValue = hour
                cell = hourCell
            }
            else {
                return nil
            }
            
            if let cell = cell {
                cell.wantsLayer = true
                
                if (9...16).contains(hour) {
                    cell.layer?.backgroundColor = NSColor(named: "DayColor")?.cgColor
                }
                else if (17...18).contains(hour) || (7...8).contains(hour) {
                    cell.layer?.backgroundColor = NSColor(named: "EveningColor")?.cgColor
                }
                else {
                    cell.layer?.backgroundColor = NSColor(named: "NightColor")?.cgColor
                }
                
                if hour == 0 {
                    cell.layer?.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                    cell.layer?.cornerRadius = 12
                }
                else if hour == 23 {
                    cell.layer?.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                    cell.layer?.cornerRadius = 12
                } else {
                    cell.layer?.cornerRadius = 0
                    cell.layer?.maskedCorners = []
                }
                
                cell.layer?.borderColor = NSColor.white.cgColor
                cell.layer?.borderWidth = 1
                
                return cell
            }
        }
        
        return nil
    }
    
}

extension NSSearchField {
    func resetSearch() {
        if let searchFieldCell = self.cell as? NSSearchFieldCell {
            searchFieldCell.cancelButtonCell?.performClick(self)
        }
    }
}

extension ViewController : NSSearchFieldDelegate {
   
    func searchFieldDidEndSearching(_ sender: NSSearchField) {
    }
    
    func searchFieldDidStartSearching(_ sender: NSSearchField) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = sender.stringValue
        MKLocalSearch(request: request).start { (response, error) in
            guard let items = response?.mapItems else {
                return
            }
            for item in items {
                self.mapItems.append(item)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }

        DispatchQueue.main.async {
            sender.resetSearch()
        }
    }
}


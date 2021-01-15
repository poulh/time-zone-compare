//
//  ViewController.swift
//  Time Zone Compare
//
//  Created by Poul Hornsleth on 1/6/21.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var textView: NSTextField!
    
    
    var currTime : Date = Date()
    var blinkSecond : Bool = true
    var hourFormatOn : String = "H:mm"
    var hourFormatOff : String = "H mm"

    var colonValue = ":"
    var timer : Timer? = nil
    
    var cities : [City] = [
        City(name: "Bucharest", country: "Romania", timezone: "EET", offset: 2.0),
        City(name: "Moscow", country: "Russia", timezone: "MSD", offset: 3.0),
        City(name: "New York", country: "USA", timezone: "EST", offset: -5.0),
        City(name: "London", country: "England", timezone: "GMT", offset: 0.0),
        City(name: "Hong Kong", country: "Hong Kong", timezone: "HKT", offset: 8.0),
        City(name: "Beijing", country: "China", timezone: "CST", offset: 8.0),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
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
        timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer), userInfo: nil, repeats: true)
       
        if let t = timer {
            RunLoop.current.add(t, forMode: .common)
        }
        
    }
    
    @objc func fireTimer() {
        self.currTime = Date()
        self.blinkSecond = !self.blinkSecond
        DispatchQueue.main.async {
          //  self.tableView.reloadData()
            let s = IndexSet(integersIn: 0..<self.tableView.numberOfRows)
            
            self.tableView.reloadData(forRowIndexes: s, columnIndexes: IndexSet(integer: 1))
        }
    }
    
    func prettyTime(timeZone:String, format:String) -> String {
        let dateFormatter = DateFormatter()
      
        // Then select your timezone.
        // Either by abbreviation or defaulting to the system timezone.
        dateFormatter.timeZone = TimeZone(identifier: timeZone)
        dateFormatter.dateFormat = format
        //  dateFormatter.timeZone = TimeZone.current
        
        let dateString = dateFormatter.string(from: currTime)
        return dateString
    }
    
    
}

extension ViewController : NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return cities.count
    }
    
    
}

extension ViewController : NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cellIdentifier = tableColumn?.identifier
        
        if cellIdentifier?.rawValue == "City" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CityCellID"), owner: nil) as? CityTableCellView {
                cell.cityLabel?.stringValue = cities[row].name
                cell.countryLabel?.stringValue = cities[row].country

                return cell
            }
        }
        else if cellIdentifier?.rawValue == "Time" {
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CityCellID"), owner: nil) as? CityTableCellView {
                let hourFormat = blinkSecond ? hourFormatOn : hourFormatOff
                cell.cityLabel?.stringValue = prettyTime(timeZone: cities[row].timezone, format: hourFormat)
                cell.countryLabel?.stringValue = "\(cities[row].offset)"

                return cell
            }
        }
        else if cellIdentifier?.rawValue == "Last" {
            return nil
        }
        else if let hourString = tableColumn?.identifier.rawValue,
                let cellHour = Int32(hourString) {

            let homeCity = cities[0]
            let currCity = cities[row]
            let offset = Int32(currCity.offset - homeCity.offset)
            
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
                dateCell.monthLabel.stringValue = "Jan"
                dateCell.dayLabel.stringValue = "9"
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
                }
                
                cell.layer?.borderColor = NSColor.white.cgColor
                cell.layer?.borderWidth = 1
                
                return cell
            }
        }
        
        return nil
    }
    
}


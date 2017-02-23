//
//  CharViewController.swift
//  BLEServiceBrowser
//
//  Created by Hiteshwar Vadlamudi on 12/1/15.
//  Copyright © 2015 bluetooth. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

class CharViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectionDelegate, UISplitViewControllerDelegate {
    
    var peripheral: CBPeripheral?
    var adapter: BLEAdapter?
    var characteristic: CBCharacteristic?
    var masterPopoverController: UIPopoverController?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var WriteCommandButton: UIButton!
    @IBOutlet weak var WriteButton: UIButton!
    
    @IBOutlet weak var ReadButton: UIButton!
    @IBOutlet weak var NotificationSwitch: UISwitch!
    @IBOutlet weak var IndicationSwitch: UISwitch!
    @IBOutlet weak var textBoxHex: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setCharViewDelegate(self)
        
        adapter = sharedInstance
        peripheral = adapter?.activePeripheral
        let properties = characteristic?.properties
        
        self.ReadButton.isEnabled = properties!.contains(.read)
        self.WriteButton.isEnabled = properties!.contains(.write)
        self.WriteCommandButton.isEnabled = properties!.contains(.writeWithoutResponse)
        self.NotificationSwitch.isEnabled = properties!.contains(.notify)
        self.IndicationSwitch.isEnabled = properties!.contains(.indicate)
        self.NotificationSwitch.isOn = false
        self.IndicationSwitch.isOn = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.configureView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureView()
    {
        if(peripheral != nil)
        {
            peripheral?.discoverDescriptors(for: characteristic!)
        }
    }
    
    func OnReadChar(_ characteristic: CBCharacteristic)
    {
        print("KeyfobViewController didUpdateValueForCharacteristic %@", characteristic)
        self.textBoxHex.text = characteristic.value?.description
        self.tableView.reloadData()
    }
    
    func OnWriteChar(_ characteristic: CBCharacteristic)
    {
        
    }
    
    func dataFromHexString(_ string: NSString)->Data?
    {
        let strLower = string.lowercased
        let length = strLower.characters.count
        
        
        let rawData = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: length/2)
        var rawIndex = 0
        
        for index in stride(from: 1, through: length, by: 2) { //var index = 0; index < length; index+=2{
            let single = NSMutableString()
            single.append(strLower.substring(with: (strLower.characters.index(strLower.startIndex, offsetBy: index) ..< strLower.characters.index(strLower.startIndex, offsetBy: index+2))))
            rawData[rawIndex] = UInt8(single as String, radix:16)!
            rawIndex += 1
        }
        
        let data:Data = Data(bytes: UnsafePointer<UInt8>(rawData), count: length/2)
        rawData.deallocate(capacity: length/2)
        
        return data
    }
    
    @IBAction func ReadButtonPressed(_ sender: AnyObject) {
        if(peripheral != nil)
        {
            if(characteristic != nil)
            {
                peripheral?.readValue(for: self.characteristic!)
            }
        }
    }
    
    @IBAction func WriteButtonPressed(_ sender: AnyObject) {
        
        if(peripheral != nil)
        {
            let data = self.dataFromHexString(self.textBoxHex.text! as NSString)
            
            withVaList([data! as CVarArg], { NSLogv("%@", $0) })
            if(characteristic != nil)
            {
                peripheral?.writeValue(data!, for: self.characteristic!, type: CBCharacteristicWriteType.withResponse)
            }
            
            
        }
    }
    
    @IBAction func WriteCommandButtonPressed(_ sender: AnyObject) {
        
        if(peripheral != nil)
        {
            let data = self.dataFromHexString(self.textBoxHex.text! as NSString)
            withVaList([data! as CVarArg], { NSLogv("%@", $0) })
            if(characteristic != nil)
            {
                peripheral?.writeValue(data!, for: characteristic!, type: CBCharacteristicWriteType.withoutResponse)
            }
        }
    }
    
    @IBAction func NotificationSwitchChanged(_ sender: AnyObject) {
        
        if(self.NotificationSwitch.isOn == true)
        {
            peripheral?.setNotifyValue(true, for: characteristic!)
        }
        else
        {
            peripheral?.setNotifyValue(false, for: characteristic!)
        }
    }
    
    @IBAction func InidicationSwitchChanged(_ sender: AnyObject) {
    }
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    var ROWS_PER_SECTION = 3
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ROWS_PER_SECTION
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        
        let char = self.characteristic
        cell.textLabel?.text = ""
        cell.detailTextLabel?.text = ""
        
        switch indexPath.row
        {
        case 0:
            cell.textLabel?.text = "Characteristic Property"
            let properties = char?.properties
            
            cell.detailTextLabel?.text = String(format: "B:%d R:%d w:%d W:%d N:%d I:%d A:%d E:%d",
                properties!.contains(.broadcast) ? 1 : 0,
                properties!.contains(.read) ? 1 : 0,
                properties!.contains(.writeWithoutResponse) ? 1 : 0,
                
                
                properties!.contains(.write) ? 1 : 0,
                
                properties!.contains(.notify) ? 1 : 0,
                
                properties!.contains(.indicate) ? 1 : 0,
                properties!.contains(.authenticatedSignedWrites) ? 1 : 0,
                properties!.contains(.extendedProperties) ? 1 : 0)
            
            break;
        case 1:
            cell.textLabel?.text = "Vlaue"
            if(char?.value != nil)
            {
                
                cell.detailTextLabel?.text = String(bytes: (characteristic?.value)!, encoding: .utf8)
            }
            else
            {
                let properties = char?.properties
                if !(properties!.contains(.read))
                {
                    cell.detailTextLabel?.text = "Not Readable"
                }
            }
            break;
        case 2:
            cell.textLabel?.text = "Descriptors"
            cell.detailTextLabel?.text = ""
            break;
        default:
            break;
        }
        
        return cell
    }
    
    // mark Selection Delegate
    
    func ClearUI(_ clear: Bool)
    {
        
    }
    func selectedPeripheral(_ peripheral: CBPeripheral)
    {
        
    }
    
    func selectedService(_ service: CBService)
    {
        
    }
    func selectedCharacteristic(_ characteristic: CBCharacteristic)
    {
        self.characteristic = characteristic
        
        self.configureView()
    }
    
    func splitViewController(_ svc: UISplitViewController, willHide aViewController: UIViewController, with barButtonItem: UIBarButtonItem, for pc: UIPopoverController) {
        
        barButtonItem.title = "Scan"
        self.navigationItem.setLeftBarButton(barButtonItem, animated: true)
        self.navigationItem.leftItemsSupplementBackButton = true
        self.masterPopoverController = pc
    }
    
    func splitViewController(_ svc: UISplitViewController, willShow aViewController: UIViewController, invalidating barButtonItem: UIBarButtonItem) {
        self.navigationItem.setLeftBarButton(nil, animated: true)
        self.masterPopoverController = nil
    }
    
}

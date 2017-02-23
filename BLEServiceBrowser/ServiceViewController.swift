//
//  ServiceViewController.swift
//  BLEServiceBrowser
//
//  Created by Hiteshwar Vadlamudi on 11/30/15.
//  Copyright © 2015 bluetooth. All rights reserved.
//

import Foundation
import CoreBluetooth
import UIKit


class ServiceViewController: UITableViewController, SelectionDelegate, UISplitViewControllerDelegate, BLEAdapterDelegate {
    
    var characteristicsOfAService :NSMutableArray = []
    var bleAdapter: BLEAdapter?
    var service: CBService?
    var peripheral: CBPeripheral?
    var masterPopoverController: UIPopoverController?
    var delegate: SelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bleAdapter = sharedInstance
        peripheral = service?.peripheral
        bleAdapter?.activePeripheral = peripheral
        self.configureView()
        bleAdapter?.getAllCharacteristicsForService(peripheral!, service: service!)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setServiceViewDelegate(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func configureView() {

        bleAdapter?.bleAdapterDelegate = self

        if(service != nil)
        {
            let strTitle = bleAdapter?.CBUUIDToNSString((service?.uuid)!)
            self.title = strTitle as? String
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return characteristicsOfAService.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        let aCharacteristic = characteristicsOfAService.object(at: indexPath.row) as! CBCharacteristic
        cell.textLabel!.text =  bleAdapter?.CBUUIDToNSString(aCharacteristic.uuid) as? String
        //        cell.detailTextLabel!.text = aCharacteristic.UUID.data.description
        
        return cell
    }
    
    
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showCharacteristic") {
            let charCtrl = segue.destination as! CharViewController
            let indexPath = self.tableView.indexPathForSelectedRow! as IndexPath
            let charObject = characteristicsOfAService.object(at: indexPath.row) as! CBCharacteristic
            charCtrl.characteristic = charObject
        }
    }
    
    // mark Selection Delegate
    
    func ClearUI(_ clear: Bool) {
        
    }
    func selectedPeripheral(_ peripheral: CBPeripheral) {
        
    }
    
    func selectedService(_ service: CBService) {
        self.service = service
        self.configureView()
    }
    
    func selectedCharacteristic(_ characteristic: CBCharacteristic) {
        
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
    
    //BLEAdapterDelegate Methods
    
    func AllCharacteristics(_ charcterArrays: NSArray)
    {
        for charcter in charcterArrays{
            characteristicsOfAService.insert(charcter, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            var indxesPath:[IndexPath] = [IndexPath]()
            indxesPath.append(indexPath)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: indxesPath, with: UITableViewRowAnimation.automatic)
            self.tableView.endUpdates()
            
            print("Characteristic found with UUID: %@", (charcter as AnyObject).uuid)
        }
    }
    
    func OnConnected(_ status: Bool){
        //This is not used here
    }
    
    func OnDiscoverService(_ services: NSArray) {
        //This is not used here
    }
    
    
}

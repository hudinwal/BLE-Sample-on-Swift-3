//
//  MasterViewController.swift
//  BLEServiceBrowser
//
//  Created by Hiteshwar Vadlamudi on 11/30/15.
//  Copyright © 2015 bluetooth. All rights reserved.
//

import UIKit
import CoreBluetooth

class MainViewController: UITableViewController {

    var peripherals:NSMutableArray = []
    var bleAdapter:BLEAdapter! = sharedInstance
    var scanState:Bool! = false
    var delegate: SelectionDelegate?



    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanState = false
        
    }

    @IBAction func scanButtonPressed(_ sender: AnyObject) {
        if(!self.scanState) {
            peripherals.removeAllObjects()
            self.tableView.reloadData()
            
            if(bleAdapter.activePeripheral != nil) {
                if(bleAdapter.activePeripheral!.state != CBPeripheralState.disconnected){
                    bleAdapter.centralManager!.cancelPeripheralConnection(bleAdapter.activePeripheral!)
                }
            }
            bleAdapter.peripherals.removeAllObjects()
            _ = bleAdapter.findBLEPeripherals(2.0)
        } else {
            
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(MainViewController.connectionTimer), userInfo: nil, repeats: false)
    }
   
    
    func connectionTimer() {
        if(bleAdapter.peripherals.count > 0){
            bleAdapter.printKnownPeripherals()
            insertScannedperipherals()
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func insertScannedperipherals () {
        
        for i in 0 ..< bleAdapter.peripherals.count{
            peripherals.insert((bleAdapter.peripherals.object(at: i)), at: 0)
            let indexPath:IndexPath =  IndexPath(item: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.fade)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            let nextDetailController = segue.destination as! DeviceViewController
            let indexPath = self.tableView.indexPathForSelectedRow! as IndexPath
            let peripheralObject = peripherals.object(at: indexPath.row) as! CBPeripheral
            nextDetailController.setDetailItems(peripheralObject)
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let p:CBPeripheral = peripherals.object(at: indexPath.row) as! CBPeripheral
        if(p.name != nil) {
            cell.textLabel!.text = p.name
        } else {
            cell.textLabel!.text = "Unknown"
        }
        return cell
    }

   


}


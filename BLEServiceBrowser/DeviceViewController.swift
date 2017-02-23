////
//  DetailViewController.swift
//  BLEServiceBrowser
//
//  Created by Hiteshwar Vadlamudi on 11/30/15.
//  Copyright © 2015 bluetooth. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SelectionDelegate, UISplitViewControllerDelegate, BLEAdapterDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var peripheralConnectionStatusLabel: UILabel!
    @IBOutlet weak var servicesLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectButton: UIBarButtonItem!
    @IBOutlet weak var serviceTableViewOutlet: UITableView!

    var peripheral: CBPeripheral!
    var bleAdapter:BLEAdapter! = sharedInstance
    var pheripheralServices: NSMutableArray = []
    var delegate:SelectionDelegate?
    var masterPopoverController: UIPopoverController?


    func setDetailItems(_ peripheralDetailItem: AnyObject?) {
        peripheral = peripheralDetailItem as! CBPeripheral
    }
    
    func configureView() {
        bleAdapter.bleAdapterDelegate = self
        
        adjustUI(false)
        // Update the user interface for the detail item.
        if let peripheral = self.peripheral {
            if let peripheralDescription = self.detailDescriptionLabel {
                peripheralDescription.text = peripheral.description
                peripheralDescription.layer.borderColor = UIColor.red.cgColor
                peripheralDescription.layer.borderWidth = 2.0
            }
            
        }
    }


    func adjustUI(_ clear: Bool){
        if(clear == true){
            self.serviceTableViewOutlet.isHidden = true
            self.navigationItem.rightBarButtonItem = nil
            self.detailDescriptionLabel.isHidden = true
            self.peripheralConnectionStatusLabel.isHidden = true
            self.statusLabel.isHidden = true
            self.servicesLabel.isHidden = true
            pheripheralServices.removeAllObjects()
            self.serviceTableViewOutlet.reloadData()
        }
        else
        {
            self.serviceTableViewOutlet.isHidden = false
            self.navigationItem.rightBarButtonItem = connectButton
            self.detailDescriptionLabel.isHidden = false
            self.peripheralConnectionStatusLabel.isHidden = false
            self.statusLabel.isHidden = false
            self.servicesLabel.isHidden = false
            pheripheralServices.removeAllObjects()
            self.serviceTableViewOutlet.reloadData()
        }
    }

    @IBAction func connectButtonPressed(_ sender: AnyObject) {
        if(peripheral.state == CBPeripheralState.disconnected)
        {
            pheripheralServices.removeAllObjects()
            serviceTableViewOutlet.reloadData()
            bleAdapter.connectPeripheral(peripheral, status: true)
        }
        else
        {
            bleAdapter.connectPeripheral(peripheral, status: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.setMainViewDelegate(self)
        
        detailDescriptionLabel.text = ""
        peripheralConnectionStatusLabel.text = "Not Connected"
        
        serviceTableViewOutlet.dataSource = self
        serviceTableViewOutlet.delegate = self
        bleAdapter.bleAdapterDelegate = self
        
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "showService") {
            let serviceCtrl = segue.destination as! ServiceViewController
            let indexPath = self.serviceTableViewOutlet.indexPathForSelectedRow! as IndexPath
            let serviceObject = pheripheralServices.object(at: indexPath.row) as! CBService
            serviceCtrl.service = serviceObject
        }
    }

    //Mark: Functions from Split View Delegate
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
    
    //Mark: Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pheripheralServices.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")! as UITableViewCell
        let aService = pheripheralServices.object(at: indexPath.row) as! CBService
        
        cell.textLabel?.text = bleAdapter.GetServiceName(aService.uuid)
        cell.detailTextLabel?.text = aService.uuid.data.description
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if(UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.pad)
        {
            _ = pheripheralServices.object(at: indexPath.row) as! CBService
            
        }
    }

    
    //Mark: Functions from Selection Delegate
    func ClearUI(_ clear: Bool)
    {
            //Not Implementing
    }
    
    func selectedPeripheral(_ peripheral: CBPeripheral)
    {
        self.peripheral = peripheral
        self.configureView()
    }
    
    func selectedService(_ service: CBService)
    {
        //Not Implementing
    }
    
    func selectedCharacteristic(_ characteristic: CBCharacteristic)
    {
        //Not Implementing
    }
    
    
    //BLE Adapter Delegate
    //This function will get called whenever a Device is getting connected.
    func OnConnected(_ status: Bool){
        if(status == true) {
            peripheralConnectionStatusLabel.text = "Connected"
            connectButton = UIBarButtonItem(title: "Disconnect", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeviceViewController.connectButtonPressed(_:)))
        } else {
            peripheralConnectionStatusLabel.text = "Not Connected";
            connectButton = UIBarButtonItem(title: "Connect", style: UIBarButtonItemStyle.plain, target: self, action: #selector(DeviceViewController.connectButtonPressed(_:)))
        }
    }
    
    func OnDiscoverService(_ services: NSArray) {
        for service in services {
            pheripheralServices.insert(service, at: 0)
            let indexPath = IndexPath(row: 0, section: 0)
            
            serviceTableViewOutlet.beginUpdates()
            self.serviceTableViewOutlet.insertRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            serviceTableViewOutlet.endUpdates()
        }
    }
    
    func AllCharacteristics(_ charcterArrays: NSArray)
    {
        //This is Optional. This will  be used on Service View COntroller
    }

}


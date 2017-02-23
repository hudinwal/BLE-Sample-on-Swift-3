//
//  SelectionDelegate.swift
//  BLEServiceBrowser
//
//  Created by Hiteshwar Vadlamudi on 11/30/15.
//  Copyright © 2015 bluetooth. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol SelectionDelegate
{
    func ClearUI(_ clear: Bool)
    func selectedPeripheral(_ peripheral: CBPeripheral)
    
    func selectedService(_ service: CBService)
    func selectedCharacteristic(_ characteristic: CBCharacteristic)
    
    
}

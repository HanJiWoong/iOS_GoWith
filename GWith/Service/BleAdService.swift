//
//  BleAdService.swift
//  GWith
//
//  Created by 한지웅 on 2022/12/07.
//

import Foundation
import CoreBluetooth

class BleAdService:NSObject {
    static let shared = BleAdService()
    
    private var mServiceUUIDStr:String? = nil
    private var mServiceUUID:CBUUID? = nil
    private var mService:CBMutableService? = nil
    
    var mPeripheralManager: CBPeripheralManager? = nil
    var mCentralManager: CBCentralManager? = nil
    
    var mBleState:CBManagerState = .poweredOff
    
    override init() {
        super.init()
            
        mPeripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        mCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func StartService(memberId:String) {
        
        if let iMemberId = Int(memberId) {
            mServiceUUIDStr = String(format: "19697466-0000-0000-0000-00000000%02X%02X", iMemberId/256,iMemberId%256)
            mServiceUUID = CBUUID(string: mServiceUUIDStr!)
            mService = CBMutableService(type: mServiceUUID!, primary: true)
            
            let characteristicUUID = CBUUID(string: mServiceUUIDStr!)
            let properties: CBCharacteristicProperties = [.notify, .read, .write]
            let permissions: CBAttributePermissions = [.readable, .writeable]
            let characteristic = CBMutableCharacteristic(
                type: characteristicUUID,
                properties: properties,
                value: nil,
                permissions: permissions)
            mService!.characteristics = [characteristic]
            
            mPeripheralManager?.add(mService!)
        }
        
    }
    
}

extension BleAdService:CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            mBleState = .poweredOn
            if let service = mService {
                mPeripheralManager?.add(service)
            }
        } else {
            mBleState = .poweredOff
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        mPeripheralManager?.setDesiredConnectionLatency(.low, for: central)
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let serviceUUID = mServiceUUID, let uuidStr = mServiceUUIDStr {
            DispatchQueue.global().async {
                let startTime = Date().timeIntervalSince1970
                
                Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
                    if (error != nil) {
                        print("PerformerUtility.publishServices() returned error: \(error!.localizedDescription)")
                        print("Providing the reason for failure: \(error!.localizedDescription)")
                    }
                    else {
                        self.mPeripheralManager?.startAdvertising([
                            CBAdvertisementDataLocalNameKey: ["mtis"],
                            CBAdvertisementDataServiceUUIDsKey : [service.uuid]])
                        print("advetising")
                    }
                    
                    let endTime = Date().timeIntervalSince1970
                    if endTime - startTime >= 2 {
                        timer.invalidate()
                        self.mPeripheralManager?.stopAdvertising()
                    }
                    
                    print("startTime => \(startTime), endTime => \(endTime), diff => \(endTime - startTime)")
                }
                
                
                RunLoop.current.run()
            }
            
        }
    }
}


extension BleAdService:CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            let options = [CBCentralManagerScanOptionAllowDuplicatesKey: true]
            if let serviceUUID = mServiceUUID {
                self.mCentralManager?.scanForPeripherals(withServices: [serviceUUID])
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(advertisementData[CBAdvertisementDataLocalNameKey])
    }
    
}

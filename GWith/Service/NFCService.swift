//
//  NFCService.swift
//  GWith
//
//  Created by 한지웅 on 2022/12/06.
//

import Foundation
import CoreNFC
import UIKit

class NFCService:NSObject{
    static let shared = NFCService()
    
    var nfcTagReaderSession:NFCTagReaderSession?
    
    func readyService(controller:UIViewController) {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support scanning your identity document.",
                preferredStyle: .alert
            )

            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            controller.present(alertController, animated: true, completion: nil)
            return
        }

        nfcTagReaderSession = NFCTagReaderSession(pollingOption: [.iso14443], delegate: self, queue: nil)
        nfcTagReaderSession?.alertMessage = "Place the device on the identity document."
        nfcTagReaderSession?.begin()
    }
    
    func stopStervice() {
        
    }
}

extension NFCService:NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        print("tagReaderSessionDidBecomeActive")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print("didInvalidateWithError")
        print(error.localizedDescription)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("got a Tag!")
        print("\(tags)")
        
        let nfcTag = tags.first!
        print("connecting to Tag!")
        
        nfcTagReaderSession?.connect(to: nfcTag) { (error1: Error?) in
            if error1 != nil{
                print(error1!)
            }

            if case let .iso7816(sTag) = nfcTag {
                print("sellecting application on card!")

                let selectApp = NFCISO7816APDU.init(data:Data.init([0,0xa4,0x04, 0x00, 0x7, 0xd4, 0x10, 0x00, 0x00, 0x03, 0x00, 0x01]))

                sTag.sendCommand(apdu: selectApp!) { (data:Data, int1:UInt8, int2:UInt8, error:Error?) in

                    if error != nil{
                        print(error!)
                        return
                    }else if data.count > 2{
                        if data[7] != 0{
                            print("select app worked")
//                            self.app = data

//                            let cardNumber = (BinaryTools.getDataSection(data: self.app!, offset: 8, length: 8)).hexEncodedString()
//
//                            DispatchQueue.main.async {
//
//                            }
                            
                        }
                        
                    }
                    
                }
                
//                print("reading purse")
//                let readPurse = NFCISO7816APDU.init(data:self.getPurseAPDU(purseNumber: 1))
                
//                sTag.sendCommand(apdu: readPurse!) { (data:Data, int1:UInt8, int2:UInt8, error:Error?) in
//
//                    if error != nil{
//                        print(error!)
//                        return
//
//                    }
//
//                    print("reading purse worked")
//                    self.purseData = data
                    
//                    let balance = BinaryTools.getDataSection(data: self.purseData!, offset: 2, length: 4).getIntFromData()
//
//                    DispatchQueue.main.async {
//                        self.balance.text = "Balance:\(String(format: "$%.02f",(Double(balance))/100))"
//
//                    }
//                    
//                }

//                let amountBytes = BinaryTools().getBigEndianBytes(number: UInt32(100))

//                let apdu = Data.init([0x90,0x40,0x00,0x00,0x04,amountBytes[0],amountBytes[1],amountBytes[2],amountBytes[3]])

//                let initLoad = NFCISO7816APDU.init(data:apdu)

//                print("init load")

//                sTag.sendCommand(apdu: initLoad!) { (data:Data, int1:UInt8, int2:UInt8, error:Error?) in
//
//                    if error != nil{
//                        print("load error \(String(describing: error))")
//
//                        return
//
//                    }else {
//                        print("init load worked")
//
//                    }
//
//                }

            }

        }

    }

}

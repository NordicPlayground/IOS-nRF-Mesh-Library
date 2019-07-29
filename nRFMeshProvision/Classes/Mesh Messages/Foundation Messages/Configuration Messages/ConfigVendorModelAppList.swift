//
//  ConfigVendorModelAppList.swift
//  nRFMeshProvision
//
//  Created by Aleksander Nowakowski on 29/07/2019.
//

import Foundation

public struct ConfigVendorModelAppList: ConfigStatusMessage, ConfigVendorModelMessage, ConfigModelAppList {
    public static let opCode: UInt32 = 0x804E
    
    public var parameters: Data? {
        let data = Data([status.rawValue]) + elementAddress + modelIdentifier + companyIdentifier
        return data + encode(indexes: applicationKeyIndexes[...])
    }
    
    public let status: ConfigMessageStatus
    public let elementAddress: Address
    public let modelIdentifier: UInt16
    public let companyIdentifier: UInt16
    public let applicationKeyIndexes: [KeyIndex]
    
    public init?(for model: Model, applicationKeys: [ApplicationKey], status: ConfigMessageStatus) {
        guard let companyIdentifier = model.companyIdentifier else {
            // Use ConfigSIGModelAppList instead.
            return nil
        }
        self.elementAddress = model.parentElement.unicastAddress
        self.modelIdentifier = model.modelIdentifier
        self.companyIdentifier = companyIdentifier
        self.applicationKeyIndexes = applicationKeys.map { return $0.index }
        self.status = status
    }
    
    public init?(parameters: Data) {
        guard parameters.count >= 7 else {
            return nil
        }
        guard let status = ConfigMessageStatus(rawValue: 0) else {
            return nil
        }
        self.status = status
        elementAddress = parameters.read(fromOffset: 1)
        modelIdentifier = parameters.read(fromOffset: 3)
        companyIdentifier = parameters.read(fromOffset: 5)
        applicationKeyIndexes = ConfigSIGModelAppList.decode(indexesFrom: parameters, at: 7)
    }
}
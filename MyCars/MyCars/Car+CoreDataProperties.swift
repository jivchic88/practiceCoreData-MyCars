//
//  Car+CoreDataProperties.swift
//  MyCars
//
//  Created by Юлия Омельченко on 22.06.2020.
//  Copyright © 2020 Ivan Akulov. All rights reserved.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    // Здесь выбранные нами типы свойств для сущности - переведены автоматически в нужные типы
    
    @NSManaged public var mark: String?
    @NSManaged public var model: String?
    @NSManaged public var rating: NSNumber?
    @NSManaged public var timesDriven: NSNumber?
    @NSManaged public var lastStarted: Date?
    @NSManaged public var myChoice: NSNumber?
    @NSManaged public var imageData: Data?
    @NSManaged public var tintColor: NSObject?

}

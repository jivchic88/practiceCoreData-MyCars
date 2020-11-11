//
//  ViewController.swift
//  MyCars
//
//  Created by Ivan Akulov on 07/11/16.
//  Copyright © 2016 Ivan Akulov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // получение контекста
    //  lazy var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // создали опциональное свойство контекст
    var context: NSManagedObjectContext!
    
    //
    var selectedCar: Car!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var markLabel: UILabel!
    @IBOutlet weak var modelLabel: UILabel!
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var lastTimeStartedLabel: UILabel!
    @IBOutlet weak var numberOfTripsLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var myChoiceImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromFile()
        
        // запрос в базу для получения из нее данных по конкретному авто
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        
        // текущая марка авто = текущий заголовок для segmentedControl
        let mark = segmentedControl.titleForSegment(at: 0)
        
        // использыем фильтр, чтобы получить инфу именно о нужном авто
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        // пытаемся извлечь значения из Core Data
        do {
            let results = try context.fetch(fetchRequest)
            selectedCar = results[0]
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // После извлечения всех значений - обновляем наш экран (обновление всех ярлыков)
    // метод для получения информации о каком-либо авто - после извлечения значений из Core Data
    func insertDataFrom(selectedCar: Car) {
        
        carImageView.image = UIImage(data: selectedCar.imageData!)
        markLabel.text = selectedCar.mark
        modelLabel.text = selectedCar.model
        
        // отображаем или нет значок - мой выбор
        // здесь инверсия значения (с помощью первого !) + приведение типа - так ка приходит NSNumber
        myChoiceImageView.isHidden = !(selectedCar.myChoice?.boolValue)!
        
        ratingLabel.text = "Rating: \(selectedCar.rating!.doubleValue)/ 10.0"
        
        numberOfTripsLabel.text = "Number of trips: \(selectedCar.timesDriven!.intValue)"
        
        // класс DateFormatter - позволяет отобразить дату в текстовом формате, у него есть свои шаблоны для представления
        let df = DateFormatter()
        df.dateStyle = .short
        df.timeStyle = .none
        lastTimeStartedLabel.text = "Last time started: \(df.string(from: selectedCar.lastStarted!))"
        
        // меняем цвет segmentedControl в зависимости от выбранной машины
        if #available(iOS 13.0, *) {
            // меняем цвет фона выделенной ячейки
            segmentedControl.selectedSegmentTintColor = selectedCar.tintColor as! UIColor
            
            // меняем цвет шрифта выделенной ячейки в segmentedControl
            segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        } else {
            segmentedControl.tintColor = selectedCar.tintColor as! UIColor
        }
//        segmentedControl. = selectedCar.tintColor as? UIColor
    }
    
    // метод - для загрузки данных из plist file в Core Data
    func getDataFromFile() {
        
        // проверяем - есть ли у нас уже записи в Core Data (если они есть,то их не переносим)
        
        // делаем запрос в базу данных
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        
        // predicate используется, когда нужно получить записи, соответствующие критерию (этот критерий устанавливается в predicate)
        // нам нужно получить все автомобили
        fetchRequest.predicate = NSPredicate(format: "mark != nil")
        
        // переменная для проверки записей в Core Data
        var records = 0
        
        // выполняем проверку есть ли данные в Core Data (метод может генерировать ошибку) + считаем количество записей
        // пытаемся извлечь записи, которые есть в контестве по запросу
        do {
            let count = try context.count(for: fetchRequest)
            records = count
            print("Data is there already? - Данные уже есть в Core Data?")
        } catch {
            print("error.localizedDescription")
        }
        
        // проверяем количество записей records
        // если количество записей равно 0 - загружаем данные (исполняем код ниже), иначе выходим из метода
        guard records == 0 else {return}
        
        // если 0, то считывания из нашего файла еще не было - нужно считать данные из plist file
        
        // ищем путь до нашего файла - plist file
        // Bundle - сам наш проект
        // data - название файла
        // plist - тип файла
        let pathToFile = Bundle.main.path(forResource: "data", ofType: "plist")
        
        // data.plist - если открыть как код (видно что файл состоит из массива)
        let dataArray = NSArray(contentsOfFile: pathToFile!)!
        
        // дальше - нужно получить все данные, которые хранятся в словарях
        // циклом перебираем словари из data.plist
        for dictionary in dataArray {
            
            // каждый элемент у нас - как отдельная сущность (каждый словарь - отдельный автомобиль)
            let entity = NSEntityDescription.entity(forEntityName: "Car", in: context)
            
            // создаем объект в который будем помещать данные из конкретного словаря
            // приводим к типу нашей сущности - Car
            // все данные попадают в конкретные объекты, которые будут сохранены с базе
            let car = NSManagedObject(entity: entity!, insertInto: context) as! Car
            
            // нужно объекту car присвоить те значения, которые содержатся в словаре
            // приводим dictionary к виду словаря - чтобы дальше обращаться к свойствам data.plist по ключу
            let carDictionary = dictionary as! NSDictionary
            
            // вытаскиваем каждое значение по ключу и приводим к нужному нам типу
            car.mark = carDictionary["mark"] as? String
            car.model = carDictionary["model"] as? String
            car.rating = carDictionary["rating"] as? NSNumber
            car.lastStarted = carDictionary["lastStarted"] as? Date
            car.timesDriven = carDictionary["timesDriven"] as? NSNumber
            car.myChoice = carDictionary["myChoice"] as? NSNumber
            
            // присваиваем изображение
            let imageName = carDictionary["imageName"] as? String
            let image = UIImage(named: imageName!)
            
            // предстваляем изображение в формате - Data (оно изначально в этом формате)
            let imageData = image!.pngData()
            
            car.imageData = imageData
            
            // присваиваем цвета
            let colorDictionary = carDictionary["tintColor"] as? NSDictionary
            car.tintColor = getColor(colorDictionary: colorDictionary!)
            
        }
    }
    
    func getColor(colorDictionary: NSDictionary) -> UIColor {
        let red = colorDictionary["red"] as! NSNumber
        let green = colorDictionary["green"] as! NSNumber
        let blue = colorDictionary["blue"] as! NSNumber
        
        return UIColor(red: CGFloat(truncating: red)/255, green: CGFloat(truncating: green)/255, blue: CGFloat(truncating: blue)/255, alpha: 1.0)
    }
    
    
    
    @IBAction func segmentedCtrlPressed(_ sender: UISegmentedControl) {
        
        // получаем марку авто, которую нажали на segmentedCtrl
        let mark = sender.titleForSegment(at: sender.selectedSegmentIndex)
        
        // создаем запрос
        let fetchRequest: NSFetchRequest<Car> = Car.fetchRequest()
        
        // фильтруем по марке
        fetchRequest.predicate = NSPredicate(format: "mark == %@", mark!)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            // результат(он всего один) полученный нами - сохраняем в selectedCar
            selectedCar = results[0]
            
            // отображаем данные
            insertDataFrom(selectedCar: selectedCar)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    
    
    //startEnginePressed - нужно увеличть количество поездок на единицу
    @IBAction func startEnginePressed(_ sender: UIButton) {
        
        // заводим константу для сохранения поездок (значение приводим в численное, чтобы можно было прибавить 1)
        let timesDriven = selectedCar.timesDriven?.intValue
        selectedCar.timesDriven = NSNumber(value: timesDriven! + 1)
        
        // также нам надо обновить время последней поездки
        // Date() - получаем текущее время для нашей поездки
        selectedCar.lastStarted = Date()
        
        // после внесения изменений - их нужно сохранить
        do {
            // попытка сохранения изменений в контексте
            try context.save()
            
            // нужно обновить наш экран -  метод для получения информации о каком-либо авто (обновление данных)
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // rateItPressed - метод для оценки авто
    @IBAction func rateItPressed(_ sender: UIButton) {
       
        // делаем всплывающий алерт контроллер
        let ac = UIAlertController(title: "Rate it", message: "Rate this car, please", preferredStyle: .alert)
        
        // реализуем кнопку окей
        let ok = UIAlertAction(title: "OK", style: .default) { (action) in
            
            // создаем 1 текстовое поле для ввода
            let textField = ac.textFields?[0]
            self.update(rating: (textField!.text)!)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        
        // добавим текстовое поле в наш алерт контроллер
        ac.addTextField { (textField) in
            
            // keyboardType (_ :) - указать тип клавиатуры для ввода текста.
            // numberPad - цифровая клавиатура с цифрами
            textField.keyboardType = .numberPad
        }
    
        ac.addAction(ok)
        ac.addAction(cancel)
        
        present(ac, animated: true)
    }
    
    
    // update - метод должен обновлять свойство рейтинг у selectedCar, после чего она должан пробовать сохранить контекст для того, чтобы эти изменения сохранились в базе данных
    func update(rating: String) {
        
        selectedCar.rating = NSNumber(value: Double(rating)!)
        
        do {
            try context.save()
            insertDataFrom(selectedCar: selectedCar)
        } catch {
            
            // алерт контроллер для введенных неверно значений
            let ac = UIAlertController(title: "Wrong value", message: "Wrong inrut", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default)
            ac.addAction(ok)
            present(ac, animated: true, completion: nil)
            
            print(error.localizedDescription)
        }
    }
}


//
//  ViewController.swift
//  pickerViewDemo
//
//  Created by 陳家豪 on 2020/8/30.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var stationTextField: UITextField!
    //宣告pickerView要使用的data
    var days = [String]()
    var hours = [String]()
    var minutes = [String]()
    var cities = [String]()
    var stationDictionary = [String:[String]]()
    //宣告要inputView要設定為pickerView的textField
    var pickerField:UITextField!
    //宣告要顯示在textField的變數
    var selectedDay = ""
    var selectedHour = ""
    var selectedMinute = ""
    var selectedCity = ""
    var selectedStation = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //將textField的delegate設為self
        dateTextField.delegate = self
        timeTextField.delegate = self
        stationTextField.delegate = self
        //取得pickerView要使用的data
        loadData()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pickerField?.resignFirstResponder()
    }
    func loadData() {
        days = DataController.shared.fetchDateData()
        
        let time = DataController.shared.fetchTimeData()
        hours = time["hours"]!
        minutes = time["minutes"]!
        
        guard let stationDictionary = DataController.shared.fetchStationData() else {return}
        self.stationDictionary = stationDictionary
        stationDictionary.keys.forEach({ (city) in
            cities.append(city)
        })
        cities.sort()
    }
    
    func initPickerView(touchAt sender:UITextField){
        //根據tag值判斷點的是哪個textField，設定不同的tag
        let pickerView = UIPickerView()
        if sender == dateTextField {
            pickerView.tag = 0
        }else if sender == timeTextField {
            pickerView.tag = 1
        }else if sender == stationTextField{
            pickerView.tag = 2
        }
        //將pickerView的delegate設為self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        //初始化pickerView上方的toolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()
        //加入toolbar的按鈕跟中間的空白
        let doneButton = UIBarButtonItem(title: "確認", style: .plain, target: self, action: #selector(submit))
        //將doneButton設定跟pickerView一樣的tag，submit方法裡可以比對要顯示哪個textField的text
        doneButton.tag = pickerView.tag
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        //設定toolBar可以使用
        toolBar.isUserInteractionEnabled = true
        
        //初始化textField，要先加入subView，才能設定他的inputView跟inputAccessoryView
        pickerField = UITextField(frame: CGRect.zero)
        view.addSubview(pickerField)
        pickerField.inputView = pickerView
        pickerField.inputAccessoryView = toolBar
        //彈出pickerField
        pickerField.becomeFirstResponder()
    }
    //設定toolBar的按鈕事件
    @objc func cancel(){
        self.pickerField?.resignFirstResponder()
    }
    @objc func submit(sender: UIBarButtonItem){
        //將選擇的日期時分跟車站顯示到textField
        let pickerViewTag = sender.tag
        if pickerViewTag == 0 {
            DispatchQueue.main.async { [self] in
                dateTextField.text = selectedDay
                self.pickerField?.resignFirstResponder()
            }
        }else if pickerViewTag == 1 {
            DispatchQueue.main.async { [self] in
                timeTextField.text = selectedHour + " " + selectedMinute
                self.pickerField?.resignFirstResponder()
            }
        }else if pickerViewTag == 2 {
            DispatchQueue.main.async { [self] in
                //要去掉城市前的編碼
                let numberIndex = selectedCity.index(selectedCity.startIndex, offsetBy: 2)
                let cityName = String(selectedCity.suffix(from: numberIndex))
                stationTextField.text = cityName + " " + selectedStation
                self.pickerField?.resignFirstResponder()
            }
        }
      
    }
}

extension ViewController: UITextFieldDelegate {
    //服從UITextFieldDelegate，當點擊textField後會呼叫delegate執行裡面的程式碼
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.initPickerView(touchAt: textField)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //按return會關掉picker view
        textField.resignFirstResponder()
        return true
    }
}


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //判斷pickerView的tag值來回傳有幾個component
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 1
        }else if pickerView.tag == 1 {
            return 2
        }else {
            return 2
        }
    }
    //判斷pickerView的tag值以及component來回傳有幾個row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return days.count
        }else if pickerView.tag == 1 {
            if component == 0 {
                return hours.count
            }else {
                return minutes.count
            }
        }else {
            if component == 0 {
                return cities.count
            }else {
                //第二個component的row數量要根據第一個component(index是0)選了哪一個row，再用這個selectedRow去取得對應的陣列
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                return stationDictionary[cities[selectedRow]]!.count
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //跟numberOfRowsInComponent概念一樣，不過要回傳的是該列要顯示的內容，型別為字串，用row去取得陣列的值
        if pickerView.tag == 0 {
            return days[row]
        }else if pickerView.tag == 1 {
            if component == 0 {
                return hours[row]
            }else {
                return minutes[row]
            }
        }else {
            if component == 0 {
                //要先把程式前的編號去掉再顯示，將字串前的兩個數字拿掉
                let citiesWithoutNumber = cities.map { (city) -> String in
                    let numberIndex = city.index(city.startIndex, offsetBy: 2)
                    return String(city.suffix(from: numberIndex))
                }
                return citiesWithoutNumber[row]
            }else {
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let stations = stationDictionary[cities[selectedRow]]
                return stations?[row]
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //將使用者選到的資料一對應的component跟row取得資料後指定給變數
        if pickerView.tag == 0 {
            self.selectedDay = days[row]
        } else if pickerView.tag == 1 {
            if component == 0 {
                self.selectedHour = hours[row]
            }else if component == 1 {
                self.selectedMinute = minutes[row]
            }
        }else {
            //當使用者選擇了第一個component的資料後，要reload第二個component(index是1)，資料才會更新
            pickerView.reloadComponent(1)
            if component == 0 {
                self.selectedCity = cities[row]
            }else if component == 1 {
                let stationsOfCity = stationDictionary[selectedCity]!
                self.selectedStation = stationsOfCity[row]
            }
        }
    }
}


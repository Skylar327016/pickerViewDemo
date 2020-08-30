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
    var days = [String]()
    var hours = [String]()
    var minutes = [String]()
    var cities = [String]()
    var stationDictionary = [String:[String]]()
    var pickerField:UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTextField.delegate = self
        timeTextField.delegate = self
        stationTextField.delegate = self
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
        
    }
    func initPickerView(touchAt sender:UITextField){
        let pickerView = UIPickerView()
        if sender == dateTextField {
            pickerView.tag = 0
        }else if sender == timeTextField {
            pickerView.tag = 1
        }else if sender == stationTextField{
            pickerView.tag = 2
        }
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .systemBlue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "確認", style: .plain, target: self, action: #selector(submit))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        pickerField = UITextField(frame: CGRect.zero)
        view.addSubview(pickerField)
        pickerField.inputView = pickerView
        pickerField.inputAccessoryView = toolBar
        pickerField.becomeFirstResponder()
    }
    @objc func cancel(){
        self.pickerField?.resignFirstResponder()
    }
    @objc func submit(){
        self.pickerField?.resignFirstResponder()
    }
}
extension ViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            self.initPickerView(touchAt: textField)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView.tag == 0 {
            return 1
        }else if pickerView.tag == 1 {
            return 2
        }else {
            return 2
        }
    }
    
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
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                return stationDictionary[cities[selectedRow]]!.count
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
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
                return cities[row]
            }else {
                let selectedRow = pickerView.selectedRow(inComponent: 0)
                let stations = stationDictionary[cities[selectedRow]]
                return stations?[row]
            }
        }
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadComponent(1)
    }
}


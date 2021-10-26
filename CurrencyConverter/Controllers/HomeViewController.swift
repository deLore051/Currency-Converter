//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 25.10.21..
//

import UIKit

class HomeViewController: UIViewController {
    
    private var currenciesFullName: [String] = []
    private var currenciesShorthand: [String] = []
    private var conversionRate: Double = 0.0
    
    
    private let datePickerTextField: UITextField = {
        let textField = UITextField()
        textField.clipsToBounds = true
        textField.placeholder = "Chose date for listing"
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.layer.borderColor = UIColor.label.cgColor
        textField.inputView = datePicker
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        
        return textField
    }()
    
    private let currency1TextField: UITextField = {
        let textField = UITextField()
        textField.clipsToBounds = true
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        return textField
    }()
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()

    private let currency2TextField: UITextField = {
        let textField = UITextField()
        textField.clipsToBounds = true
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        return textField
    }()
    
    private let amountToConvertTextField: UITextField = {
        let textField = UITextField()
        textField.clipsToBounds = true
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        return textField
    }()

    private let currency1Label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    private let conversionResultLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.label.cgColor
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 25
        return label
    }()
    
    private let currency2Label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    private let convertButton: UIButton = {
        let button = UIButton()
        button.setTitle("Convert", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        button.titleLabel?.textColor = UIColor.white
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        return button
    }()
    
    override func viewDidAppear(_ animated: Bool) {
        let networkMonitor = NetworkMonitor()
        networkMonitor.startMonitoring { [weak self] connected in
            guard let self = self else { return }
            guard connected else {
                print("Failed to reconnect in homeVC")
                DispatchQueue.main.async {
                    let vc = NoInternetViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
                return
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        getCurrencies()
        addSubviews()
        setUpPicker()
        convertButton.addTarget(self, action: #selector(didTapConvertButton), for: .touchUpInside)
        amountToConvertTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let networkMonitor = NetworkMonitor()
        networkMonitor.stopMonitoring()
    }
    
    private func setUpPicker() {
        currency1TextField.inputView = pickerView
        currency2TextField.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.currency1TextField.text = self.currenciesFullName[0]
            self.currency2TextField.text = self.currenciesFullName[0]
            self.currency1Label.text = self.currenciesShorthand[0]
            self.currency2Label.text = self.currenciesShorthand[0]
            self.amountToConvertTextField.text = "0.0"
            self.conversionResultLabel.text = "0.0"
        }
            
    }
    
    private func addSubviews() {
        view.addSubview(datePickerTextField)
        view.addSubview(currency1TextField)
        view.addSubview(currency2TextField)
        view.addSubview(amountToConvertTextField)
        view.addSubview(currency1Label)
        view.addSubview(conversionResultLabel)
        view.addSubview(currency2Label)
        view.addSubview(convertButton)
    }
    
    private func getCurrencies() {
        APICaller.shared.getAllCurrencies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                for (key, value) in model.currnecies {
                    self.currenciesFullName.append(value)
                    self.currenciesShorthand.append(key)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    @objc private func didTapConvertButton() {
        convertButton.tapEffect(sender: convertButton)
        guard let date = datePickerTextField.text, !date.isEmpty,
              let currency1 = currency1Label.text,
              let currency2 = currency2Label.text,
              let amount = amountToConvertTextField.text, !amount.isEmpty,
              amount != "0.0" else {
            let alert = UIAlertController(title: "Warning",
                                          message: "Fill in all fields before preceding.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        APICaller.shared.getConversionValue(
            date: date,
            currency1: currency1,
            currency2: currency2) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                self.conversionRate = model[currency2] as! Double
                let result = self.conversionRate * NSString(string: amount).doubleValue
                DispatchQueue.main.async {
                    self.conversionResultLabel.text = "\(result)"
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .full
        dateFormater.timeStyle = .none
        dateFormater.dateFormat = "yyyy-MM-dd"
        let date = dateFormater.string(from: sender.date)
        self.datePickerTextField.text = date
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let textFieldWidth: CGFloat = view.width - 40
        let textFieldHeight: CGFloat = 50
        
        datePickerTextField.frame = CGRect(x: 20,
                                           y: view.safeAreaInsets.top + 50,
                                           width: textFieldWidth,
                                           height: textFieldHeight)
        
        currency1TextField.frame = CGRect(x: 20,
                                          y: datePickerTextField.bottom + 30,
                                          width: textFieldWidth / 2 - 5,
                                          height: textFieldHeight)
        
        currency2TextField.frame = CGRect(x: currency1TextField.right + 10,
                                          y: datePickerTextField.bottom + 30,
                                          width: textFieldWidth / 2 - 5,
                                          height: textFieldHeight)
        
        amountToConvertTextField.frame = CGRect(x: 20,
                                                y: currency1TextField.bottom + 30,
                                                width: textFieldWidth / 1.5,
                                                height: textFieldHeight)
        
        currency1Label.frame = CGRect(x: amountToConvertTextField.right + 10,
                                      y: currency1TextField.bottom + 30,
                                      width: view.width - (textFieldWidth / 1.5) - 50,
                                      height: textFieldHeight)
        
        conversionResultLabel.frame = CGRect(x: 20,
                                             y: amountToConvertTextField.bottom + 30,
                                             width: textFieldWidth / 1.5,
                                             height: textFieldHeight)
        
        currency2Label.frame = CGRect(x: conversionResultLabel.right + 10,
                                      y: amountToConvertTextField.bottom + 30,
                                      width: view.width - (textFieldWidth / 1.5) - 50,
                                      height: textFieldHeight)

        convertButton.frame = CGRect(x: 20,
                                     y: conversionResultLabel.bottom + 100,
                                     width: textFieldWidth,
                                     height: textFieldHeight)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.datePickerTextField.layer.borderColor = UIColor.label.cgColor
        self.currency1TextField.layer.borderColor = UIColor.label.cgColor
        self.currency2TextField.layer.borderColor = UIColor.label.cgColor
        self.amountToConvertTextField.layer.borderColor = UIColor.label.cgColor
        self.conversionResultLabel.layer.borderColor = UIColor.label.cgColor
    }
    
}


extension HomeViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currenciesFullName.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currenciesFullName[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            currency1TextField.text = currenciesFullName[row]
            currency1Label.text = currenciesShorthand[row]
        case 1:
            currency2TextField.text = currenciesFullName[row]
            currency2Label.text = currenciesShorthand[row]
        default:
            fatalError()
        }
    }
    
}


extension HomeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        let arrayOfStrings = newString.components(separatedBy: ".")
        
        guard arrayOfStrings.count < 3 else { return false }
        return true
    }
    
    
    
}

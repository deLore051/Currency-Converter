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
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .systemBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.clipsToBounds = true
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 600)
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// Picker for the date of listing creation.
    private let datePickerTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 0
        textField.translatesAutoresizingMaskIntoConstraints = false
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
    
    /// Picker for the currency that we want to convert.
    private let currency1TextField: UITextField = {
        let textField = UITextField()
        textField.tag = 1
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        return textField
    }()
    
    /// Picker view that we use as input view for our text fields
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()

    /// Picker for the currency that we want our money to be converted to.
    private let currency2TextField: UITextField = {
        let textField = UITextField()
        textField.tag = 2
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clipsToBounds = true
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        return textField
    }()
    
    /// Input text field for the amount of money we want to exchange.
    private let amountToConvertTextField: UITextField = {
        let textField = UITextField()
        textField.tag = 3
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Enter amount to be exchanged"
        textField.clipsToBounds = true
        textField.font = .systemFont(ofSize: 18)
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.label.cgColor
        textField.layer.cornerRadius = 25
        textField.textAlignment = .center
        textField.keyboardType = .decimalPad
        return textField
    }()

    /// Shorthand label for the currency we are exchangeing.
    private let currency1Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    /// Label for amount of money we will get after converting the inputed currency.
    private let conversionResultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.label.cgColor
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 25
        return label
    }()
    
    /// Shorthand label for the currency we want our money to be exchanged to.
    private let currency2Label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.backgroundColor = .secondarySystemBackground
        label.clipsToBounds = true
        label.layer.cornerRadius = 25
        return label
    }()
    
    /// Convert button.
    private let convertButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
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
        addSubviews()
        setUpPicker()
        addConstraints()
        addTapGestureToContentAndScrollView()
        convertButton.addTarget(self, action: #selector(didTapConvertButton), for: .touchUpInside)
        amountToConvertTextField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let networkMonitor = NetworkMonitor()
        networkMonitor.stopMonitoring()
    }
    
    /// Method for adding tap gesture recognizer to our content view and scroll view.
    private func addTapGestureToContentAndScrollView() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapContentView))
        contentView.addGestureRecognizer(tap)
        scrollView.addGestureRecognizer(tap)
    }
    
    /// Method for setting up our currency picker, where we select the two currencies for exchange.
    private func setUpPicker() {
        currency1TextField.inputView = pickerView
        currency2TextField.inputView = pickerView
        pickerView.delegate = self
        pickerView.dataSource = self
        getCurrencies { [weak self] success in
            guard let self = self else { return }
            guard success else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currency1TextField.text = self.currenciesFullName[0]
                self.currency2TextField.text = self.currenciesFullName[0]
                self.currency1Label.text = self.currenciesShorthand[0]
                self.currency2Label.text = self.currenciesShorthand[0]
                self.conversionResultLabel.text = "0.0"
            }
        }
    }
    
    /// Method for adding subviews to our view.
    private func addSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(datePickerTextField)
        contentView.addSubview(currency1TextField)
        contentView.addSubview(currency2TextField)
        contentView.addSubview(amountToConvertTextField)
        contentView.addSubview(currency1Label)
        contentView.addSubview(conversionResultLabel)
        contentView.addSubview(currency2Label)
        contentView.addSubview(convertButton)
    }
    
    /// Method for retrieving available currencies in our listing.
    private func getCurrencies(completion: @escaping (Bool) -> Void) {
        APICaller.shared.getAllCurrencies { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let model):
                for (key, value) in model.currnecies {
                    self.currenciesFullName.append(value)
                    self.currenciesShorthand.append(key)
                    completion(true)
                }
            case .failure(let error):
                print(error.localizedDescription)
                completion(false)
            }
        }
    }
    
    /// Method for hiding picker after the user taps outside of the picker view.
    @objc private func didTapContentView() {
        self.view.endEditing(true)
    }

    /// Method for getting the conversion rate and converting the currencies after the convert button is tapped.
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
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.conversionResultLabel.text = "\(result)"
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    /// Method for showing the selected date in its text field after its value changes.
    @objc private func dateChanged(_ sender: UIDatePicker) {
        let dateFormater = DateFormatter()
        dateFormater.dateStyle = .full
        dateFormater.timeStyle = .none
        dateFormater.dateFormat = "yyyy-MM-dd"
        let date = dateFormater.string(from: sender.date)
        self.datePickerTextField.text = date
    }
    
    /// Method for setting up our ui elements constraints
    private func addConstraints() {
        
        // scrollView
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
        
        // contentView
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 600).isActive = true
        
        // datePickerTextField
        datePickerTextField.topAnchor
            .constraint(equalTo: contentView.topAnchor, constant: 50).isActive = true
        datePickerTextField.centerXAnchor
            .constraint(equalTo: contentView.centerXAnchor).isActive = true
        datePickerTextField.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, constant: -40).isActive = true
        datePickerTextField.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
        
        // currency1TextField
        currency1TextField.topAnchor
            .constraint(equalTo: datePickerTextField.bottomAnchor, constant: 30).isActive = true
        currency1TextField.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        currency1TextField.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -30).isActive = true
        currency1TextField.heightAnchor
            .constraint(equalToConstant: 50).isActive = true
        
        // currency2TextField
        currency2TextField.topAnchor
            .constraint(equalTo: datePickerTextField.bottomAnchor, constant: 30).isActive = true
        currency2TextField.leadingAnchor
            .constraint(equalTo: currency1TextField.trailingAnchor, constant: 20).isActive = true
        currency2TextField.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.5, constant: -30).isActive = true
        currency2TextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // amountToConvertTextField
        amountToConvertTextField.topAnchor
            .constraint(equalTo: currency1TextField.bottomAnchor, constant: 30).isActive = true
        amountToConvertTextField.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        amountToConvertTextField.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.75, constant: -30).isActive = true
        amountToConvertTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // currency1Label
        currency1Label.topAnchor
            .constraint(equalTo: currency1TextField.bottomAnchor, constant: 30).isActive = true
        currency1Label.leadingAnchor
            .constraint(equalTo: amountToConvertTextField.trailingAnchor, constant: 10).isActive = true
        currency1Label.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.25, constant: -20).isActive = true
        currency1Label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // conversionResultLabel
        conversionResultLabel.topAnchor
            .constraint(equalTo: amountToConvertTextField.bottomAnchor, constant: 30).isActive = true
        conversionResultLabel.leadingAnchor
            .constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        conversionResultLabel.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.75, constant: -30).isActive = true
        conversionResultLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // currency2Label
        currency2Label.topAnchor
            .constraint(equalTo: amountToConvertTextField.bottomAnchor, constant: 30).isActive = true
        currency2Label.leadingAnchor
            .constraint(equalTo: amountToConvertTextField.trailingAnchor, constant: 10).isActive = true
        currency2Label.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.25, constant: -20).isActive = true
        currency2Label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // convertButton
        convertButton.topAnchor
            .constraint(equalTo: conversionResultLabel.bottomAnchor, constant: 100).isActive = true
        convertButton.centerXAnchor
            .constraint(equalTo: contentView.centerXAnchor).isActive = true
        convertButton.widthAnchor
            .constraint(equalTo: contentView.widthAnchor, multiplier: 0.75).isActive = true
        convertButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    /// Method that updates border colors of our elements when the user switches between light and dark mode.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.datePickerTextField.layer.borderColor = UIColor.label.cgColor
        self.currency1TextField.layer.borderColor = UIColor.label.cgColor
        self.currency2TextField.layer.borderColor = UIColor.label.cgColor
        self.amountToConvertTextField.layer.borderColor = UIColor.label.cgColor
        self.conversionResultLabel.layer.borderColor = UIColor.label.cgColor
    }
    
}

//MARK: - UIPickerViewDelegate_DataSource

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

//MARK: - UITextFieldDelegate

extension HomeViewController: UITextFieldDelegate {
    
    // Method used to limit the user input in amount text field to only valid decimal values.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
        let arrayOfStrings = newString.components(separatedBy: ".")
        
        guard arrayOfStrings.count < 3 else { return false }
        return true
    }
}

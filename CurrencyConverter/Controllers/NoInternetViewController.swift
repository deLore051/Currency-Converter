//
//  NoInternetViewController.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 26.10.21..
//

import UIKit

class NoInternetViewController: UIViewController {

    /// No internet image view for warning image.
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(
            systemName: "wifi.exclamationmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 100))
        imageView.clipsToBounds = true
        imageView.tintColor = UIColor.label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// No internet label.
    private let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "No Internet Connection!"
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    /// Retry connection button.
    private let button: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Retry", for: .normal)
        button.clipsToBounds = true
        button.setTitleColor( .white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 22, weight: .medium)
        return button
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(label)
        view.addSubview(button)
        addConstraints()
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }
    
    /// Method for checking if the phone has internet connection again, after the retry button is tapped.
    @objc private func didTapRetry() {
        button.tapEffect(sender: button)
        let networkMonitor = NetworkMonitor()
        networkMonitor.startMonitoring { [weak self] connected in
            guard let self = self else { return }
            guard connected else {
                print("Failed to reconnect in noInternetVC")
                return
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let vc = HomeViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        networkMonitor.stopMonitoring()
    }
    
    private func addConstraints() {
        // imageView
        imageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        imageView.centerYAnchor
            .constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -50).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        // label
        label.topAnchor
            .constraint(equalTo: imageView.safeAreaLayoutGuide.bottomAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        label.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
        label.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // button
        button.topAnchor.constraint(equalTo: label.safeAreaLayoutGuide.bottomAnchor, constant: 50).isActive = true
        button.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        button.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.75).isActive = true
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        imageView.frame = CGRect(x: view.width / 2 - 75,
//                                 y: view.height / 2 - 200,
//                                 width: 150,
//                                 height: 150)
//
//        label.frame = CGRect(x: 20,
//                             y: imageView.bottom + 5,
//                             width: view.width - 40,
//                             height: 30)
//
//        button.frame = CGRect(x: 30,
//                              y: label.bottom + 50,
//                              width: view.width - 60,
//                              height: 50)
//    }
    
    
}

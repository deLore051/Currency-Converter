//
//  NoInternetViewController.swift
//  CurrencyConverter
//
//  Created by Stefan Dojcinovic on 26.10.21..
//

import UIKit

class NoInternetViewController: UIViewController {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(
            systemName: "wifi.exclamationmark",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 100))
        imageView.clipsToBounds = true
        imageView.tintColor = UIColor.label
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "No Internet Connection!"
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
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
        button.addTarget(self, action: #selector(didTapRetry), for: .touchUpInside)
    }
    
    @objc private func didTapRetry() {
        let networkMonitor = NetworkMonitor()
        networkMonitor.startMonitoring { [weak self] connected in
            guard let self = self else { return }
            guard connected else {
                print("Failed to reconnect in noInternetVC")
                return
            }
            DispatchQueue.main.async {
                let vc = HomeViewController()
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
        networkMonitor.stopMonitoring()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: view.width / 2 - 75,
                                 y: view.height / 2 - 200,
                                 width: 150,
                                 height: 150)
        
        label.frame = CGRect(x: 20,
                             y: imageView.bottom + 5,
                             width: view.width - 40,
                             height: 30)
        
        button.frame = CGRect(x: 30,
                              y: label.bottom + 50,
                              width: view.width - 60,
                              height: 50)
    }
    
    
}

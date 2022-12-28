//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 26.12.2022.
//

import UIKit

class AlertPresenter {
    weak var controller: UIViewController?

    func show(model: AlertModel) {
        let alert = UIAlertController(
            title: model.title,
            message: model.message,
            preferredStyle: .alert
        )
            
        let action = UIAlertAction(
            title: model.buttonText,
            style: .default
        ) { _ in
            model.completion()
        }
            
        alert.addAction(action)
        
        controller?.present(alert, animated: true, completion: nil)
    }
}

//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 26.12.2022.
//

import Foundation

typealias VoidCompletionHandler = () -> Void

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: VoidCompletionHandler
}

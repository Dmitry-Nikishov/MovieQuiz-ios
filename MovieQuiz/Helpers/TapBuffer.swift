//
//  TapBuffer.swift
//  MovieQuiz
//
//  Created by Дмитрий Никишов on 11.12.2022.
//

import Foundation

public class TapBuffer {
  /// Delay between tapping
  private let delay: Double

  /// Queue for search
  private let queue: DispatchQueue

  /// Dispatch work item
  private var workItem: DispatchWorkItem?

  /// Init with 'queue', 'delay'
  ///
  /// - Parameters:
  ///     - queue: Wotk queue
  ///     - delay: Delay between input characters
  public init(queue: DispatchQueue, delay: Double = 0.8) {
    self.queue = queue
    self.delay = delay
  }

  /// Search by text
  public func tap(_ closure: @escaping () -> Void) {
    self.workItem?.cancel()

    self.workItem = DispatchWorkItem {
      closure()
    }

    if let workItem = self.workItem {
      self.queue.asyncAfter(deadline: .now() + self.delay, execute: workItem)
    }
  }
}


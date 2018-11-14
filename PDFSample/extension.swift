//
//  extension.swift
//  PDFSample
//
//  Created by kou on 2018/11/14.
//  Copyright © 2018 kou. All rights reserved.
//

import Foundation

extension String {
    func split(range: Int) -> (String, String) {
        let firstTrimmedText = String(self.prefix(range))
        let trimmedText = self.suffix(self.count - range)
        let secondTrimmedText = String(trimmedText.prefix(range))
        return (firstTrimmedText, secondTrimmedText)
    }
}

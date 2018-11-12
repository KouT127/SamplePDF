//
//  ViewController.swift
//  PDFSample
//
//  Created by kou on 2018/11/09.
//  Copyright © 2018 kou. All rights reserved.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdf = PDFDocument()
        let contents = ["hoge", "hoge2", "hoge3"]
        let firstPage = PdfPages(title: "サンプル", contents:contents)
        pdf.insert(firstPage, at: 0)
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = url.appendingPathComponent("sample.pdf")
            print(path)
            pdf.write(to: path)
        }
    }


}

class PdfPages: PDFPage {
    private let width = 900
    private let height = 1000
    private let title: String
    private let contents: [String]
    
    init(title: String, contents: [String]) {
        self.title = title
        self.contents = contents
        super.init()
    }
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        let path = UIBezierPath()
        UIGraphicsPushContext(context)
        context.translateBy(x: 0.0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        let rect = CGRect(x: 25, y: 25, width: width, height: 100)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 50),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        title.draw(in: rect, withAttributes: attributes)
        
        var contentY: Int = 0
        var cnt = 1
        
        for content in contents {
            contentY = cnt * 200
            let contentRect = CGRect(x: 25, y: contentY, width: width, height: 600)
            content.draw(in: contentRect, withAttributes: attributes)
            
            path.move(to: CGPoint(x: 0, y: contentY + 60))
            path.addLine(to: CGPoint(x: width, y: contentY + 50))
            path.lineWidth = 2.0
            path.stroke()
            
            cnt += 1
        }

        UIGraphicsPopContext()
    }
    
    override func bounds(for box: PDFDisplayBox) -> CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
}

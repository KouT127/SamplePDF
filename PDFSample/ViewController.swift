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
        let firstPage = PdfPages(width: 900, height: 1000, title: "サンプル", contents:contents)
        pdf.insert(firstPage, at: 0)
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = url.appendingPathComponent("sample.pdf")
            print(path)
            pdf.write(to: path)
        }
    }


}

class PdfPages: PDFPage {
    private let width: Int
    private let height: Int
    private let title: String
    private let contents: [String]
    private let path = UIBezierPath()
    
    private let titleFontSize = 40
    private let fontSize = 20
    private let titleOffsetY = 25
    
    init(width: Int, height: Int, title: String, contents: [String]) {
        self.title = title
        self.contents = contents
        self.width = width
        self.height = height
        super.init()
    }
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        UIGraphicsPushContext(context)
        //原点の指定　左上
        context.translateBy(x: 0.0, y: CGFloat(height))
        //倍率指定
        context.scaleBy(x: 1.0, y: -1.0)
        
        titleDraw(title: title)
        contentDraw(content: contents)
        
        //中心線　確認用
        //縦線
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.lineWidth = 1.0
        path.stroke()
        
        UIGraphicsPopContext()
    }
    
    private func titleDraw(title: String) {
        let titleHalfCount = title.count / 2
        //位置指定
        let titleRect = CGRect(x: (width / 2) - (titleHalfCount * titleFontSize), y: titleOffsetY, width: width, height: 25)
        //文字の形式の指定
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(titleFontSize)),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        title.draw(in: titleRect, withAttributes: attributes)
    }
    
    private func headerDraw(headers: [String: String]){
        var contentY = titleOffsetY + 20
        var contentX: Int = 0
    }
    
    private func contentDraw(content: [String]) {
        //初期オフセット
        var contentY = titleOffsetY + 20
        var contentX: Int = 0
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        
        addLine(from: CGPoint(x: 10, y: contentY + 30), to: CGPoint(x: width - 10, y: contentY + 30))
        contentY += 30
        
        for content in contents {
            let contentRect = CGRect(x: 15, y: contentY, width: width, height: 30)
            content.draw(in: contentRect, withAttributes: attributes)
            gridDraw(x: 25, y: contentY)
            contentY += 30
            contentX += 25
        }
    }
    
    private func gridDraw(x: Int, y: Int) {
        //始点、終点、線の太さ、描画
        //横線
        addLine(from: CGPoint(x: 10, y: y + 30), to: CGPoint(x: width - 10, y: y + 30))
        addLine(from: CGPoint(x: 10, y: y + 30), to: CGPoint(x: width - 10, y: y + 30))
        //縦線
        addLine(from: CGPoint(x: 10, y: y), to: CGPoint(x: 10, y: y + 30))
        addLine(from: CGPoint(x: width - 10, y: y), to: CGPoint(x: width - 10, y: y + 30))
        
        addLine(from: CGPoint(x: (width - 10) / 1, y: y), to: CGPoint(x: (width - 10) / 1, y: y + 30))
        addLine(from: CGPoint(x: width - 10, y: y), to: CGPoint(x: width - 10, y: y + 30))
    }
    
    private func addLine(from: CGPoint, to: CGPoint) {
        path.move(to: from)
        path.addLine(to: to)
        path.lineWidth = 1.0
        path.stroke()
    }
    
    override func bounds(for box: PDFDisplayBox) -> CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }
}



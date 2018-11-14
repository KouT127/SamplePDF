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
        
        let header1 = HeaderContent(title: "あ:", content: "ヘッダー内容")
        let header2 = HeaderContent(title: "あいう:", content: "ヘッダー内容")
        let header3 = HeaderContent(title: "あいうえお:", content: "ヘッダー内容")
        let header4 = HeaderContent(title: "あいうえお", content: "ヘッダー内容")
        let headers = [header1, header2, header3, header4]
        var content = GridContent(code: "123456789012345023456789012345", name: "あいうえおかきくけこさしすせそたちつてと", qty: 10000)
        var contents: [GridContent] = []
        
        for i in 100 ..< 111 {
            content.no = i
            contents.append(content)
        }
        
        let data = FormContent(title: "サンプル", headers: headers, contents: contents)
        let setting = LayoutSetting(formContent: data, width: 1020, height: 1700)
        
        let firstPage = PdfForm(formContent: data, setting: setting)
        
        pdf.insert(firstPage, at: 0)
        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let path = url.appendingPathComponent("sample.pdf")
            print(path)
            pdf.write(to: path)
        }
    }
}

class PdfForm: PDFPage {
    
    private let formContent: FormContent
    private let setting: LayoutSetting
    private let path = UIBezierPath()
    private let firstCharacterOffset: Int
    
    init(formContent: FormContent, setting: LayoutSetting) {
        self.formContent = formContent
        self.setting = setting
        self.firstCharacterOffset = setting.firstCharacterOffset
        super.init()
    }
    
    override func draw(with box: PDFDisplayBox, to context: CGContext) {
        super.draw(with: box, to: context)
        UIGraphicsPushContext(context)
        //原点の指定　左上
        context.translateBy(x: 0.0, y: CGFloat(setting.height))
        //倍率指定
        context.scaleBy(x: 1.0, y: -1.0)
        
        titleDraw(title: formContent.title)
        headerDraw(headers: formContent.headers)
        gridHeaderDraw(contents: formContent.contents)
        contentDraw(contents: formContent.contents)
        
        UIGraphicsPopContext()
    }
    
    private func titleDraw(title: String) {
        let startOffsetY = setting.titleStartOffset
        let titleFontSize = setting.titleFontSize
        let titleHalfCount = title.count / 2
        //位置指定
        let titleRect = CGRect(x: (setting.width / 2) - (titleHalfCount * titleFontSize), y: startOffsetY, width: setting.width, height: titleFontSize)
        //文字の形式の指定
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(titleFontSize)),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        title.draw(in: titleRect, withAttributes: attributes)
    }
    
    private func headerDraw(headers: [HeaderContent]){
        let vertical = setting.headerStartY
        let horizontal = setting.startX
        var cnt = 1
        var line = 0
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(setting.headerFontSize)),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        
        for header in headers {
            let offsetHorizon = (cnt % 2 == 0)
            let offsetVertical = line / 2
            let headerHorizontal: Int = offsetHorizon ? horizontal + setting.writableWidth / 2  : horizontal
            
            // ヘッダー同士の隙間のオフセットを直打ち
            let headerVertical: Int = vertical + offsetVertical * (setting.headerFontSize + 15)
            let titleRect = CGRect(x: headerHorizontal, y: headerVertical, width: setting.writableWidth / 2, height: setting.headerEndY)
            header.title.draw(in: titleRect, withAttributes: attributes)
            
            let contentOffsetVertical = header.title.count * setting.headerFontSize
            let contentRect  = CGRect(x: headerHorizontal + contentOffsetVertical, y: headerVertical, width: setting.writableWidth / 2, height: setting.headerEndY)
            header.content.draw(in: contentRect, withAttributes: attributes)
            cnt += 1
            line += 1
        }
    
    }
    
    private func gridHeaderDraw(contents: [GridContent]) {
        let vertical = setting.contentHeaderStartY
        let horizontal = setting.startX
        let width = setting.writableWidth
        let fontSize = setting.contentHeaderFontSize
        
        let endVertical = setting.contentHeaderEndY
        let endHorizontal = setting.endX
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        // No: 0.1 code: 0.3, name: 0.4, qty: 0.1 の割合
        let codeHorizontal = Double(width) * 0.07
        let nameHorizontal = Double(width) * 0.34
        let qtyHorizontal = Double(width) * 0.9
        
        let content = contents.first
        
        let noRect = CGRect(x: horizontal + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
        content?.noTitle.draw(in: noRect, withAttributes: attributes)
        
        let codeRect = CGRect(x: Int(codeHorizontal) + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
        content?.codeTitle.draw(in: codeRect, withAttributes: attributes)
        
        let nameRect = CGRect(x: Int(nameHorizontal) + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
        content?.nameTitle.draw(in: nameRect, withAttributes: attributes)
        
        let qtyRect = CGRect(x: Int(qtyHorizontal) + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
        content?.qtyTitle.draw(in: qtyRect, withAttributes: attributes)
        
        //縦線
        verticalGridDraw(xPoints: [horizontal, Int(codeHorizontal), Int(nameHorizontal), Int(qtyHorizontal), endHorizontal], startY: vertical, endY: endVertical)
        
        //横線
        addLine(from: CGPoint(x: horizontal, y: vertical), to: CGPoint(x: endHorizontal, y: vertical))
        addLine(from: CGPoint(x: horizontal, y: endVertical), to: CGPoint(x: endHorizontal, y: endVertical))
    }
    
    private func contentDraw(contents: [GridContent]) {
        var vertical = setting.contentStartY
        let width = setting.writableWidth
        let fontSize = setting.contentFontSize
        var endVertical = setting.contentEndY
        //行間のサイズ
        let offset = endVertical - vertical
        
        let horizontal = setting.startX
        let endHorizontal = setting.endX
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        // No: 0.1 code: 0.3, name: 0.4, qty: 0.2 の割合
        let codeHorizontal = Double(width) * 0.07
        let nameHorizontal = Double(width) * 0.34
        let qtyHorizontal = Double(width) * 0.9
        
        for content in contents {
            
            if let no = content.no {
                let noRect = CGRect(x: horizontal + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
                no.description.draw(in: noRect, withAttributes: attributes)
            }
            
            let (firstCode, secondCode) = content.code.split(range: 15)
            
            let codeRect = CGRect(x: Int(codeHorizontal) + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
            firstCode.draw(in: codeRect, withAttributes: attributes)
            let secondCodeRect = CGRect(x: Int(codeHorizontal) + firstCharacterOffset, y: vertical + 60 , width: width, height: endVertical)
            secondCode.draw(in: secondCodeRect, withAttributes: attributes)
            
            let (firstName, secondName) = content.name.split(range: 20)
            
            let firstNameRect = CGRect(x: Int(nameHorizontal) + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
            firstName.draw(in: firstNameRect, withAttributes: attributes)
            let secondNameRect = CGRect(x: Int(nameHorizontal) + firstCharacterOffset, y: vertical + 60 , width: width, height: endVertical)
            secondName.draw(in: secondNameRect, withAttributes: attributes)
            
            let qtyRect = CGRect(x: Int(qtyHorizontal) + firstCharacterOffset, y: vertical + 10 , width: width, height: endVertical)
            "99,999".draw(in: qtyRect, withAttributes: attributes)
            //content.qty.description.draw(in: qtyRect, withAttributes: attributes)
            
            //縦線
            verticalGridDraw(xPoints: [horizontal, Int(codeHorizontal), Int(nameHorizontal), Int(qtyHorizontal), endHorizontal], startY: vertical, endY: endVertical)
            //横線
            addLine(from: CGPoint(x: horizontal, y: endVertical), to: CGPoint(x: endHorizontal, y: endVertical))
            vertical += offset
            endVertical += offset
        }
    }
    
    private func verticalGridDraw(xPoints: [Int], startY: Int, endY: Int) {
        for x in xPoints {
            addLine(from: CGPoint(x: x, y: startY), to: CGPoint(x: x, y: endY))
        }
    }
    
    private func addLine(from: CGPoint, to: CGPoint) {
        path.move(to: from)
        path.addLine(to: to)
        path.lineWidth = 1.0
        path.stroke()
    }
    
    override func bounds(for box: PDFDisplayBox) -> CGRect {
        return CGRect(x: 0, y: 0, width: setting.width, height: setting.height)
    }
}

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
        
        let header1 = HeaderContent(title: "ヘッダー1", content: "ヘッダーだよ〜")
        let header2 = HeaderContent(title: "ヘッダー2", content: "ヘッダーだよ〜")
        let header3 = HeaderContent(title: "ヘッダ-3", content: "ヘッダーだよ〜")
        let headers = [header1, header2, header3]
        let content = GridContent(code: "コード", name: "名前", qty: 10)
        
        let data = FormContent(title: "サンプル", headers: headers, contents: [content])
        let setting = LayoutSetting(formContent: data, width: 1020, height: 2970)
        
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
//    private let width: Int
//    private let height: Int
//    private let title: String
//    private let contents: [String]
    
    private let formContent: FormContent
    private let setting: LayoutSetting
    private let path = UIBezierPath()
    
    private let titleFontSize = 40
    private let fontSize = 20
    private let titleOffsetY = 25
    
    init(formContent: FormContent, setting: LayoutSetting) {
        self.formContent = formContent
        self.setting = setting
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
//        contentDraw(contents: formContent.contents)
        
        //中心線　確認用
        //縦線
        path.move(to: CGPoint(x: setting.width / 2, y: 0))
        path.addLine(to: CGPoint(x: setting.width / 2, y: setting.height))
        path.lineWidth = 1.0
        path.stroke()
        
        UIGraphicsPopContext()
    }
    
    private func titleDraw(title: String) {
        let titleHalfCount = title.count / 2
        //位置指定
        let titleRect = CGRect(x: (setting.width / 2) - (titleHalfCount * titleFontSize), y: titleOffsetY, width: setting.width, height: setting.titleFontSize)
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
        let fontSize = setting.contentFontSize
        
        let endVertical = setting.contentHeaderEndY
        let endHorizontal = setting.endX
        
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: CGFloat(fontSize)),
                          NSAttributedString.Key.foregroundColor: UIColor.black]
        // code: 0.3, name: 0.5, qty: 0.2 の割合
        let nameHorizontal = Double(width) * 0.3
        let qtyHorizontal = Double(width) * 0.8
        
        addLine(from: CGPoint(x: horizontal, y: vertical), to: CGPoint(x: setting.endX, y: vertical))
        let content = contents.first
        addLine(from: CGPoint(x: horizontal, y: vertical), to: CGPoint(x: horizontal, y: endVertical))
        let codeRect = CGRect(x: horizontal + 5, y: vertical + 10 , width: setting.writableWidth, height: setting.headerEndY)
        content?.codeTitle.draw(in: codeRect, withAttributes: attributes)
        
        addLine(from: CGPoint(x: Int(nameHorizontal), y: vertical), to: CGPoint(x: Int(nameHorizontal), y: endVertical))
        let nameRect = CGRect(x: Int(nameHorizontal) + 5, y: vertical + 10 , width: setting.writableWidth, height: setting.headerEndY)
        content?.nameTitle.draw(in: nameRect, withAttributes: attributes)
        
        addLine(from: CGPoint(x: Int(qtyHorizontal), y: vertical), to: CGPoint(x: Int(qtyHorizontal), y: endVertical))
        let qtyRect = CGRect(x: Int(qtyHorizontal) + 5, y: vertical + 10 , width: setting.writableWidth, height: setting.headerEndY)
        content?.qtyTitle.draw(in: qtyRect, withAttributes: attributes)
        
        addLine(from: CGPoint(x: endHorizontal, y: vertical), to: CGPoint(x: endHorizontal, y: endVertical))
        
        addLine(from: CGPoint(x: horizontal, y: endVertical), to: CGPoint(x: setting.endX, y: endVertical))
//        for content in contents {
//            let offsetHorizon = (cnt % 2 == 0)
//            let offsetVertical = line / 2
//            let headerHorizontal: Int = offsetHorizon ? horizontal + setting.writableWidth / 2  : horizontal
//
//            // ヘッダー同士の隙間のオフセットを直打ち
//            let headerVertical: Int = vertical + offsetVertical * (setting.headerFontSize + 15)
//            let titleRect = CGRect(x: headerHorizontal, y: headerVertical, width: setting.writableWidth / 2, height: setting.headerEndY)
//            header.title.draw(in: titleRect, withAttributes: attributes)
//
//            let contentOffsetVertical = header.title.count * setting.headerFontSize
//            let contentRect  = CGRect(x: headerHorizontal + contentOffsetVertical, y: headerVertical, width: setting.writableWidth / 2, height: setting.headerEndY)
//            header.content.draw(in: contentRect, withAttributes: attributes)
//            cnt += 1
//            line += 1
//        }
    }
    
    private func contentDraw(contents: [GridContent]) {
//        var vertical: Int = setting.contentStartY
//        var horizontal: Int = 0
//        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20),
//                          NSAttributedString.Key.foregroundColor: UIColor.black]
//
//        addLine(from: CGPoint(x: 10, y: vertical), to: CGPoint(x: setting.width - 10, y: vertical))
//        vertical += 30
//
//        for content in contents {
//            let contentRect = CGRect(x: 15, y: setting.contentStartY, width: setting.width, height: 30)
//            content.code.draw(in: contentRect, withAttributes: attributes)
//            horizontal += 25
//            content.name.draw(in: contentRect, withAttributes: attributes)
//            horizontal += 25
//            content.qty.description.draw(in: contentRect, withAttributes: attributes)
//            horizontal += 25
//            gridDraw(x: 25, y: vertical)
//            vertical += 30
//        }
    }
    
    private func gridDraw(x: Int, y: Int) {
        //始点、終点、線の太さ、描画
        //横線
        addLine(from: CGPoint(x: 10, y: y + 30), to: CGPoint(x: setting.width - 10, y: y + 30))
        addLine(from: CGPoint(x: 10, y: y + 30), to: CGPoint(x: setting.width - 10, y: y + 30))
        //縦線
        addLine(from: CGPoint(x: 10, y: y), to: CGPoint(x: 10, y: y + 30))
        addLine(from: CGPoint(x: setting.width - 10, y: y), to: CGPoint(x: setting.width - 10, y: y + 30))
        
        addLine(from: CGPoint(x: (setting.width - 10) / 1, y: y), to: CGPoint(x: (setting.width - 10) / 1, y: y + 30))
        addLine(from: CGPoint(x: setting.width - 10, y: y), to: CGPoint(x: setting.width - 10, y: y + 30))
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



struct FormContent {
    let title: String
    var headers: [HeaderContent]
    var contents: [GridContent]
    
    init(title: String, headers: [HeaderContent], contents: [GridContent]) {
        self.title = title
        self.headers = headers
        self.contents = contents
    }
}

struct HeaderContent {
    let title: String
    let content: String
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
    }
}

struct GridContent {
    let code: String
    let name: String
    let qty: Int
    
    init (code: String, name: String, qty: Int) {
        self.code = code
        self.name = name
        self.qty = qty
    }
    
    var codeTitle: String { return "コード"}
    var nameTitle: String { return "名前"}
    var qtyTitle: String { return "数量"}
}

struct LayoutSetting {
    
    let formContent: FormContent
    
    let width: Int
    let height: Int
    //現状決め打ち
    let marginTop: Int = 10
    let marginLeft: Int = 25
    let marginRight: Int = 25
    let margintBottom: Int = 10

    let titleFontSize: Int
    let headerFontSize: Int
    let contentHeaderFontSize: Int
    let contentFontSize: Int
    
    let startOffset: Int
    let defaultOffset: Int = 10
    
    init(formContent: FormContent, width: Int, height: Int, titleFontSize: Int = 40, headerFontSize: Int = 20,contentHeaderFontSize: Int = 30 ,contentFontSize: Int = 20, startOffset: Int = 25) {
        self.formContent = formContent
        self.width = width
        self.height = height
        self.titleFontSize = titleFontSize
        self.headerFontSize = headerFontSize
        self.contentHeaderFontSize = contentHeaderFontSize
        self.contentFontSize = contentFontSize
        self.startOffset = startOffset
    }
    
    var headerLine: Int { return formContent.headers.count / 2 + 1}
    var contentLine: Int  { return formContent.contents.count }
    
    //マージンを考慮した大きさ
    var writableWidth: Int { return width - marginLeft - marginRight }
    var writableHeight: Int { return height - marginTop - margintBottom }
    
    //Y軸
    //TODO:Offset決め打ち
    var titleStartY: Int { return startOffset + marginTop }
    var titleEndY: Int { return titleStartY + titleFontSize + 15 }
    
    var headerStartY: Int { return titleEndY + defaultOffset }
    var headerEndY: Int { return headerStartY + (headerFontSize + 15) * headerLine + 15}
    
    var contentHeaderStartY: Int { return headerEndY + defaultOffset }
    var contentHeaderEndY: Int { return contentHeaderStartY + contentFontSize + 25 }
    
    //X軸
    var startX: Int { return marginLeft }
    var endX: Int { return width - marginRight}
}

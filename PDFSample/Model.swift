//
//  Model.swift
//  PDFSample
//
//  Created by kou on 2018/11/14.
//  Copyright © 2018 kou. All rights reserved.
//

import Foundation

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
    let line: Int
    
    init(title: String, content: String, line: Int = 1) {
        self.title = title
        self.content = content
        self.line = line
    }
}

struct GridContent {
    var no: Int?
    let code: String
    let name: String
    let qty: Int
    
    init (no: Int? = nil, code: String, name: String, qty: Int) {
        self.no = no
        self.code = code
        self.name = name
        self.qty = qty
    }
    
    var noTitle: String { return "No."}
    var codeTitle: String { return "コード"}
    var nameTitle: String { return "名前"}
    var qtyTitle: String { return "数量"}
}

struct FontSize {
    let titleFontSize: Int
    let headerFontSize: Int
    let contentHeaderFontSize: Int
    let contentFontSize: Int
    
    init(titleFontSize: Int = 0, headerFontSize: Int = 0, contentHeaderFontSize: Int = 0, contentFontSize: Int = 0) {
        self.titleFontSize = titleFontSize
        self.headerFontSize = headerFontSize
        self.contentHeaderFontSize = contentHeaderFontSize
        self.contentFontSize = contentFontSize
    }
}

struct LayoutSetting {
    
    let formContent: FormContent
    
    let width: Int
    let height: Int
    
    let fontSizes: FontSize
    //各マージン
    let marginTop: Int = 0
    let marginLeft: Int = 0
    let marginRight: Int = 0
    let margintBottom: Int = 0
    
    let titleStartOffset: Int = 25
    //各パーツ毎のオフセット
    let defaultOffset: Int = 10
    //先頭文字のオフセット
    let firstCharacterOffset: Int = 3
    //表内のオフセット
    let firstVerticalOffset: Int = 10
    let secondVerticalOffset: Int = 60
    
    enum Page {
        case first
        case other
        
        func getFontSize() -> FontSize {
            switch self {
            case .first:
                return FontSize(titleFontSize: 70, headerFontSize: 32, contentHeaderFontSize: 33, contentFontSize: 30)
            case .other:
                return FontSize(contentHeaderFontSize: 33, contentFontSize: 30)
            }
        }
    }
    
    init(page: Page, formContent: FormContent, width: Int, height: Int) {
        self.fontSizes = page.getFontSize()
        self.formContent = formContent
        self.width = width
        self.height = height
    }
}

extension LayoutSetting {
    
    //FontSize
    var titleFontSize: Int { return fontSizes.titleFontSize }
    var headerFontSize: Int { return fontSizes.headerFontSize}
    var contentHeaderFontSize: Int { return fontSizes.contentHeaderFontSize }
    var contentFontSize: Int { return fontSizes.contentFontSize }
    
    //行間
    var contentHeaderRowSize: Int { return contentHeaderFontSize + 25}
    var contentRowSize: Int { return (contentFontSize + 25) * 2}
    
    //-2は位置合わせ
    var headerLine: Int { return formContent.headers.map {$0.line}.reduce(0){$0 + $1} - 2}
    var contentLine: Int  { return formContent.contents.count }
    
    //マージンを考慮した大きさ
    var writableWidth: Int { return width - marginLeft - marginRight }
    var writableHeight: Int { return height - marginTop - margintBottom }
    
    //Y軸
    //TODO:Offset決め打ち
    var titleStartY: Int { return titleStartOffset + marginTop }
    var titleEndY: Int { return titleStartY + titleFontSize }
    
    var headerStartY: Int { return titleEndY + defaultOffset }
    var headerEndY: Int { return headerStartY + (headerFontSize) * headerLine + 10}
    
    var contentHeaderStartY: Int { return headerEndY }
    var contentHeaderEndY: Int { return contentHeaderStartY + contentHeaderRowSize }
    
    var contentStartY: Int { return contentHeaderEndY  }
    var contentEndY: Int { return contentStartY + contentRowSize }
    
    //X軸
    var startX: Int { return marginLeft }
    var endX: Int { return width - marginRight}
}

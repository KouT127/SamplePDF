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
    
    init(title: String, content: String) {
        self.title = title
        self.content = content
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

struct LayoutSetting {
    
    let formContent: FormContent
    
    let width: Int
    let height: Int
    //各マージン
    let marginTop: Int = 0
    let marginLeft: Int = 0
    let marginRight: Int = 0
    let margintBottom: Int = 0
    
    //FontSize
    let titleFontSize: Int = 80
    let headerFontSize: Int = 35
    let contentHeaderFontSize: Int = 35
    let contentFontSize: Int = 30
    
    //行間
    var contentHeaderRowSize: Int { return contentHeaderFontSize + 25}
    var contentRowSize: Int { return (contentFontSize + 25) * 2}
    
    let titleStartOffset: Int = 25
    //各パーツ毎のオフセット
    let defaultOffset: Int = 10
    //先頭文字のオフセット
    let firstCharacterOffset: Int = 3
    
    init(formContent: FormContent, width: Int, height: Int) {
        self.formContent = formContent
        self.width = width
        self.height = height
    }
    
    var headerLine: Int { return formContent.headers.count / 2 + 1}
    var contentLine: Int  { return formContent.contents.count }
    
    //マージンを考慮した大きさ
    var writableWidth: Int { return width - marginLeft - marginRight }
    var writableHeight: Int { return height - marginTop - margintBottom }
    
    //Y軸
    //TODO:Offset決め打ち
    var titleStartY: Int { return titleStartOffset + marginTop }
    var titleEndY: Int { return titleStartY + titleFontSize }
    
    var headerStartY: Int { return titleEndY + defaultOffset }
    var headerEndY: Int { return headerStartY + (headerFontSize) * headerLine}
    
    var contentHeaderStartY: Int { return headerEndY }
    var contentHeaderEndY: Int { return contentHeaderStartY + contentHeaderRowSize }
    
    var contentStartY: Int { return contentHeaderEndY  }
    var contentEndY: Int { return contentStartY + contentRowSize }
    
    //X軸
    var startX: Int { return marginLeft }
    var endX: Int { return width - marginRight}
}

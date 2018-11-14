//
//  SampleViewController.swift
//  PDFSample
//
//  Created by bird on 2018/11/14.
//  Copyright © 2018 kou. All rights reserved.
//

import UIKit
import PDFKit
import TPPDF

class SampleViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pdf = PDFDocument()
        
        let header1 = HeaderContent(title: "あいう:", content: "あいうえおかきくけこあいうえおかきくけこあいうえおかきくけこ", line: 2)
        let header2 = HeaderContent(title: "あいうえ:", content: "1234567890123456789012345678901234567890", line: 2)
        let header3 = HeaderContent(title: "あいうえ:", content: "2018/12/12 00:00")
        let header4 = HeaderContent(title: "あい:", content: "あいう　えおか")
        let headers = [header1, header2, header3, header4]
        var content = GridContent(code: "123456789012345023456789012345", name: "あいうえおかきくけこさしすせそたちつてと", qty: 10000)
        var contents: [GridContent] = []
        
        for i in 1 ..< 14 {
            content.no = i
            contents.append(content)
        }
        
        let data = FormContent(title: "サンプル", headers: headers, contents: contents)
        let setting = LayoutSetting(page: .first, formContent: data, width: 1020, height: 1600)
        
        let firstPage = PdfForm(formContent: data, setting: setting)
        
//        pdf.insert(firstPage, at: 0)
//        if let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
//            let path = url.appendingPathComponent("sample.pdf")
//            print(path)
//            pdf.write(to: path)
//        }
        generateExamplePDF()
    }
    
    func generateExamplePDF() {
        let document = PDFDocument(format: .a4)
        let table = PDFTable()
        
        // Set document meta data
        document.info.title = "TPPDF Example"
        document.info.subject = "Building a PDF easily"
        
        // Set spacing of header and footer
        document.layout.space.header = 5
        document.layout.space.footer = 5
        
        
        document.addText(text: "あいう")
        document.addSpace(space: 10)
        
        let section1 = PDFSection(columnWidths: [0.5,0.5])
        section1.columns[0].addText(.left, text: "left")
        section1.columns[1].addText(.left, text: "left")
        section1.columns[0].setTextColor(color: UIColor.red)
        document.addSection(section1)
        
        let section2 = PDFSection(columnWidths: [0.5,0.5])
        section2.columns[0].addText(.left, text: "left")
        section2.columns[1].addText(.left, text: "left")
        
        document.addSection(section2)
        
        do {
            try table.generateCells(
                data:
                [
                    ["No", "Name", "Image", "Description"],
                    ["1000", "123456789012345123456789012345", "アイウエオかきくけこさしすせそたちつてと", "Water flowing down stones."],
                    ["a", "Forrest", "aa", "Sunlight shining through the leafs."],
                    ["a", nil, nil, "Many beautiful places"]
                ],
                alignments:
                [
                    [.left, .left, .left, .right],
                    [.left, .left, .left, .right],
                    [.left, .left, .left, .right],
                    [.left, .left, .left, .right],
                    ])
        } catch PDFError.tableContentInvalid(let value) {
            // In case invalid input is provided, this error will be thrown.
            
            print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
        } catch {
            // General error handling in case something goes wrong.
            
            print("Error while creating table: " + error.localizedDescription)
        }
        document.addTable(table: table)
        
        
        do {
            try table.generateCells(
                data:
                [
                    ["No", "Name", "Image", "Description"],
                    ["1000", "123456789012345123456789012345", "アイウエオかきくけこさしすせそたちつてと", "Water flowing down stones."],
                    ["a", "Forrest", "aa", "Sunlight shining through the leafs."],
                    ["a", nil, nil, "Many beautiful places"]
                ],
                alignments:
                [
                    [.left, .left, .left, .right],
                    [.left, .left, .left, .right],
                    [.left, .left, .left, .right],
                    [.left, .left, .left, .right],
                    ])
        } catch PDFError.tableContentInvalid(let value) {
            // In case invalid input is provided, this error will be thrown.
            
            print("This type of object is not supported as table content: " + String(describing: (type(of: value))))
        } catch {
            // General error handling in case something goes wrong.
            
            print("Error while creating table: " + error.localizedDescription)
        }

        // The widths of each column is proportional to the total width, set by a value between 0.0 and 1.0, representing percentage.
        
        table.widths = [
            0.1, 0.25, 0.35, 0.3
        ]
        let style = PDFTableStyleDefaults.simple
        let lineStyle = PDFLineStyle(type: .full, color: UIColor.black, width: 1)
        let borders = PDFTableCellBorders(left: lineStyle, top: lineStyle, right: lineStyle, bottom: lineStyle)
        
        style.rowHeaderStyle = PDFTableCellStyle(
            colors: (
                fill: UIColor.white,
                text: UIColor.black
            ),
            borders: borders,
            font: UIFont.systemFont(ofSize: 15))
        
        style.columnHeaderStyle = PDFTableCellStyle(
            colors: (
            fill: UIColor.white,
            text: UIColor.black
            ),
            borders: borders,
            font: UIFont.systemFont(ofSize: 15))
        
        style.alternatingContentStyle = PDFTableCellStyle(
            colors: (
                fill: UIColor.white,
                text: UIColor.red
            ),
            borders: borders,
            font: UIFont.systemFont(ofSize: 15))
        
        style.contentStyle = PDFTableCellStyle(
            colors: (
                fill: UIColor.white,
                text: UIColor.red
            ),
            borders: borders,
            font: UIFont.systemFont(ofSize: 15))
        
        // Change standardized styles
        style.footerStyle = PDFTableCellStyle(
            colors: (
                fill: UIColor.white,
                text: UIColor.black
            ),
            borders: borders,
            font: UIFont.systemFont(ofSize: 10)
        )
        
        table.style = style
        
        document.pagination = PDFPagination(container: .footerCenter, style: PDFPaginationStyle.customClosure { (page, total) -> String in
            return "\(page) / \(total)"
            }, range: (1, 20), hiddenPages: [3, 7], textAttributes: [
                .font: UIFont.boldSystemFont(ofSize: 15.0),
                .foregroundColor: UIColor.black
            ])
//        table.padding = 5.0
//        table.margin = 10.0
//        table.showHeadersOnEveryPage = true
        document.addTable(table: table)
        
        do {
            // Generate PDF file and save it in a temporary file. This returns the file URL to the temporary file
            let url = try PDFGenerator.generateURL(document: document, filename: "Example.pdf", progress: {
                (progressValue: CGFloat) in
                print("progress: ", progressValue)
            }, debug: true)
            print(url)
        } catch {
            print("Error while generating PDF: " + error.localizedDescription)
        }
    }
}

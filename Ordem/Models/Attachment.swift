//
//  Attachment.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/6/26.
//
import SwiftData
import Foundation


 // MARK: - Attachment

   @Model
   final class Attachment: Identifiable {
       @Attribute(.unique) var id: UUID
       var filename: String
       var mimeType: String
       @Attribute(.externalStorage) var data: Data
       var createdAt: Date

       @Relationship var note: Note?

       init(filename: String, mimeType: String, data: Data) {
           self.id = UUID()
           self.filename = filename
           self.mimeType = mimeType
           self.data = data
           self.createdAt = .now
       }

       var isImage: Bool { mimeType.hasPrefix("image/") }
       var isPDF: Bool  { mimeType == "application/pdf" }
   }

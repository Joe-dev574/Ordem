//
//  WorkspaceSurfaceRole.swift
//  Ordem
//
//  Created by Joseph DeWeese on 5/14/26.
//

import Foundation
import SwiftUI

enum WorkspaceSurfaceRole: String, CaseIterable, Identifiable {
    case canvas, sidebar, list, detail, chrome, elevated, card, row

    var id: String { rawValue }

    var title: String {
        switch self {
        case .canvas:   "Canvas"
        case .sidebar:  "Sidebar"
        case .list:     "List"
        case .detail:   "Detail"
        case .chrome:   "Chrome"
        case .elevated: "Elevated"
        case .card:     "Card"
        case .row:      "Row"
        }
    }
}

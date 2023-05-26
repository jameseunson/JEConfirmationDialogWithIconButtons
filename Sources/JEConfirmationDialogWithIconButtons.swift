/*

 JEConfirmationDialogWithIconButtons.swift
 JEConfirmationDialogWithIconButtons

 Created by James Eunson (github.com/jameseunson) on 22 May 2023.
 Copyright © 2023 James Eunson. All rights reserved.

 MIT License

 Copyright (c) 2023 James Eunson

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import Foundation
import SwiftUI

public extension View {
    func confirmationDialogWithIconButtons<A>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where A: View {

        confirmationDialogWithIconButtons(Text(titleKey), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions)
    }

    func confirmationDialogWithIconButtons<S, A>(_ title: S, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where S: StringProtocol, A: View {

        confirmationDialogWithIconButtons(Text(title), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions)
    }

    func confirmationDialogWithIconButtons<A>(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where A: View {

        createDialogWithIconButtons(isPresented, actions, title, titleVisibility)
    }

    func confirmationDialogWithIconButtons<A, M>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) -> some View where A: View, M: View {

        confirmationDialogWithIconButtons(Text(titleKey), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions, message: message)
    }

    func confirmationDialogWithIconButtons<S, A, M>(_ title: S, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) -> some View where S: StringProtocol, A: View, M: View {

        confirmationDialogWithIconButtons(Text(title), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions, message: message)
    }

    func confirmationDialogWithIconButtons<A, M>(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) -> some View where A: View, M: View {

        createDialogWithIconButtons(isPresented, actions, message, title, titleVisibility)
    }

    fileprivate func createDialogWithIconButtons<Content: View, Message: View>(_ isPresented: Binding<Bool>, _ actions: @escaping () -> Content, _ message: @escaping () -> Message?, _ title: Text, _ titleVisibility: Visibility) -> some View {
        return ZStack {
            DialogWithIconButtonsBackgroundOverlayView(isPresented: isPresented)
            self
                .modifier(DialogWithIconButtonsDesaturateContrastModifier(isPresented: isPresented))
                .fullScreenCover(isPresented: isPresented, content: {
                    DialogWithIconButtonsView(content: actions,
                                       message: message,
                                       title: title,
                                       titleVisibility: titleVisibility)
                })
        }
    }

    fileprivate func createDialogWithIconButtons<Content: View>(_ isPresented: Binding<Bool>, _ actions: @escaping () -> Content, _ title: Text, _ titleVisibility: Visibility) -> some View {
        return ZStack {
            DialogWithIconButtonsBackgroundOverlayView(isPresented: isPresented)
            self
                .modifier(DialogWithIconButtonsDesaturateContrastModifier(isPresented: isPresented))
                .fullScreenCover(isPresented: isPresented, content: {
                    DialogWithIconButtonsView(content: actions,
                                       title: title,
                                       titleVisibility: titleVisibility)
                })
        }
    }
}

struct DialogWithIconButtonsBackgroundOverlayView: View {
    let isPresented: Binding<Bool>

    var body: some View {
        if isPresented.wrappedValue {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
        } else {
            EmptyView()
        }
    }
}

struct DialogWithIconButtonsDesaturateContrastModifier: ViewModifier {
    let isPresented: Binding<Bool>

    func body(content: Content) -> some View {
        content
            .saturation(isPresented.wrappedValue ? 0 : 1)
            .contrast(isPresented.wrappedValue ? 0.7 : 1)
    }
}

struct DialogWithIconButtonsView<Content: View, Message: View>: View {
    let content: Content
    let title: Text
    let titleVisibility: Visibility
    let message: () -> Message

    init(@ViewBuilder content: () -> Content, @ViewBuilder message: @escaping () -> Message, title: Text, titleVisibility: Visibility) {
        self.content = content()
        self.title = title
        self.titleVisibility = titleVisibility
        self.message = message
    }

    init(@ViewBuilder content: () -> Content, title: Text, titleVisibility: Visibility) where Message == EmptyView {
        self.content = content()
        self.title = title
        self.titleVisibility = titleVisibility
        self.message = { EmptyView() }
    }

    var body: some View {
        _VariadicView.Tree(DialogWithIconButtonsLayout(title: title,
                                                titleVisibility: titleVisibility,
                                                message: message)) {
            content
                .buttonStyle(DialogWithIconButtonsButtonStyle())
                .labelStyle(DialogWithIconButtonsLabelStyle())
        }
    }
}

struct DialogWithIconButtonsLayout<Content: View>: _VariadicView_MultiViewRoot {
    let title: Text
    let titleVisibility: Visibility
    let message: Content
    var hasMessage: Bool {
        Content.self != EmptyView.self
    }

    init(title: Text, titleVisibility: Visibility, @ViewBuilder message: () -> Content) {
        self.title = title
        self.titleVisibility = titleVisibility
        self.message = message()
    }

    @Environment(\.dismiss) var dismiss

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let options = children.filter { $0[DialogWithIconButtonsButtonRoleTrait.self] == .noRole }
        let cancel = children.filter { $0[DialogWithIconButtonsButtonRoleTrait.self] == .hasRole(.cancel) }

        VStack(spacing: 0) {
            Spacer()
            VStack {
                if titleVisibility == .visible {
                    title
                        .fontWeight(hasMessage ? .semibold : .regular)
                        .padding(.top, 14)
                        .padding(.bottom, hasMessage ? 1 : 6)
                    if !hasMessage {
                        Divider()
                            .overlay(Color(uiColor: UIColor.systemGray2))
                    }
                }
                if hasMessage {
                    message
                        .background(Color.clear)
                        .padding(.bottom, 14)
                    Divider()
                        .overlay(Color(uiColor: UIColor.systemGray2))
                }
            }
            .modifier(DialogWithIconButtonsTitleViewModifier())
            .cornerRadius(8, corners: DialogWithIconButtonsButtonType.corners(for: .top))

            ForEach(options) { child in
                child
                    .cornerRadius(8, corners: DialogWithIconButtonsButtonType.corners(for: options.childType(for: child, titleVisible: titleVisibility == .visible)))
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        dismiss()
                    })

                if child.id != options.last?.id {
                    Divider()
                        .overlay(Color(uiColor: UIColor.systemGray2))
                }
            }
            ForEach(cancel) { child in
                child
                    .cornerRadius(8, corners: DialogWithIconButtonsButtonType.corners(for: .cancel))
                    .padding(.top, 10)
            }
        }
        .padding([.leading, .trailing], 10)
        .frame(maxWidth: .infinity)
        .background(DialogWithIconButtonsClearBackgroundView().onTapGesture(perform: {
            dismiss()
        }))
    }
}

struct DialogWithIconButtonsTitleViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13))
            .frame(maxWidth: .infinity)
            .foregroundColor(.secondary)
            .background(.regularMaterial)
    }
}

struct DialogWithIconButtonsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let material: Material = configuration.role == .cancel ? .ultraThickMaterial : .regularMaterial

        VStack {
            configuration.label
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom], 16)
                .foregroundColor(configuration.role == .destructive ? .red : .accentColor)
                .fontWeight(configuration.role == .cancel ? .medium : .regular)
                .background {
                    ZStack {
                        Rectangle()
                            .fill(material)
                        if configuration.isPressed {
                            Color.gray.opacity(0.2)
                        }
                    }
                }
        }
    }
}

struct DialogWithIconButtonsLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
                .frame(width: 10)
            configuration.icon
            configuration.title
            Spacer()
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( DialogWithIconButtonsRoundedCorner(radius: radius, corners: corners) )
    }
}

struct DialogWithIconButtonsRoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct DialogWithIconButtonsClearBackgroundView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return InnerView()
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    private class InnerView: UIView {
        override func didMoveToWindow() {
            super.didMoveToWindow()
            superview?.superview?.backgroundColor = .clear
        }
    }
}

extension View {
    func roleTrait(_ value: DialogWithIconButtonsButtonRoleTrait) -> some View {
        _trait(DialogWithIconButtonsButtonRoleTrait.self, value)
    }
}

struct DialogIconButton<Label>: View where Label: View {
    var action: () -> Void
    var label: () -> Label
    let role: ButtonRole?

    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label, role: ButtonRole? = nil) {
        self.action = action
        self.label = label
        self.role = role
    }

    var body: some View {
        Button(role: role, action: action, label: label)
            .roleTrait(role == .cancel ? .hasRole(.cancel) : .noRole)
    }
}

extension DialogIconButton where Label == Text {
    init(_ titleKey: LocalizedStringKey, action: @escaping () -> Void) {
        self.action = action
        self.label = { Text(titleKey) }
        self.role = nil
    }

    init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
        self.action = action
        self.label = { Text(title) }
        self.role = nil
    }
    init(_ titleKey: LocalizedStringKey, role: ButtonRole?, action: @escaping () -> Void) {
        self.action = action
        self.label = { Text(titleKey) }
        self.role = role
    }

    init<S>(_ title: S, role: ButtonRole?, action: @escaping () -> Void) where S: StringProtocol {
        self.action = action
        self.label = { Text(title) }
        self.role = role
    }
}

enum DialogWithIconButtonsButtonRoleTrait: _ViewTraitKey, Equatable {
    static var defaultValue: DialogWithIconButtonsButtonRoleTrait = .noRole

    case hasRole(DialogWithIconButtonsButtonRole)
    case noRole
}

enum DialogWithIconButtonsButtonRole {
    case cancel
    case destructive
}

enum DialogWithIconButtonsButtonType {
    case top
    case middle
    case bottom
    case cancel

    static func corners(for type: DialogWithIconButtonsButtonType) -> UIRectCorner {
        switch type {
        case .top:
            return [.topLeft, .topRight]
        case .middle:
            return []
        case .bottom:
            return [.bottomLeft, .bottomRight]
        case .cancel:
            return [.allCorners]
        }
    }
}

extension Array where Element == _VariadicView_Children.Element {
    func childType(for child: _VariadicView_Children.Element, titleVisible: Bool) -> DialogWithIconButtonsButtonType {
        var childType: DialogWithIconButtonsButtonType = .middle
        if child.id == self.first?.id {
            if titleVisible {
                childType = .middle
            } else {
                childType = .top
            }
        } else if child.id == self.last?.id {
            childType = .bottom
        }
        return childType
    }
}

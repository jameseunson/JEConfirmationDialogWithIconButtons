//
//  ContentView.swift
//  JEConfirmationDialogWithIcons
//
//  Created by James Eunson on 22/5/2023.
//

import SwiftUI

struct ContentView: View {
    @State var isSystemSheetVisible = false
    @State var isSheetVisible = false
    @State var isLabelSheetVisible = false

    var body: some View {
        VStack {
            Button("Activate system sheet") {
                isSystemSheetVisible = true
            }
            Button("Activate sheet") {
                isSheetVisible = true
            }
            Button("Activate sheet with label buttons") {
                isLabelSheetVisible = true
            }
        }
        .buttonStyle(BorderedButtonStyle())
        .confirmationDialog("Test Sheet 1", isPresented: $isSystemSheetVisible, titleVisibility: .visible) {
            Button("Option 1") {
                print("test")
            }
            Button("Option 2") {
                print("test")
            }
            Button("Option 3", role: .destructive) {
                print("test")
            }
            Button("Cancel", role: .cancel) {
                print("test")
            }
        } message: {
            Text("Hello, this is a message")
        }
        .sheetWithIcons("Test Sheet 2", isPresented: $isSheetVisible, titleVisibility: .visible) {
            JEConfirmationDialogButton("Option 1") {
                print("test")
            }
            JEConfirmationDialogButton("Option 2") {
                print("test")
            }
            JEConfirmationDialogButton("Option 3", role: .destructive) {
                print("test")
            }
            JEConfirmationDialogButton("Cancel", role: .cancel) {
                isSheetVisible = false
            }
        } message: {
            Text("Hello, this is a message")
        }
        .sheetWithIcons("Test Sheet 3", isPresented: $isLabelSheetVisible, titleVisibility: .visible) {
            JEConfirmationDialogButton {
                print("test")
            } label: {
                Label("Option 1", systemImage: "star")
            }
            JEConfirmationDialogButton {
                print("test")
            } label: {
                Label("Option 2", systemImage: "star")
            }
            JEConfirmationDialogButton(action: {
                print("test")
            }, label: {
                Label("Option 3", systemImage: "star")
            },
            role: .destructive)
            JEConfirmationDialogButton("Cancel", role: .cancel) {
                isLabelSheetVisible = false
            }
        } message: {
            Text("Hello, this is a message")
        }
    }
}

extension View {
    public func sheetWithIcons<A>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where A: View {

        sheetWithIcons(Text(titleKey), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions)
    }

    public func sheetWithIcons<S, A>(_ title: S, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where S: StringProtocol, A: View {

        sheetWithIcons(Text(title), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions)
    }

    public func sheetWithIcons<A>(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where A: View {

        createSheetWithIcons(isPresented, actions, title, titleVisibility)
    }

    public func sheetWithIcons<A, M>(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) -> some View where A: View, M: View {

        sheetWithIcons(Text(titleKey), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions, message: message)
    }

    public func sheetWithIcons<S, A, M>(_ title: S, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) -> some View where S: StringProtocol, A: View, M: View {

        sheetWithIcons(Text(title), isPresented: isPresented, titleVisibility: titleVisibility, actions: actions, message: message)
    }

    public func sheetWithIcons<A, M>(_ title: Text, isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) -> some View where A: View, M: View {

        createSheetWithIcons(isPresented, actions, title, titleVisibility)
    }

    fileprivate func createSheetWithIcons<Content: View>(_ isPresented: Binding<Bool>, _ actions: @escaping () -> Content, _ title: Text, _ titleVisibility: Visibility) -> some View {
        return ZStack {
            if isPresented.wrappedValue {
                Color.primary.opacity(0.2)
                    .ignoresSafeArea()
            }
            self
                .saturation(isPresented.wrappedValue ? 0 : 1)
                .contrast(isPresented.wrappedValue ? 0.7 : 1)
                .fullScreenCover(isPresented: isPresented, content: {
                    SheetWithIconsView(content: actions,
                                       title: title,
                                       titleVisibility: titleVisibility)
                })
        }
    }
}

struct SheetWithIconsView<Content: View>: View {
    let content: Content
    let title: Text
    let titleVisibility: Visibility
    let message: () -> Content?

    init(@ViewBuilder content: () -> Content, @ViewBuilder message: @escaping () -> Content? = { nil }, title: Text, titleVisibility: Visibility) {
        self.content = content()
        self.title = title
        self.titleVisibility = titleVisibility
        self.message = message
    }

    var body: some View {
        _VariadicView.Tree(SheetWithIconsLayout(title: title,
                                                titleVisibility: titleVisibility,
                                                message: message)) {
            content
                .buttonStyle(JEConfirmationDialogButtonStyle())
                .labelStyle(JEConfirmationDialogLabelStyle())
        }
    }
}

struct SheetWithIconsLayout<Content: View>: _VariadicView_MultiViewRoot {
    let title: Text
    let titleVisibility: Visibility
    let message: Content

    init(title: Text, titleVisibility: Visibility, @ViewBuilder message: () -> Content) {
        self.title = title
        self.titleVisibility = titleVisibility
        self.message = message()
    }

    @Environment(\.dismiss) var dismiss

    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let options = children.filter { $0[JEConfirmationDialogButtonRoleTrait.self] == .noRole }
        let cancel = children.filter { $0[JEConfirmationDialogButtonRoleTrait.self] == .hasRole(.cancel) }

        VStack(spacing: 0) {
            Spacer()
            if titleVisibility == .visible {
                title
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom], 14)
                    .foregroundColor(.secondary)
                    .background(.regularMaterial)
                    .cornerRadius(8, corners: JEConfirmationDialogButtonType.corners(for: .top))
                Divider()
            }
            ForEach(options) { child in
                child
                    .cornerRadius(8, corners: JEConfirmationDialogButtonType.corners(for: options.childType(for: child, titleVisible: titleVisibility == .visible)))
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        dismiss()
                    })

                if child.id != options.last?.id {
                    Divider()
                }
            }
            ForEach(cancel) { child in
                child
                    .cornerRadius(8, corners: JEConfirmationDialogButtonType.corners(for: .cancel))
                    .padding(.top, 10)
            }
        }
        .padding([.leading, .trailing], 10)
        .frame(maxWidth: .infinity)
        .background(ClearBackgroundView().onTapGesture(perform: {
            dismiss()
        }))
    }
}

struct JEConfirmationDialogButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let material: Material = configuration.role == .cancel ? .ultraThickMaterial : .regularMaterial

        VStack {
            configuration.label
                .font(.title3)
                .frame(maxWidth: .infinity)
                .padding([.top, .bottom], 16)
                .foregroundColor(configuration.role == .destructive ? .red : .accentColor)
                .fontWeight(configuration.role == .cancel ? .medium : .regular)
                .background(material)
                .overlay(content: {
                    if configuration.isPressed {
                        Color.gray.opacity(0.5)
                    }
                })
        }
    }
}

struct JEConfirmationDialogLabelStyle: LabelStyle {
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum ContentListPosition {
    case top
    case middle
    case bottom
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ClearBackgroundView: UIViewRepresentable {
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
    func roleTrait(_ value: JEConfirmationDialogButtonRoleTrait) -> some View {
        _trait(JEConfirmationDialogButtonRoleTrait.self, value)
    }
}

struct JEConfirmationDialogButton<Label>: View where Label: View {
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

extension JEConfirmationDialogButton where Label == Text {
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

enum JEConfirmationDialogButtonRoleTrait: _ViewTraitKey, Equatable {
    static var defaultValue: JEConfirmationDialogButtonRoleTrait = .noRole

    case hasRole(JEConfirmationDialogButtonRole)
    case noRole
}

enum JEConfirmationDialogButtonRole {
    case cancel
    case destructive
}

enum JEConfirmationDialogButtonType {
    case top
    case middle
    case bottom
    case cancel

    static func corners(for type: JEConfirmationDialogButtonType) -> UIRectCorner {
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
    func childType(for child: _VariadicView_Children.Element, titleVisible: Bool) -> JEConfirmationDialogButtonType {
        var childType: JEConfirmationDialogButtonType = .middle
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

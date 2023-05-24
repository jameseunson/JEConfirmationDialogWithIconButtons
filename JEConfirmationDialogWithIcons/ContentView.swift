//
//  ContentView.swift
//  JEConfirmationDialogWithIcons
//
//  Created by James Eunson on 22/5/2023.
//

import SwiftUI

struct ContentView: View {
    @State var isSheetVisible = false
    @State var isLabelSheetVisible = false
    
    var body: some View {
        VStack {
            Button("Activate sheet") {
                isSheetVisible = true
            }
            .buttonStyle(BorderedButtonStyle())
            Button("Activate sheet with label buttons") {
                isLabelSheetVisible = true
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .sheetWithIcons(isPresented: $isSheetVisible) {
            JEConfirmationDialogButton("Option 1") {
                print("test")
            }
            JEConfirmationDialogButton("Option 2") {
                print("test")
            }
            JEConfirmationDialogButton("Option 3") {
                print("test")
            }
            JEConfirmationDialogButton("Cancel", role: .cancel) {
                isSheetVisible = false
            }
        }
        .sheetWithIcons(isPresented: $isLabelSheetVisible) {
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
            JEConfirmationDialogButton {
                print("test")
            } label: {
                Label("Option 3", systemImage: "star")
            }
            JEConfirmationDialogButton("Cancel", role: .cancel) {
                isLabelSheetVisible = false
            }
        }
//        .confirmationDialog("Something", isPresented: .constant(true)) {
//            Button("Test") {
//
//            }
//        }

    }
}

struct SheetWithIconsView<Content: View>: View {
    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        _VariadicView.Tree(SheetWithIconsLayout()) {
            content
                .buttonStyle(JEConfirmationDialogButtonStyle())
                .labelStyle(JEConfirmationDialogLabelStyle())
        }
    }
}

struct SheetWithIconsLayout: _VariadicView_MultiViewRoot {
    @Environment(\.dismiss) var dismiss
    
    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id
        let options = children.filter { $0[JEConfirmationDialogButtonRoleTrait.self] == .noRole }
        let cancel = children.filter { $0[JEConfirmationDialogButtonRoleTrait.self] == .hasRole(.cancel) }

        VStack(spacing: 0) {
            Spacer()
            ForEach(options) { child in
                child
                    .cornerRadius(8, corners: JEConfirmationDialogButtonType.corners(for: options.childType(for: child)))
                    .simultaneousGesture(TapGesture().onEnded { _ in
                        dismiss()
                    })

                if child.id != last {
                    Divider()
                }
            }
            ForEach(cancel) { child in
                child
                    .cornerRadius(8, corners: JEConfirmationDialogButtonType.corners(for: .cancel))
                    .padding(.top, 10)
            }
        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity)
        .background(ClearBackgroundView().onTapGesture(perform: {
            dismiss()
        }))
    }
    
    @ViewBuilder
    func makeButton(title: String, action: @escaping () -> () = {}, position: ContentListPosition) -> some View {
        Button(action: action) {
            Label(title, systemImage: "square.and.arrow.up")
                .labelStyle(JEConfirmationDialogLabelStyle())
        }
        .buttonStyle(JEConfirmationDialogButtonStyle())
    }
}

extension View {
    public func sheetWithIcons<A>(isPresented: Binding<Bool>, titleVisibility: Visibility = .automatic, @ViewBuilder actions: @escaping () -> A) -> some View where A : View {
        ZStack {
            if isPresented.wrappedValue {
                Color.primary.opacity(0.2)
                    .ignoresSafeArea()
            }
            self
                .fullScreenCover(isPresented: isPresented, content: {
                    SheetWithIconsView(content: actions)
                })
        }
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
                .foregroundColor(.accentColor)
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
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
    
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

    init<S>(_ title: S, action: @escaping () -> Void) where S : StringProtocol {
        self.action = action
        self.label = { Text(title) }
        self.role = nil
    }
    init(_ titleKey: LocalizedStringKey, role: ButtonRole?, action: @escaping () -> Void) {
        self.action = action
        self.label = { Text(titleKey) }
        self.role = role
    }

    init<S>(_ title: S, role: ButtonRole?, action: @escaping () -> Void) where S : StringProtocol {
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
    func childType(for child: _VariadicView_Children.Element) -> JEConfirmationDialogButtonType {
        var childType: JEConfirmationDialogButtonType = .middle
        if child.id == self.first?.id {
            childType = .top
        } else if child.id == self.last?.id {
            childType = .bottom
        }
        return childType
    }
}

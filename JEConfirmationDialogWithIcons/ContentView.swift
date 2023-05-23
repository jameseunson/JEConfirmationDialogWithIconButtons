//
//  ContentView.swift
//  JEConfirmationDialogWithIcons
//
//  Created by James Eunson on 22/5/2023.
//

import SwiftUI

struct ContentView: View {
    @State var isSheetVisible = false
    
    var body: some View {
        VStack {
            Button("Activate sheet") {
                isSheetVisible = true
            }
            .buttonStyle(BorderedButtonStyle())
        }
        .sheetWithIcons(isPresented: $isSheetVisible) {
            Button("Option 1") {
                print("test")
            }
            Button("Option 2") {
                print("test")
            }
            Button("Option 3") {
                print("test")
            }
            Button("Cancel", role: .cancel) {
                isSheetVisible = false
            }
        }
//        .modifier(JEConfirmationDialogViewModifier(isPresented: $isSheetVisible))
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

        VStack(spacing: 0) {
            Spacer()
            ForEach(children) { child in
                if child.id == children.first?.id {
                    child
                        .cornerRadius(8, corners: [.topLeft, .topRight])
                } else if child.id == children.last?.id {
                    child
                        .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                } else {
                    child
                }

                if child.id != last {
                    Divider()
                }
            }
        }
        .padding([.leading, .trailing])
        .frame(maxWidth: .infinity)
        .background(ClearBackgroundView())
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
    func sheetWithIcons<Content>(isPresented: Binding<Bool>, transition: AnyTransition = .opacity, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        
        ZStack {
            if isPresented.wrappedValue {
                Color.primary.opacity(0.2)
                    .ignoresSafeArea()
//                    .onTapGesture {
//                        isPresented = false
//                    }
            }
            self
                .fullScreenCover(isPresented: isPresented, content: {
                    SheetWithIconsView(content: content)
                })
        }
    }
}

struct JEConfirmationDialogButtonStyle: ButtonStyle {
//    let position: ContentListPosition
    let corners: UIRectCorner = .allCorners
    
//    init(position: ContentListPosition) {
//        self.position = position
//        switch position {
//        case .top:
//            corners = [.topLeft, .topRight]
//        case .middle:
//            corners = []
//        case .bottom:
//            corners = [.bottomLeft, .bottomRight]
//        case .action:
//            corners = [.allCorners]
//        }
//    }
    
    func makeBody(configuration: Configuration) -> some View {
        let material: Material = configuration.role == .cancel ? .ultraThickMaterial : .regularMaterial
        
        VStack {
            if configuration.role == .cancel {
                Spacer().frame(height: 10)
            }
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

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
        .modifier(JEConfirmationDialogViewModifier(isPresented: $isSheetVisible))
//        .confirmationDialog("Something", isPresented: .constant(true)) {
//            Button("Test") {
//
//            }
//        }

    }
}

struct JEConfirmationDialogViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented, content: {
                VStack(spacing: 0) {
                    Spacer()
                    Section {
                        makeButton(title: "Option 1", position: .top)
                        Divider()
                        makeButton(title: "Option 2", position: .middle)
                        Divider()
                        makeButton(title: "Option 3", position: .bottom)
                    }
                    Spacer().frame(height: 8)
                    Section {
                        makeButton(title: "Cancel", action: {
                            isPresented = false
                            
                        }, position: .action)
                    }
                }
                .padding([.leading, .trailing])
                .frame(maxWidth: .infinity)
                .background(ClearBackgroundView())
            })
    }
    
    @ViewBuilder
    func makeButton(title: String, action: @escaping () -> () = {}, position: ContentListPosition) -> some View {
        Button(action: action) {
            if position == .action {
                Text(title)
            } else {
                Label(title, systemImage: "square.and.arrow.up")
                    .labelStyle(JEConfirmationDialogLabelStyle())
            }
        }
        .buttonStyle(JEConfirmationDialogButtonStyle(position: position))
    }
}

struct JEConfirmationDialogButtonStyle: ButtonStyle {
    let position: ContentListPosition
    let corners: UIRectCorner
    let material: Material
    
    init(position: ContentListPosition) {
        self.position = position
        switch position {
        case .top:
            corners = [.topLeft, .topRight]
        case .middle:
            corners = []
        case .bottom:
            corners = [.bottomLeft, .bottomRight]
        case .action:
            corners = [.allCorners]
        }
        
        switch position {
        case .action:
            material = .ultraThickMaterial
        default:
            material = .regularMaterial
        }
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .frame(maxWidth: .infinity)
            .padding([.top, .bottom], 16)
            .foregroundColor(.accentColor)
            .fontWeight(position == .action ? .medium : .regular)
            .background(material)
            .overlay(content: {
                if configuration.isPressed {
                    Color.gray.opacity(0.5)
                }
            })
            .cornerRadius(8, corners: corners)
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
    case action
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

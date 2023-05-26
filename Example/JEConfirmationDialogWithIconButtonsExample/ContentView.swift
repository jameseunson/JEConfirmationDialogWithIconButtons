//
//  ContentView.swift
//  JEConfirmationDialogWithIcons
//
//  Created by James Eunson on 22/5/2023.
//

import SwiftUI

struct ContentView: View {
    @State var isSystemSheetVisible = false
    @State var isSystemTitleMessageSheetVisible = false
    @State var isSheetVisible = false
    @State var isLabelSheetVisible = false
    @State var isTitleSheetVisible = false
    @State var isMessageSheetVisible = false
    @State var isTitleMessageSheetVisible = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Section {
                    Button {
                        isSystemSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "System confirmation dialog")
                    }
                    Button {
                        isSystemTitleMessageSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "System confirmation dialog with title and message")
                    }
                } header: {
                    Text("System Confirmation Dialog")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Divider()
                    
                } footer: {
                    Spacer().frame(height: 40)
                }
                Section {
                    Button {
                        isSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "Custom sheet with standard buttons")
                    }
                    Button {
                        isLabelSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "Custom sheet with icon buttons")
                    }
                } header: {
                    Text("Dialog with Icons - Basic")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Divider()
                    
                } footer: {
                    Spacer().frame(height: 40)
                }
                
                Section {
                    Button {
                        isTitleSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "Custom sheet with title")
                    }
                    Button {
                        isMessageSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "Custom sheet with message")
                    }
                    Button {
                        isTitleMessageSheetVisible = true
                    } label: {
                        DialogOptionLabelView(name: "Custom sheet with title and message")
                    }
                } header: {
                    Text("Dialog with Icons - Advanced")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                    Divider()
                } footer: {
                    Spacer().frame(height: 40)
                }
                
                Spacer()
                
                VStack(alignment: .center) {
                    Text("Created by James Eunson")
                    Text("http://github.com/jameseunson")
                }
                .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 20)
            .navigationTitle("Dialog with Icons")
        }
        .buttonStyle(BorderedButtonStyle())
        .confirmationDialog("Test Sheet", isPresented: isAnySystemSheetVisible(), titleVisibility: isSystemTitleMessageSheetVisible ? .visible : .hidden) {
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
            if isSystemTitleMessageSheetVisible {
                Text("Message")
            }
        }
        .confirmationDialogWithIconButtons("Test Sheet", isPresented: isAnyCustomSheetVisible(), titleVisibility: isTitleSheetVisible || isTitleMessageSheetVisible ? .visible : .hidden) {
            
            if isSheetVisible {
                DialogIconButton("Option 1") {
                    print("test")
                }
                DialogIconButton("Option 2") {
                    print("test")
                }
                DialogIconButton("Option 3", role: .destructive) {
                    print("test")
                }
            } else {
                DialogIconButton {
                    print("test")
                } label: {
                    Label("Option 1", systemImage: "star")
                }
                DialogIconButton {
                    print("test")
                } label: {
                    Label("Option 2", systemImage: "square.and.arrow.up")
                }
                DialogIconButton(action: {
                    print("test")
                }, label: {
                    Label("Option 3", systemImage: "xmark.bin")
                },
                role: .destructive)
            }
            DialogIconButton("Cancel", role: .cancel) {
                isTitleSheetVisible = false
            }
        } message: {
            if isTitleMessageSheetVisible || isMessageSheetVisible {
                Text("Message")
            }
        }
    }
    
    func isAnySystemSheetVisible() -> Binding<Bool> {
        return Binding {
            return isSystemSheetVisible || isSystemTitleMessageSheetVisible
        } set: { _ in
            isSystemSheetVisible = false
            isSystemTitleMessageSheetVisible = false
        }
    }
    
    func isAnyCustomSheetVisible() -> Binding<Bool> {
        return Binding {
            return isSheetVisible || isLabelSheetVisible || isTitleSheetVisible || isMessageSheetVisible || isTitleMessageSheetVisible
        } set: { _ in
            isSheetVisible = false
            isLabelSheetVisible = false
            isTitleSheetVisible = false
            isMessageSheetVisible = false
            isTitleMessageSheetVisible = false
        }
    }
}

struct DialogOptionLabelView: View {
    let name: String
    
    var body: some View {
        HStack {
            Text(name)
                .multilineTextAlignment(.leading)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        ContentView(isSheetVisible: true)
    }
}

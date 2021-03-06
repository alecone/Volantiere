//
//  TextFieldAlert.swift
//  Volantiere
//
//  Created by Alexandru Cone on 05/03/21.
//

import Foundation
import SwiftUI
import Combine

class TextFieldAlertViewController: UIViewController {
    
    /// Presents a UIAlertController (alert style) with a UITextField and a `Done` button
    /// - Parameters:
    ///   - title: to be used as title of the UIAlertController
    ///   - message: to be used as optional message of the UIAlertController
    ///   - text: binding for the text typed into the UITextField
    ///   - isPresented: binding to be set to false when the alert is dismissed (`Done` button tapped)
    ///   - customFunc: function to be called when button is pressed
    init(title: String, message: String?, text: Binding<String?>, isPresented: Binding<Bool>?, customFunc:@escaping () -> Void) {
        self.alertTitle = title
        self.message = message
        self._text = text
        self.isPresented = isPresented
        self.caller = customFunc
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Dependencies
    private let alertTitle: String
    private let message: String?
    @Binding private var text: String?
    private var isPresented: Binding<Bool>?
    private let caller: () -> Void
    
    // MARK: - Private Properties
    private var subscription: AnyCancellable?
    
    // MARK: - Lifecycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentAlertController()
    }
    
    private func presentAlertController() {
        guard subscription == nil else { return } // present only once
        
        let vc = UIAlertController(title: alertTitle, message: message, preferredStyle: .alert)
        
        // add a textField and create a subscription to update the `text` binding
        vc.addTextField { [weak self] textField in
            guard let self = self else { return }
            self.subscription = NotificationCenter.default
                .publisher(for: UITextField.textDidChangeNotification, object: textField)
                .map { ($0.object as? UITextField)?.text }
                .assign(to: \.text, on: self)
        }
        
        // create a `Done` action that updates the `isPresented` binding when tapped
        // this is just for Demo only but we should really inject
        // an array of buttons (with their title, style and tap handler)
        let action = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.isPresented?.wrappedValue = false
            self?.caller()
        }
        vc.addAction(action)
        present(vc, animated: true, completion: nil)
    }
}

struct TextFieldAlert {
    
    // MARK: Properties
    let title: String
    let message: String?
    @Binding var text: String?
    var isPresented: Binding<Bool>? = nil
    let caller: () -> Void
    
    // MARK: Modifiers
    func dismissable(_ isPresented: Binding<Bool>) -> TextFieldAlert {
        TextFieldAlert(title: title, message: message, text: $text, isPresented: isPresented, caller: caller)
    }
}

extension TextFieldAlert: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = TextFieldAlertViewController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<TextFieldAlert>) -> UIViewControllerType {
        TextFieldAlertViewController(title: title, message: message, text: $text, isPresented: isPresented, customFunc: caller)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType,
                                context: UIViewControllerRepresentableContext<TextFieldAlert>) {
        // no update needed
    }
}

struct TextFieldWrapper<PresentingView: View>: View {
    
    @Binding var isPresented: Bool
    let presentingView: PresentingView
    let content: () -> TextFieldAlert
    
    var body: some View {
        ZStack {
            if (isPresented) { content().dismissable($isPresented) }
            presentingView
        }
    }
}

extension View {
    func textFieldAlert(isPresented: Binding<Bool>,
                        content: @escaping () -> TextFieldAlert) -> some View {
        TextFieldWrapper(isPresented: isPresented,
                         presentingView: self,
                         content: content)
    }
}

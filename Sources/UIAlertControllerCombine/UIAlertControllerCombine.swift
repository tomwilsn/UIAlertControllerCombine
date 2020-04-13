import UIKit
import Combine

/**
    Represents a UIAlertAction that will output an event of type `T` when it's button is tapped or clicked.
 */
public struct UIAlertControllerCombineAction<T> {
    /**
    Initialise a new UIAlertControllerCombineAction
        
    - Parameters:
       - title: The button title
       - style: The `UIAlertAction.Style` to use for the button
       - event: The item to be emitted from the publisher if the button is tapped or clicked
     */
    public init(title: String?, style: UIAlertAction.Style, event: T) {
        self.title = title
        self.style = style
        self.event = event
    }
    
    public let title: String?
    public let style: UIAlertAction.Style
    public let event: T
}


/**
 Extension to present UIAlertControllers and receive the output as a `Future`
 */
public extension UIAlertController {
    /**
    Show a UIAlertController with the result returned as type `T`
     
    Example:
     
    ```
    enum ConfimationEnum: CaseIterable {
        case Cancel, Confirm
    }

    UIAlertController(title: "Something Alarming",
                      message: "Are you sure you want to do this?",
                      preferredStyle: .alert)
        .show(presenter: self, actions: [
            UIAlertControllerCombineAction(title: "Cancel", style: .cancel, event: ConfirmationEnum.Cancel),
            UIAlertControllerCombineAction(title: "Delete", style: .destructive, event: ConfirmationEnum.Confirm),
            ]
    ).sink { [weak self] result in
        switch result {
        case .Cancel:
            break
        case .Confirm:
            self?.doConfirmAction()
       }
    }
    .store(in: &subscriptions)
    ```
     
     
     - Parameters:
        - presenter: The `UIViewController` to present the alert
        - actions: The list of `UIAlertControllerCombineAction<T>` that will be used to create the buttons
     
     -  Returns:
        A future of type `T`
     */
    func show<T>(presenter: UIViewController, actions: [UIAlertControllerCombineAction<T>]) -> AnyPublisher<T, Never> {
        
        return Future<T, Never>() { resolve in
            // Add the actions
            actions.forEach { action in
                self.addAction(UIAlertAction(title: action.title, style: action.style) { _ in
                    resolve(.success(action.event))
                })
            }
            // Present
            presenter.present(self, animated: true)
        }.handleEvents(receiveCancel: {
            // If we are cancelled, dismiss the alert
            presenter.dismiss(animated: true)
        }).eraseToAnyPublisher()
    }
}


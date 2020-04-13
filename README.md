# UIAlertControllerCombine

An extension for UIAlertController that will output the result as a Future of any type.

## Example

```
enum ConfimationEnum: CaseIterable {
    case Cancel, Confirm
}

var subscriptions = Set<AnyCancellable>()

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

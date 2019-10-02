import Combine

var subscriptions = Set<AnyCancellable>()

let numbers = (1...100).publisher

numbers.dropFirst(50).prefix(20).filter {
    $0 % 2 == 0
}.sink(receiveCompletion: {
    print("completion: \($0)")
}) {
    print($0)
}.store(in: &subscriptions)

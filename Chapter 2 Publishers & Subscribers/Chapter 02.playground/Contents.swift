import UIKit
import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Publisher") {
    let notification = Notification.Name("MyNotification")

    let publisher = NotificationCenter.default.publisher(for: notification)

    let center = NotificationCenter.default

    let observer = center.addObserver(forName: notification, object: nil, queue: nil) { (notification) in
        print("Notification received!")
    }

    center.post(name: notification, object: nil)
    center.removeObserver(observer)
}

example(of: "Subsciber") {
    let myNotification = Notification.Name("myNotification")

    let publisher = NotificationCenter.default.publisher(for: myNotification)

    let center = NotificationCenter.default

    let subscription = publisher.sink { (notification) in
        print("Notification Received from a publisher")
    }

    // 1
    center.post(name: myNotification, object: nil)
    // 2
    subscription.cancel()
}

example(of: "Just") {
    let just = Just("Hello world")
    _ = just.sink(receiveCompletion: {
        print("Received completion", $0)
    }, receiveValue: {
        print("Received value", $0)
    })

    _ = just .sink(
      receiveCompletion: {
        print("Received completion (another)", $0)
      },
      receiveValue: {
        print("Received value (another)", $0)
    })
}

example(of: "assign(to:on)") {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }


    let object = SomeObject()

    let publisher = ["Hello", "world"].publisher

    _ = publisher.assign(to: \.value, on: object)
}

example(of: "Custom subsciber") {
    let publisher = (1...6).publisher
//    let publisher = ["A", "B", "C", "D", "E", "F"].publisher

    final class IntSubscriber: Subscriber {
        typealias Input = Int
        typealias Failure = Never

        func receive(subscription: Subscription) {
            subscription.request(Subscribers.Demand.max(3))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
//            return .unlimited
//            return .none
            return .max(1)
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }
    }

    let subsciber = IntSubscriber()
    publisher.subscribe(subsciber)
}

example(of: "Future") {
    func futureIncrement(integer:Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
        Future<Int, Never> { (promise) in
            print("Original")
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + delay) {
                promise(.success(integer + 1))
            }
        }
    }

//    let future = futureIncrement(integer: 1, afterDelay: 3)
//    future.sink(receiveCompletion: {
//        print($0)
//    }) {
//        print($0)
//    }.store(in: &subscriptions)
//    future.sink(receiveCompletion: {
//        print("Second", $0)
//    }, receiveValue: {
//        print("Second", $0)
//    }) .store(in: &subscriptions)
}

example(of: "Passthrough Subject") {
    enum MyError: Error {
        case test
    }

    final class StringSubscriber: Subscriber {
        func receive(completion: Subscribers.Completion<MyError>) {
            print("Received completion", completion)
        }

        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: String) -> Subscribers.Demand {
            print("Received value", input)
            return input == "World" ? .max(1) : .none
        }

        typealias Input = String

        typealias Failure = MyError
    }

    let subscriber = StringSubscriber()
    let subject = PassthroughSubject<String, MyError>()

    subject.subscribe(subscriber)

    let subscription = subject.sink(
        receiveCompletion: { completion in
          print("Received completion (sink)", completion)
        },
        receiveValue: { value in
          print("Received value (sink)", value)
        }
    )

    subject.send("Hello")
    subject.send("World")

    subscription.cancel()
    subject.send("Still there")
    subject.send(completion: .failure(MyError.test))
    subject.send(completion: .finished)
    subject.send("How about another one?")
}

example(of: "CurrentValueSubject") {
    var subscriptions = Set<AnyCancellable>()
    let subject = CurrentValueSubject<Int, Never>(0)
    subject.print().sink {
        print($0)
    }.store(in: &subscriptions)
    subject.send(1)
    subject.send(2)
    subject.value = 3
    print(subject.value)

    subject.print().sink {
        print("Second subscription:", $0)
    }.store(in: &subscriptions)

    subject.send(completion: .finished)
}

example(of: "Dynamically adjusting Demand") {
    final class IntSubscriber: Subscriber {
        func receive(subscription: Subscription) {
            subscription.request(.max(2))
        }

        func receive(_ input: Int) -> Subscribers.Demand {
            print("Received value", input)
            switch input {
            case 1:
                return .max(2)
            case 3:
                return .max(1)
            default:
                return .none
            }
        }

        func receive(completion: Subscribers.Completion<Never>) {
            print("Received completion", completion)
        }

        typealias Input = Int

        typealias Failure = Never
    }
    let subscriber = IntSubscriber()
    let subject = PassthroughSubject<Int, Never>()
    subject.subscribe(subscriber)
    subject.send(1)
    subject.send(2)
    subject.send(3)
    subject.send(4)
    subject.send(5)
    subject.send(6)
}

example(of: "Type erasure") {
    let subject = PassthroughSubject<Int, Never>()
    let publisher = subject.eraseToAnyPublisher()
    publisher.sink {
        print($0)
    }.store(in: &subscriptions)
    subject.send(0)
}

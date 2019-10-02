import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
example(of: "collect") {
    ["A", "B", "C", "D", "E"].publisher
        .collect(2)
        .sink(receiveCompletion: {
            print($0)
        }) {
            print($0)
    }.store(in: &subscriptions)
}

example(of: "map") {
    let formatter = NumberFormatter()
    formatter.numberStyle = .spellOut
    [123, 4, 56].publisher.map {
        formatter.string(from: NSNumber(integerLiteral: $0)) ?? ""
    }.sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "map key path") {
    let publisher = PassthroughSubject<Coordinate, Never>()

    publisher.map(\.x, \.y).sink(receiveCompletion: {
        print($0)
    }) { (x, y) in
        print("The coordinate at (\(x), \(y)) is in quadrant", quadrantOf(x: x, y: y))
    }.store(in: &subscriptions)

    publisher.send(Coordinate(x: 10, y: -9))
}

example(of: "try map") {
    Just("Directory name that not exists").tryMap {
        try FileManager.default.contentsOfDirectory(atPath: $0)
    }.sink(receiveCompletion: {
        print($0)
    }) {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "flatmap") {
    let charlotte = Chatter(name: "Charlotte", message: "Hi, I'm Charlotte!")
    let james = Chatter(name: "James", message: "Hi, I'm James!")
    let morgan = Chatter(name: "Morgan", message: "Hey guys, what are you up to?")

    let chat = CurrentValueSubject<Chatter, Never>(charlotte)
    chat.flatMap(maxPublishers: .max(2), {
        $0.message
    }).sink {
        print($0)
    }.store(in: &subscriptions)

    charlotte.message.value = "Charlotte: How's it going?"
    chat.value = james

    james.message.value = "James: Doing great. You?"
    charlotte.message.value = "Charlotte: I'm doing fine thanks."

    chat.value = morgan
    charlotte.message.value = "Did you hear something?"
}

example(of: "Replace nil") {
    ["A", nil, "C"].publisher.replaceNil(with: "-").sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "replaceEmpty") {
    let empty = Empty<Int, Never>()
    empty.replaceEmpty(with: 1).sink(receiveCompletion: {
        print($0)
    }) {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "scan") {
    var dailyGainLoss: Int { .random(in: -10...10) }
    let august2019 = (0..<22).map { _ in
        dailyGainLoss
    }.publisher

    august2019.scan(50, { (lastest, current) in
        max(0, lastest + current)
    }).sink { (_) in

    }.store(in: &subscriptions)
}

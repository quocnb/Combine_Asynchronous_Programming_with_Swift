import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "filter") {
    let numbers = (1...10).publisher
    numbers.filter {
        $0.isMultiple(of: 3)
    }.sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "remove duplicates") {
    let words = "hey hey there! want to listen to mister mister ?".components(separatedBy: " ").publisher
    words.removeDuplicates().sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "compactMap") {
    let strings = ["a", "1.24", "3", "def", "45", "0.23"].publisher
    strings.compactMap({Float($0)}).sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "ignore output") {
    let numbers = (1...10_000).publisher
    numbers.ignoreOutput().sink(receiveCompletion: {
        print($0)
    }) {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "first where") {
    let numbers = (1...9).publisher
    numbers.print().first {
        $0 % 2 == 0
    }.sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "last where") {
    let numbers = (1...9).publisher
    numbers.print().last {
        $0 % 2 == 0
    }.sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "drop first") {
    let numbers = (1...9).publisher
    numbers.dropFirst(3).sink {
        print($0)
    }.store(in: &subscriptions)
}

example(of: "limit value") {
    let numbers = (1...9).publisher
    numbers.prefix(2).sink {
        print($0)
    }.store(in: &subscriptions)
}

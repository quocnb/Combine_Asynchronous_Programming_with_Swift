import Combine

var subscriptions = Set<AnyCancellable>()

example(of: "Create a Blackjack card dealer") {
  let dealtHand = PassthroughSubject<Hand, HandError>()

  func deal(_ cardCount: UInt) {
    var deck = cards
    var cardsRemaining = 52
    var hand = Hand()

    for _ in 0 ..< cardCount {
      let randomIndex = Int.random(in: 0 ..< cardsRemaining)
      hand.append(deck[randomIndex])
      deck.remove(at: randomIndex)
      cardsRemaining -= 1
    }
    if hand.points > 21 {
        dealtHand.send(completion: .failure(HandError.busted))
    } else {
        dealtHand.send(hand)
    }
  }

  // Add subscription to dealtHand here
    dealtHand.sink(receiveCompletion: {
        if case let .failure(error) = $0 {
            print(error)
        }
    }) { (cards) in
        print(cards.cardString)
        print(cards.points)
    }

  deal(3)
}

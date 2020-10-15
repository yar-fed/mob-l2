//: ## Лабораторная работа №2. Классы Swift
import Foundation
//: Перечесления могут иметь базовый тип. Каждой константе будет присвоено некоторое значение базового типа.
enum Suit: String {
    case spades, hearts, diamonds, clubs
}
Suit.spades.rawValue

enum Rank: Int {
    case two = 2, three, four, five, six, seven,
    eight, nine, ten, jack, queen, king, ace
}
//: Структуры хранятся и передаются по значению (статически). Используйте структуры для хранения набора значений. Если методы объекта позволяют модифицировать хранимые значения, лучше использовать класс.
struct Card {
    let rank: Rank
    let suit: Suit
    
    // Сравнение карт одной масти по старшенству
    static func <(lhv: Card, rhv: Card) -> Bool {
        return lhv.rank.rawValue < rhv.rank.rawValue && lhv.suit == rhv.suit
    }
}
//: ### Задание №1
//: Любой тип можно расширить новыми методами и вычислимыми полями. Принятие протоколов в Swift традиционно реализуется в расширениях.
//:
//: Реализуйте расширение типа `Card` для принятия протокола `CustomStringConvertible`.
//:
//: Свойство `description` должно выводить описание карты на русском: "туз пик".
extension Card: CustomStringConvertible {
    var description: String {
        return "\(self.rank) \(self.suit)"
    }
}

let card = Card(rank: .ace, suit: .spades)

print(card.description)
//: Протокол позволяет описать образец некоторого типа, задающий его свойства и методы.
/// Протокол для колоды карт
protocol CardDeck {
    /// Инициализатор для заданных наборов мастей и стоимости
    init(with ranks: [Rank], of suits: [Suit])
    
    /// Снять верхнюю карту
    mutating func getCard() -> Card
    
    /// Колода пуста
    var isEmpty: Bool {get}
}
//: Классы и структуры могут принимать протокол, реализуя запрашиваемые в нём свойства и методы.
class Deck: CardDeck {
    // Внутреннее свойство
    private var cards: [Card]
    
    // Принимаем протокол CardDeck
    
    func getCard() -> Card {
        // мы не перемешивали колоду, поэтому верхняя карта берётся случайно
        return cards.remove(at: Int(arc4random()) % cards.count)
    }
    
    var isEmpty: Bool {
        return cards.isEmpty
    }
    
    // Т. к. протокол принимается классом, инициализатор должен быть помечен required
    // Это гарантирует что любой наследник класса будет иметь этот инициализатор
    required init(with ranks: [Rank], of suits: [Suit] = [.spades, .hearts, .diamonds, .clubs]) {
        self.cards = suits.flatMap {
            suit in ranks.flatMap {
                rank in Card(rank: rank, suit: suit)
            }
        }
    }
}
//: Расширения позволяют выносить дополнительную функциональность в отдельный блок кода (или файл).
extension Deck {
    /// Тип колоды: 52, 36, 32 карты
    enum DeckType { case standart52, stripped36, stripped32 }
    
    /// Инициализатор для заданного типа колоды
    convenience init(of type: DeckType) {
        switch type {
        case .standart52:
            self.init(with: [.two, .three, .four, .five, .six, .seven, .eight, .nine, .ten, .jack, .queen, .king, .ace])
        case .stripped36:
            self.init(with: [.six, .seven, .eight, .nine, .ten, .jack, .queen, .king, .ace])
        case .stripped32:
            self.init(with: [.seven, .eight, .nine, .ten, .jack, .queen, .king, .ace])
        }
    }
}

let deck = Deck(of: .standart52)

/// Протокол игрока
protocol CardPlayer {
    /// Имя игрока
    var name: String {get}
    
    /// Инициализатор с заданным именем
    init(withName name: String)
    
    /// Карты в руке
    var hand: [Card] {get}
    
    /// Разыграть карту из руки
    mutating func playCard() -> Card
    
    /// Возвращает карту из руки наименьшей стоимости которая бъёт заданную
    mutating func cover(for card: Card) -> Card?
    
    /// Взять указанную карту в руку
    mutating func take(_ card: Card)
    
    /// Добрать карты в руку из колоды, чтобы стало minNumberOfCards
    mutating func fillHand(from deck: Deck, for minNumberOfCards: Int)
}
//: ### Задание №2
//: Реализуйте класс игрока в карты, принимающий протокол `CardPlayer`.
class Player: CardPlayer {
    var hand: [Card]
    let name: String;
    
    func playCard() -> Card {
        return hand.remove(at: Int(arc4random()) % self.hand.count);
    }
    
    func cover(for card: Card) -> Card? {
        let cards = self.hand.filter { $0.suit == card.suit }

        if cards.count == 0 {
            return nil;
        }
        
        let minCard = cards.min { $1<$0 }
        
        if minCard == nil {
            return nil;
        }
        
        return minCard;
    }
    
    func fillHand(from deck: Deck, for minNumberOfCards: Int) {
        if !deck.isEmpty {
            for _ in 1...minNumberOfCards {
                self.hand.append(deck.getCard())
            }
        }
    }
    
    func take(_ card: Card) {
        self.hand.append(card);
    }

    required init(withName name: String) {
        self.name = name;
        self.hand = [];
    }
 }
//: Наполните массив игроков:
var players = [CardPlayer]()
players = [Player(withName: "First"), Player(withName: "Second"), Player(withName: "Third")]

//: Подобно классам, протоколы можно наследовать, добавляя в них дополнительные требования.
//:
/// Протокол игры
protocol Game {
    /// Уловие завершения игры
    var isFinished: Bool {get}
    /// Начать игру
    mutating func play()
}

/// Протокол карточной игры
protocol CardGame: Game {
    /// Минимальное число карт в руке у игрока
    static var minCardsInHand: Int {get}
    
    /// Колода карт
    var deck: Deck {get}
    
    /// Инициализатор с заданной колодой
    init(with deck: Deck)
    
    /// Игроки
    var players: [CardPlayer] {get}
    
    /// Добавить игрока в игру и выдать ему карты
    mutating func add(player: inout CardPlayer)
}
//: ### Задание №3
//: Реализовать игру в "Дурака" со следующим алгоритмом:
//: ```
//:    Пока количество игроков не равно одному:
//:        Текущий игрок разыгрывает карту
//:        Следующий игрок отбивается
//:
//:        Если следующий игрок не может отбиться, то он берёт разыгранную карту
//:
//:        Если у текущего игрока нет карт, то он выходит из игры
//:        Иначе если его карту не отбили, то добирает до шести карт
//:
//:        Если у следующего игрока нет карт, то он выходит из игры
//:        Иначе добирает до шести карт
//:
//:        Если следующий игрок отбился, то ход переходит к нему
//: ```
//: _Заметьте, что когда игрок выходит из игры, это влияет на индексы игроков в массиве!_
//:
//: В ходе игры необходимо выводить сообщения: "игрок разыграл карту", игрок побил карту, игрок вышел из игры - на консоль, для пояснения хода игры.
// class FoolCardGame: CardGame {}
//: Присвойте `newGame` экземпляр вашей игры. Игра должна начаться автоматически.
var newGame: CardGame?
for var player in players {
    newGame?.add(player: &player)
}
newGame?.play()

if let game = newGame, game.players.count == 1 {
    print(game.players[0].name + " в дураках!")
} else {
    print("Игра завершилась вничью!")
}
//: ### Задание №4 _Дополнительное_
//: Реализовать наследников ваших классов для описания игры с понятием "козырь" (trump suit).
// class PlayerTrump: Player {}
// class FoolTrumpGame: FoolCardGame {}

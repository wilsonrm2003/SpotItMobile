//
//  CardGeneration.swift
//  SpotItMobile
//
//  Created by Rachael Wilson on 3/26/26.
//

struct GenerateCards {
    var generated_cards: [SpotItCard] = []
    
    init() {
        // referenced 101computing.net's "The Dobble Algorithm"
        let icon_per_card = 8
        let n = (icon_per_card-1)
        
        var intList : [[Int]] = []
        
        for i in (0..<n) {
            intList.append([0])
            
            for j in (0..<n) {
                intList[i].append((j + 1) + (i * n))
            }
        }
        
        for i in (0..<n) {
            for j in (0..<n) {
                intList.append([i + 1])
                
                for k in (0..<n) {
                    let compute_step = (n+1 + k * n + (i * k + j) % n)
                    intList[intList.count-1].append(compute_step)
                }
            }
        }
        
        // shuffle icons and turns cards into spot it cards ;)
        var allCards : [SpotItCard] = []
        for card in intList {
            // print(card) // uncomment for testing
            allCards.append(SpotItCard(icons: card.shuffled()))
            
        }
        
        //MARK: check generation
        //(this is completely claudes for testing)
//        var foundBadPair = false
//        for a in 0..<allCards.count {
//            for b in (a+1)..<allCards.count {
//                let shared = Set(allCards[a].icons).intersection(Set(allCards[b].icons))
//                if shared.count != 1 {
//                    print("BAD PAIR: card \(a) and card \(b) share \(shared.count) icons: \(shared)")
//                    foundBadPair = true
//                }
//            }
//        }
//        if !foundBadPair { print("ALL PAIRS VALID") }
        
        generated_cards = allCards
    }
}

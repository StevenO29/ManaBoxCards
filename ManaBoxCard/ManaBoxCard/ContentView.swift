//
//  ContentView.swift
//  ManaBoxCard
//
//  Created by MacBook Pro on 17/11/23.
//

import SwiftUI

struct Card: Codable {
    let object: String
    let total_cards: Int
    let has_more: Bool
    let data: [CardData]
}

struct CardData: Codable {
    let object: String?
    let id: String?
    let oracle_id: String?
    let multiverse_ids: [Int]?
    let mtgo_id: Int?
    let arena_id: Int?
    let tcgplayer_id: Int?
    let cardmarket_id: Int?
    let name: String?
    let lang: String?
    let released_at: String?
    let uri: String?
    let scryfall_uri: String?
    let layout: String?
    let highres_image: Bool?
    let image_status: String?
    let image_uris: ImageURIs?
    let mana_cost: String?
    let cmc: Double?
    let type_line: String?
    let oracle_text: String?
    let colors: [String]?
    let color_identity: [String]?
    let keywords: [String]?
    let legalities: Legalities?
    let games: [String]?
    let reserved: Bool?
    let foil: Bool?
    let nonfoil: Bool?
    let finishes: [String]?
    let oversized: Bool?
    let promo: Bool?
    let reprint: Bool?
    let variation: Bool?
    let set_id: String?
    let set: String?
    let set_name: String?
    let set_type: String?
    let set_uri: String?
    let set_search_uri: String?
    let scryfall_set_uri: String?
    let rulings_uri: String?
    let prints_search_uri: String?
    let collector_number: String?
    let digital: Bool?
    let rarity: String?
    let flavor_text: String?
    let card_back_id: String?
    let artist: String?
    let artist_ids: [String]?
    let illustration_id: String?
    let border_color: String?
    let frame: String?
    let frame_effects: [String]?
    let security_stamp: String?
    let full_art: Bool?
    let textless: Bool?
    let booster: Bool?
    let story_spotlight: Bool?
    let promo_types: [String]?
    let edhrec_rank: Int?
    let penny_rank: Int?
    let prices: Prices?
    let related_uris: RelatedURIs?
    let purchase_uris: PurchaseURIs?
}


struct ImageURIs: Codable {
    let small: String?
    let normal: String?
    let large: String?
    let png: String?
    let art_crop: String?
    let border_crop: String?
}

struct Legalities: Codable {
    let standard: String?
    let future: String?
    let historic: String?
    let gladiator: String?
    let pioneer: String?
    let explorer: String?
    let modern: String?
    let legacy: String?
    let pauper: String?
    let vintage: String?
    let penny: String?
    let commander: String?
    let oathbreaker: String?
    let brawl: String?
    let historicbrawl: String?
    let alchemy: String?
    let paupercommander: String?
    let duel: String?
    let oldschool: String?
    let premodern: String?
    let predh: String?
}

struct Prices: Codable {
    let usd: String?
    let usd_foil: String?
    let usd_etched: String?
    let eur: String?
    let eur_foil: String?
    let tix: String?
}

struct RelatedURIs: Codable {
    let gatherer: String?
    let tcgplayer_infinite_articles: String?
    let tcgplayer_infinite_decks: String?
    let edhrec: String?
}

struct PurchaseURIs: Codable {
    let tcgplayer: String?
    let cardmarket: String?
    let cardhoarder: String?
}

struct ContentView: View {
    @State private var searchText = ""
    @State private var sortByAscending = true
    @State var dataCards: [CardData] = []

    func loadJSONData() {
        if let bundlePath = Bundle.main.path(forResource: "WOT-Scryfall", ofType: "json"),
           let jsonData = try? Data(contentsOf: URL(fileURLWithPath: bundlePath)) {
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(Card.self, from: jsonData)
                dataCards = result.data
            } catch {
                print(error)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(), count: 3), spacing: 8) {
                    ForEach(dataCards.filter {
                        searchText.isEmpty || $0.name?.localizedCaseInsensitiveContains(searchText) == true
                    }.sorted(by: { card1, card2 in
                        if sortByAscending {
                            return (card1.name ?? "") < (card2.name ?? "")
                        } else {
                            return (card1.name ?? "") > (card2.name ?? "")
                        }
                    }), id: \.id) { card in
                        NavigationLink(destination: DetailView(card: card)) {
                            VStack(alignment: .center) {
                                AsyncImage(url: URL(string: card.image_uris?.normal ?? "https://via.placeholder.com/150")!) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                }
                                Text(card.name ?? "")
                                    .font(.headline)
                                    .lineLimit(1)
                                    .padding(.top, 4)
                            }
                        }
                    }
                }
                .padding(8)
            }
            .searchable(text: $searchText) {
                Text("Search")
            }
            .navigationTitle("Manabox Cards")
            .onAppear {
                loadJSONData()
            }
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    sortByAscending.toggle()
                }) {
                    Image(systemName: sortByAscending ? "arrow.up" : "arrow.down")
                        .imageScale(.large)
                }
            })
        }
    }
}

struct DetailView: View {
    @State private var isImageFullScreen = false // Menambahkan state untuk melacak status pop-up
    @State private var offset: CGFloat = 0 // Menambahkan state untuk melacak offset geser

    var card: CardData

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                Button(action: {
                    isImageFullScreen.toggle() // Mengaktifkan pop-up ketika tombol diklik
                }) {
                    AsyncImage(url: URL(string: card.image_uris?.normal ?? "https://via.placeholder.com/150")!) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        ProgressView()
                    }
                }
                .buttonStyle(PlainButtonStyle()) // Menghilangkan tampilan default tombol

                Text(card.name ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .padding(.horizontal, 16)

                Text("Mana Cost: \(card.mana_cost ?? "")")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Text("Type: \(card.type_line ?? "")")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Text("Oracle Text: \(card.oracle_text ?? "")")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                if let colors = card.colors, !colors.isEmpty {
                    Text("Colors: \(colors.joined(separator: ", "))")
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                Text("Rarity: \(card.rarity ?? "")")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                Text("Set: \(card.set_name ?? "")")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            .padding()
            .offset(x: offset) // Menyesuaikan offset untuk swipe

            // Gesture untuk swipe
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offset = value.translation.width
                    }
                    .onEnded { value in
                        withAnimation {
                            // Menentukan batas geser untuk menavigasi
                            if value.translation.width > 100 {
                                // Swipe ke kiri
                                // Implementasikan navigasi ke tampilan sebelumnya di sini jika ada
                            } else if value.translation.width < -100 {
                                // Swipe ke kanan
                                // Implementasikan navigasi ke tampilan selanjutnya di sini jika ada
                            }
                            offset = 0 // Mengembalikan offset ke posisi awal
                        }
                    }
            )
        }
        .navigationTitle(card.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isImageFullScreen) {
            // Tampilan pop-up untuk menampilkan gambar secara penuh layar
            if let imageURL = URL(string: card.image_uris?.large ?? "") {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

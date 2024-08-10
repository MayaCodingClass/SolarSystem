import SwiftUI

struct CelestialBody: Identifiable {
    var id = UUID()
    var name: String
    var color: Color
    var radius: CGFloat
    var orbitRadius: CGFloat
    var orbitSpeed: Double
    var isSun: Bool = false
}

enum AlertType {
    case none, victory, tryAgain
    
    var isPresented: Bool {
        get {
            self != .none
        }
        
        set {
            self = newValue ? self : .none
        }
    }
    
    var title: String {
        switch self {
        case .victory: return "Victory!"
        case .tryAgain: return "Try Again"
        default: return ""
        }
    }
    
    var message: String {
        switch self {
        case .victory: return "You found the missing heart!"
        case .tryAgain: return "You'll do better next time."
        default: return ""
        }
    }
    
    var button: String {
        switch self {
        case .victory: return "Play Again"
        case .tryAgain: return "Try Again"
        default: return ""
        }
    }
}

struct SolarSystemView: View {
    @State private var celestialBodies = [
        CelestialBody(name: "Mercury", color: .gray, radius: 5, orbitRadius: 25, orbitSpeed: 3),
        CelestialBody(name: "Venus", color: .yellow, radius: 8, orbitRadius: 40, orbitSpeed: 7),
        CelestialBody(name: "Earth", color: .blue, radius: 10, orbitRadius: 55, orbitSpeed: 10),
        CelestialBody(name: "Mars", color: .red, radius: 7, orbitRadius: 70, orbitSpeed: 15),
        CelestialBody(name: "Jupiter", color: .orange, radius: 15, orbitRadius: 100, orbitSpeed: 20),
        CelestialBody(name: "Saturn", color: .yellow, radius: 12, orbitRadius: 125, orbitSpeed: 25),
        CelestialBody(name: "Uranus", color: .blue, radius: 10, orbitRadius: 150, orbitSpeed: 30),
        CelestialBody(name: "Neptune", color: .blue, radius: 10, orbitRadius: 175, orbitSpeed: 35),
        CelestialBody(name: "Sun", color: .yellow, radius: 25, orbitRadius: 0, orbitSpeed: 0, isSun: true)
    ]
    
    @State private var specialBodyID: UUID?
    @State private var alertType: AlertType = .none
    @State private var remainingGuesses = 5

    var body: some View {
        ZStack {
            ForEach(celestialBodies) { body in
                CelestialBodyView(celestialBody: body, isSpecial: body.id == specialBodyID) { foundSpecial in
                    if foundSpecial {
                        alertType = .victory
                    } else {
                        remainingGuesses -= 1
                        celestialBodies.removeAll { $0.id == body.id }

                        if remainingGuesses == 0 {
                            alertType = .tryAgain
                        }
                    }
                }
            }
        }
        .frame(width: 800, height: 800)
        .background(Color.black)
        .onAppear(perform: selectSpecialBody)
        .alert(isPresented: $alertType.isPresented) {
            Alert(
                title: Text(alertType.title),
                message: Text(alertType.message),
                dismissButton: .default(Text(alertType.button)) {
                    resetGame()
                }
            )
        }
    }
    
    private func selectSpecialBody() {
        specialBodyID = celestialBodies.randomElement()?.id
    }
    
    private func resetGame() {
        celestialBodies = [
            CelestialBody(name: "Mercury", color: .gray, radius: 5, orbitRadius: 25, orbitSpeed: 3),
            CelestialBody(name: "Venus", color: .yellow, radius: 8, orbitRadius: 40, orbitSpeed: 7),
            CelestialBody(name: "Earth", color: .blue, radius: 10, orbitRadius: 55, orbitSpeed: 10),
            CelestialBody(name: "Mars", color: .red, radius: 7, orbitRadius: 70, orbitSpeed: 15),
            CelestialBody(name: "Jupiter", color: .orange, radius: 15, orbitRadius: 100, orbitSpeed: 20),
            CelestialBody(name: "Saturn", color: .yellow, radius: 12, orbitRadius: 125, orbitSpeed: 25),
            CelestialBody(name: "Uranus", color: .blue, radius: 10, orbitRadius: 150, orbitSpeed: 30),
            CelestialBody(name: "Neptune", color: .blue, radius: 10, orbitRadius: 175, orbitSpeed: 35),
            CelestialBody(name: "Sun", color: .yellow, radius: 25, orbitRadius: 0, orbitSpeed: 0, isSun: true)
        ]
        remainingGuesses = 5
        selectSpecialBody()
    }
}

struct CelestialBodyView: View {
    let celestialBody: CelestialBody
    let isSpecial: Bool
    var onTap: (Bool) -> Void
    @State private var angle: Double = 0
    @State private var isTapped = false
    private let timer = Timer.publish(every: 0.001, on: .main, in: .common).autoconnect()

    var body: some View {
        let x = cos(angle) * celestialBody.orbitRadius
        let y = sin(angle) * celestialBody.orbitRadius
        
        return ZStack {
            if isTapped && isSpecial {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(celestialBody.color)
                    .frame(width: celestialBody.radius * 2, height: celestialBody.radius * 2)
                    .offset(x: x, y: y)
                    .onReceive(timer) { _ in
                        if !celestialBody.isSun {
                            withAnimation(.linear(duration: 0.01)) {
                                angle += 0.01 / celestialBody.orbitSpeed
                                if angle >= 2 * .pi {
                                    angle = 0
                                }
                            }
                        }
                    }
            } else if !isTapped {
                Circle()
                    .fill(celestialBody.color)
                    .frame(width: celestialBody.radius * 2, height: celestialBody.radius * 2)
                    .offset(x: x, y: y)
                    .onReceive(timer) { _ in
                        if !celestialBody.isSun {
                            withAnimation(.linear(duration: 0.01)) {
                                angle += 0.01 / celestialBody.orbitSpeed
                                if angle >= 2 * .pi {
                                    angle = 0
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        onTap(isSpecial)  // Trigger the action first
                        isTapped = true    // Then set the tapped state
                    }
            }
        }
        .position(x: celestialBody.isSun ? 400 : 400 + x, y: celestialBody.isSun ? 400 : 400 + y)
    }
}

struct ContentView: View {
    var body: some View {
        SolarSystemView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

import SwiftUI

struct CelestialBody: Identifiable {
    var id = UUID()
    var name: String
    var color: Color
    var radius: CGFloat
    var orbitRadius: CGFloat
    var orbitSpeed: Double
    var isSun: Bool = false
    var position: CGPoint? = nil  // Position for stationary stars
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
    static let NumberOfGuesses = 10
    @State private var celestialBodies: [CelestialBody] = []
    @State private var specialBodyID: UUID?
    @State private var alertType: AlertType = .none
    @State private var remainingGuesses = SolarSystemView.NumberOfGuesses

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
        .onAppear(perform: initializeGame)
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
    
    private func initializeGame() {
        // Reset celestial bodies
        celestialBodies = [
            CelestialBody(name: "Mercury", color: .gray, radius: 5, orbitRadius: 25, orbitSpeed: 3),
            CelestialBody(name: "Venus", color: .venusYellow, radius: 8, orbitRadius: 40, orbitSpeed: 7),
            CelestialBody(name: "Earth", color: .blue, radius: 10, orbitRadius: 55, orbitSpeed: 10),
            CelestialBody(name: "Mars", color: .red, radius: 7, orbitRadius: 70, orbitSpeed: 15),
            CelestialBody(name: "Jupiter", color: .jupiterOrange, radius: 15, orbitRadius: 100, orbitSpeed: 20),
            CelestialBody(name: "Saturn", color: .gold, radius: 12, orbitRadius: 125, orbitSpeed: 25),
            CelestialBody(name: "Uranus", color: .lightBlueGreen, radius: 10, orbitRadius: 150, orbitSpeed: 30),
            CelestialBody(name: "Neptune", color: .neptuneBlue, radius: 10, orbitRadius: 175, orbitSpeed: 35),
            CelestialBody(name: "Sun", color: .sunYellow, radius: 25, orbitRadius: 0, orbitSpeed: 0, isSun: true)
        ]
        
        // Add stationary stars
        let starColors: [Color] = [.white, .gray, .blue, .yellow]
        for i in 0..<10 {
            celestialBodies.append(
                CelestialBody(
                    name: "Star \(i + 1)",
                    color: starColors.randomElement() ?? .white,
                    radius: 4,
                    orbitRadius: 0,
                    orbitSpeed: 0,
                    isSun: false,
                    position: CGPoint(x: CGFloat.random(in: 50...750), y: CGFloat.random(in: 50...750))
                )
            )
        }
        
        // Select the special body
        selectSpecialBody()
    }
    
    private func selectSpecialBody() {
        specialBodyID = celestialBodies.randomElement()?.id
    }
    
    private func resetGame() {
        remainingGuesses = SolarSystemView.NumberOfGuesses
        initializeGame()
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
            if isTapped && isSpecial || !isTapped {
                if celestialBody.position != nil {
                    // Stationary star
                    Image(systemName: !isTapped ? "star.fill" : "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(celestialBody.color)
                        .frame(width: celestialBody.radius * 2, height: celestialBody.radius * 2)
                        .position(celestialBody.position ?? CGPoint(x: 400 + x, y: 400 + y))
                } else {
                    // Orbiting circle
                    Image(systemName: !isTapped ? "circle.fill" : "heart.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(celestialBody.color)
                        .frame(width: celestialBody.radius * 2, height: celestialBody.radius * 2)
                        .offset(x: x, y: y)
                        .position(CGPoint(x: 400 + x, y: 400 + y))
                        .onReceive(timer) { _ in
                            if !celestialBody.isSun && celestialBody.position == nil {
                                withAnimation(.linear(duration: 0.01)) {
                                    angle += 0.01 / celestialBody.orbitSpeed
                                    if angle >= 2 * .pi {
                                        angle = 0
                                    }
                                }
                            }
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

extension Color {
    static let sunYellow = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let venusYellow = Color(red: 0.94, green: 0.9, blue: 0.55)
    static let gold: Color = Color(red: 1.0, green: 0.84, blue: 0.0)
    static let jupiterOrange = Color(red: 0.89, green: 0.59, blue: 0.31)
    static let lightBlueGreen = Color(red: 0.68, green: 0.85, blue: 0.9)
    static let neptuneBlue = Color(red: 0.25, green: 0.41, blue: 0.88)
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

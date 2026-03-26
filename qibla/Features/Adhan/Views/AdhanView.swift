import SwiftUI
import CoreLocation
import Combine

// MARK: - Day Stage Logic
enum DayStage {
    case dawn, day, sunset, night
}

struct AdhanView: View {
    @State private var prayerTimes: PrayerTimesResult?
    @State private var currentTime = Date()
    @State private var nextPrayerFromTomorrow: (name: String, time: Date)? = nil
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // Détermine l'étape de la journée pour l'ambiance visuelle
    private var currentStage: DayStage {
        guard let t = prayerTimes else { return .night }
        let now = currentTime
        
        if now >= t.fajr && now < t.sunrise { return .dawn }
        if now >= t.sunrise && now < t.maghrib { return .day }
        if now >= t.maghrib && now < t.isha { return .sunset }
        return .night
    }

    var body: some View {
        ZStack {
            // 1. FOND DYNAMIQUE (Dessiné par code)
            AtmosphericBackgroundView(stage: currentStage)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 25) {
                    // HEADER
                    headerDateView
                    
                    // CARTE PROCHAINE PRIÈRE
                    if let next = currentNextPrayer {
                        nextPrayerCard(next: next)
                    }

                    // LISTE DES HORAIRES (Inclus les nouveaux tiers de nuit)
                    if let t = prayerTimes {
                        prayerListView(t: t)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .onAppear { refresh() }
        .onReceive(timer) { input in
            currentTime = input
            checkIfNeedTomorrow()
        }
    }

    // MARK: - Subviews
    private var headerDateView: some View {
        VStack(spacing: 8) {
            Text("✧ \(prayerTimes?.city.uppercased() ?? "CHARGEMENT") ✧")
                .font(.system(size: 18, weight: .bold, design: .serif))
                .foregroundColor(.white)
                .shadow(radius: 2)
                .padding(.top, 20)
            
            Text(Date().formatted(date: .complete, time: .omitted).uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private func nextPrayerCard(next: (name: String, time: Date)) -> some View {
        VStack(spacing: 10) {
            Text(Calendar.current.isDateInTomorrow(next.time) ? "DEMAIN" : "PROCHAINE PRIÈRE")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.7))
            
            Text(next.name.uppercased())
                .font(.system(size: 40, weight: .thin, design: .serif))
                .foregroundColor(.white)

            Text(timeRemaining(to: next.time))
                .font(.system(size: 24, weight: .light, design: .monospaced))
                .foregroundColor(Color.appGold)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.3))
                .clipShape(Capsule())
            
            Text("à \(next.time.formatted(date: .omitted, time: .shortened))")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(35)
        .background(RoundedRectangle(cornerRadius: 30).fill(.ultraThinMaterial))
        .padding(.horizontal)
    }

    private func prayerListView(t: PrayerTimesResult) -> some View {
        VStack(spacing: 0) {
            Group {
                PrayerRow(name: "Imsak", time: t.imsak, icon: "hourglass")
                PrayerRow(name: "Fajr", time: t.fajr, icon: "moon.stars.fill")
                PrayerRow(name: "Sunrise", time: t.sunrise, icon: "sunrise.fill")
                PrayerRow(name: "Dhuhr", time: t.dhuhr, icon: "sun.max.fill")
                PrayerRow(name: "Asr", time: t.asr, icon: "sun.min.fill")
                PrayerRow(name: "Maghrib", time: t.maghrib, icon: "sunset.fill")
                PrayerRow(name: "Isha", time: t.isha, icon: "moon.fill")
            }
            
            // Section Nuit (Optionnel, selon tes préférences de design)
            Group {
                Divider().background(Color.white.opacity(0.2)).padding(.horizontal)
                PrayerRow(name: "Midnight", time: t.midnight, icon: "moon.zzz.fill")
                PrayerRow(name: "Last Third", time: t.lastThird, icon: "sparkles")
            }
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(25)
        .padding()
    }

    // MARK: - Logic
    private func refresh() {
        LocationPrayerService.shared.update { res in
            self.prayerTimes = res
            self.nextPrayerFromTomorrow = nil
        }
    }

    private var currentNextPrayer: (name: String, time: Date)? {
        guard let t = prayerTimes else { return nil }
        // Liste ordonnée pour la recherche de la prochaine prière
        let todayPrayers = [
            ("Fajr", t.fajr), ("Sunrise", t.sunrise), ("Dhuhr", t.dhuhr),
            ("Asr", t.asr), ("Maghrib", t.maghrib), ("Isha", t.isha)
        ]
        
        if let next = todayPrayers.first(where: { $0.1 > currentTime }) {
            return next
        }
        return nextPrayerFromTomorrow
    }

    private func checkIfNeedTomorrow() {
        guard let t = prayerTimes, nextPrayerFromTomorrow == nil else { return }
        if currentTime > t.isha {
            let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            // Note: On utilise t.latitude et t.longitude (nouveaux noms de ton modèle Swift)
            if let tNext = AstroEngine.shared.calculate(date: tomorrow, lat: t.latitude, lon: t.longitude, city: t.city) {
                self.nextPrayerFromTomorrow = ("Fajr", tNext.fajr)
            }
        }
    }

    private func timeRemaining(to target: Date) -> String {
        let diff = Int(target.timeIntervalSince(currentTime))
        return diff < 0 ? "00:00:00" : String(format: "%02d:%02d:%02d", diff/3600, (diff%3600)/60, diff%60)
    }
}

// MARK: - COMPOSANTS ATMOSPHÉRIQUES

struct AtmosphericBackgroundView: View {
    let stage: DayStage
    
    var body: some View {
        ZStack {
            skyGradient
            if stage == .night { StarsView() }
            celestialBody
            AtmosphericGlow(stage: stage)
        }
    }
    
    private var skyGradient: some View {
        let colors: [Color]
        switch stage {
        case .dawn: colors = [Color(hex: "0C1428") ?? .blue, Color(hex: "E2A139") ?? .orange]
        case .day: colors = [Color(hex: "4CA1AF") ?? .blue, Color(hex: "C4E0E5") ?? .cyan]
        case .sunset: colors = [Color(hex: "2e294e") ?? .purple, Color(hex: "f46036") ?? .orange]
        case .night: colors = [Color(hex: "020409") ?? .black, Color(hex: "090F1B") ?? .black]
        }
        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }
    
    private var celestialBody: some View {
        Group {
            if stage == .day { SunView() }
            else if stage == .night { MoonView() }
        }
    }
}

private struct SunView: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(RadialGradient(colors: [.white, .yellow, .orange.opacity(0)], center: .center, startRadius: 0, endRadius: 100))
                .frame(width: 200, height: 200)
                .position(x: geo.size.width / 2, y: geo.size.height / 4)
                .blur(radius: 10)
        }
    }
}

private struct MoonView: View {
    var body: some View {
        GeometryReader { geo in
            Circle()
                .fill(RadialGradient(colors: [Color.white.opacity(0.8), Color.gray.opacity(0)], center: .center, startRadius: 0, endRadius: 60))
                .frame(width: 120, height: 120)
                .position(x: geo.size.width * 0.75, y: geo.size.height / 5)
        }
    }
}

private struct StarsView: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { context, size in
                for _ in 0..<100 {
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height * 0.6)
                    let rect = CGRect(x: x, y: y, width: 2, height: 2)
                    context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(Double.random(in: 0.2...0.7))))
                }
            }
        }
    }
}

private struct AtmosphericGlow: View {
    let stage: DayStage
    private var glowColor: Color {
        switch stage {
        case .dawn: return Color(hex: "FFCC33") ?? .orange
        case .day: return Color.white.opacity(0.2)
        case .sunset: return Color(hex: "FF4500") ?? .red
        case .night: return Color.clear
        }
    }
    var body: some View {
        VStack {
            Spacer()
            LinearGradient(colors: [glowColor.opacity(0.4), .clear], startPoint: .bottom, endPoint: .top)
                .frame(height: 200)
                .blur(radius: 40)
        }
    }
}


#Preview {
    AdhanView()
}

import SwiftUI

// MARK: - Saved Daily Data Models

struct MoodLogEntry: Codable, Identifiable {
    var id = UUID()
    let moods: [String]
    let typedMood: String
    let timeText: String
    // ADd camera, add so that food logging is possible with the text asw, add fake glucose editor, add the daily digest tab,intro instructions screen, prevent spamming xp, and descriptiosn count for more xp
}

struct ActivityLogEntry: Codable, Identifiable {
    var id = UUID()
    let activities: [String]
    let typedActivity: String
    let durationMinutes: Int
    let timeText: String
}

struct MealLogEntry: Codable, Identifiable {
    var id = UUID()
    let aiDescription: String
    let userDescription: String
    let timeText: String
}

struct GlucoseLogEntry: Codable, Identifiable {
    var id = UUID()
    let level: String // "Low", "Okay", or "High"
    let timeText: String
}


enum GlucoseRange {
    static func text(for level: String) -> String {
        switch level {
        case "Low":
            return "Below 70 mg/dL (3.9 mmol/L)"
        case "Okay":
            return "70–180 mg/dL (3.9–10.0 mmol/L)"
        case "High":
            return "Above 180 mg/dL (10.0 mmol/L)"
        default:
            return ""
        }
    }
}

struct DailyDataStore {
    static func dateForOffset(_ offset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: offset, to: Date()) ?? Date()
    }
    
    static func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    static func displayDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMMM d"
        return formatter.string(from: date)
    }
    
    static func displayDate(from dayKey: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dayKey) else {
            return dayKey
        }
        
        return displayDate(for: date)
    }
    
    static func currentTimeText() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: Date())
    }
    
    static func moodKey(_ dayKey: String) -> String {
        "moodLogs_\(dayKey)"
    }
    
    static func activityKey(_ dayKey: String) -> String {
        "activityLogs_\(dayKey)"
    }
    
    static func mealKey(_ dayKey: String) -> String {
        "mealCount_\(dayKey)"
    }
    
    static func digestKey(_ dayKey: String) -> String {
        "dailyDigest_\(dayKey)"
    }
    
    static func activeDayKey(_ dayOffset: Int) -> String {
        dayKey(for: dateForOffset(dayOffset))
    }
    
    static func loadMoodLogs(dayKey: String) -> [MoodLogEntry] {
        guard let data = UserDefaults.standard.data(forKey: moodKey(dayKey)) else {
            return []
        }
        
        return (try? JSONDecoder().decode([MoodLogEntry].self, from: data)) ?? []
    }
    
    static func saveMoodLogs(_ logs: [MoodLogEntry], dayKey: String) {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: moodKey(dayKey))
        }
        updateDigest(dayKey: dayKey)
    }
    
    static func addMoodLog(dayKey: String, moods: [String], typedMood: String) {
        var logs = loadMoodLogs(dayKey: dayKey)
        
        let newLog = MoodLogEntry(
            moods: moods,
            typedMood: typedMood,
            timeText: currentTimeText()
        )
        
        logs.append(newLog)
        saveMoodLogs(logs, dayKey: dayKey)
    }
    
    static func loadActivityLogs(dayKey: String) -> [ActivityLogEntry] {
        guard let data = UserDefaults.standard.data(forKey: activityKey(dayKey)) else {
            return []
        }
        
        return (try? JSONDecoder().decode([ActivityLogEntry].self, from: data)) ?? []
    }
    
    static func saveActivityLogs(_ logs: [ActivityLogEntry], dayKey: String) {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: activityKey(dayKey))
        }
        updateDigest(dayKey: dayKey)
    }
    
    static func addActivityLog(dayKey: String, activities: [String], typedActivity: String, duration: Int) {
        var logs = loadActivityLogs(dayKey: dayKey)
        
        let newLog = ActivityLogEntry(
            activities: activities,
            typedActivity: typedActivity,
            durationMinutes: duration,
            timeText: currentTimeText()
        )
        
        logs.append(newLog)
        saveActivityLogs(logs, dayKey: dayKey)
    }
    
    static func loadMealCount(dayKey: String) -> Int {
        UserDefaults.standard.integer(forKey: mealKey(dayKey))
    }
    
    static func addMeal(dayKey: String) {
        let current = loadMealCount(dayKey: dayKey)
        UserDefaults.standard.set(min(current + 1, 3), forKey: mealKey(dayKey))
        updateDigest(dayKey: dayKey)
    }

    static func mealLogsKey(_ dayKey: String) -> String {
        "mealLogs_\(dayKey)"
    }

    static func loadMealLogs(dayKey: String) -> [MealLogEntry] {
        guard let data = UserDefaults.standard.data(forKey: mealLogsKey(dayKey)) else {
            return []
        }

        return (try? JSONDecoder().decode([MealLogEntry].self, from: data)) ?? []
    }

    static func saveMealLogs(_ logs: [MealLogEntry], dayKey: String) {
        if let data = try? JSONEncoder().encode(logs) {
            UserDefaults.standard.set(data, forKey: mealLogsKey(dayKey))
        }
    }

    static func addMealLog(dayKey: String, aiDescription: String, userDescription: String) {
        var logs = loadMealLogs(dayKey: dayKey)

        let newLog = MealLogEntry(
            aiDescription: aiDescription,
            userDescription: userDescription,
            timeText: currentTimeText()
        )

        logs.append(newLog)
        saveMealLogs(logs, dayKey: dayKey)
        addMeal(dayKey: dayKey)
    }

    static func glucoseKey(_ dayKey: String) -> String {
        "glucoseLogs_\(dayKey)"
    }

    static func loadGlucoseLogs(dayKey: String) -> [GlucoseLogEntry] {
        guard let data = UserDefaults.standard.data(forKey: glucoseKey(dayKey)) else {
            return []
        }

        return (try? JSONDecoder().decode([GlucoseLogEntry].self, from: data)) ?? []
    }

    static func hasGlucoseLog(dayKey: String) -> Bool {
        !loadGlucoseLogs(dayKey: dayKey).isEmpty
    }

    /// Testing-only stub: one glucose status per day. Logging again the same day overwrites it
    /// rather than appending, since there's no real CGM feed yet.
    static func setGlucoseLog(dayKey: String, level: String) {
        let entry = GlucoseLogEntry(level: level, timeText: currentTimeText())
        if let data = try? JSONEncoder().encode([entry]) {
            UserDefaults.standard.set(data, forKey: glucoseKey(dayKey))
        }
        updateDigest(dayKey: dayKey)
    }

    /// Updates the placeholder summary shown until the pal is tapped and a real AI digest is generated.
    /// Does NOT call the AI — that only happens from MainView when the pal is tapped (see regenerateAIDigest).
    static func updateDigest(dayKey: String) {
        let moodLogs = loadMoodLogs(dayKey: dayKey)
        let activityLogs = loadActivityLogs(dayKey: dayKey)
        let mealCount = loadMealCount(dayKey: dayKey)

        let fallback = "Today you logged \(mealCount) meal(s), \(moodLogs.count) mood check-in(s), and \(activityLogs.count) activity log(s). Tap your pal to generate your daily digest."

        UserDefaults.standard.set(fallback, forKey: digestKey(dayKey))
    }

    /// Only called when the user explicitly confirms (e.g. taps "Yes" on the pal's digest popup).
    static func regenerateAIDigest(dayKey: String) async -> DigestGenerationResult {
        let foodLogs = loadMealLogs(dayKey: dayKey)
        let moodLogs = loadMoodLogs(dayKey: dayKey)
        let activityLogs = loadActivityLogs(dayKey: dayKey)
        let glucoseLogs = loadGlucoseLogs(dayKey: dayKey)

        guard !foodLogs.isEmpty || !moodLogs.isEmpty || !activityLogs.isEmpty || !glucoseLogs.isEmpty else {
            return .noLogs
        }

        do {
            let digest = try await DigestService.generateDigest(
                foodLogs: foodLogs,
                moodLogs: moodLogs,
                activityLogs: activityLogs,
                glucoseLogs: glucoseLogs
            )

            await MainActor.run {
                UserDefaults.standard.set(digest, forKey: digestKey(dayKey))
                NotificationCenter.default.post(name: .digestDidUpdate, object: nil, userInfo: ["dayKey": dayKey])
            }

            return .success(digest)
        } catch {
            // AI call failed (e.g. LM Studio isn't running) — the fallback summary stays in place.
            return .failure(error.localizedDescription)
        }
    }

    static func loadDigest(dayKey: String) -> String {
        UserDefaults.standard.string(forKey: digestKey(dayKey)) ?? "No daily digest yet. Log mood, activity, or food to create one."
    }

    static func hasAnyLog(dayKey: String) -> Bool {
        !loadMoodLogs(dayKey: dayKey).isEmpty ||
        !loadActivityLogs(dayKey: dayKey).isEmpty ||
        !loadGlucoseLogs(dayKey: dayKey).isEmpty ||
        loadMealCount(dayKey: dayKey) > 0
    }
    
    static func diaryDayKeys(simulationDayOffset: Int) -> [String] {
        var keys: [String] = []
        let daysForward = max(simulationDayOffset, 3)
        
        for offset in stride(from: daysForward, through: -14, by: -1) {
            let date = dateForOffset(offset)
            keys.append(dayKey(for: date))
        }
        
        return keys
    }
}

extension Notification.Name {
    static let digestDidUpdate = Notification.Name("digestDidUpdate")
}

enum DigestGenerationResult {
    case success(String)
    case noLogs
    case failure(String)
}

// MARK: - Main View

struct MainView: View {
    @AppStorage("childName") private var childName = ""
    @AppStorage("palName") private var palName = "Sugar Booger"
    @AppStorage("simulationDayOffset") private var simulationDayOffset = 0
    @AppStorage("selectedActivities") private var onboardingActivities = ""
    
    @AppStorage("rewardAmount") private var rewardAmount = ""
    @AppStorage("rewardItem") private var rewardItem = ""
    @AppStorage("levelGoal") private var levelGoal = 2
    
    @AppStorage("palXP") private var palXP = 80
    @AppStorage("palLevel") private var palLevel = 1
    
    @State private var showEditPalName = false
    @State private var draftPalName = ""
    @State private var showRewardPopup = false
    @State private var showLevelUpPopup = false
    @State private var levelUpMessage = ""
    
    @State private var showMoodPopup = false
    @State private var selectedMoods: Set<String> = []
    @State private var typedMood = ""
    
    @State private var showActivityPopup = false
    @State private var selectedActivityChoices: Set<String> = []
    @State private var typedActivity = ""
    @State private var activityDuration = 30.0
    
    @State private var showDiaryScreen = false
    @State private var showFoodLogScreen = false
    @State private var bouncePal = false

    @State private var moodCount = 0
    @State private var activityCount = 0
    @State private var mealCount = 0

    @State private var showGlucosePopup = false
    @State private var glucoseStatus: String = "Not logged"

    @State private var showDigestPopup = false
    @State private var isGeneratingDigest = false
    @State private var digestPopupText = ""
    @State private var digestPopupError: String?
    
    var requiredXP: Int {
        palLevel * 100
    }
    
    var simulatedDate: Date {
        DailyDataStore.dateForOffset(simulationDayOffset)
    }
    
    var simulatedDateText: String {
        DailyDataStore.displayDate(for: simulatedDate)
    }
    
    var dayKey: String {
        DailyDataStore.dayKey(for: simulatedDate)
    }
    
    var streakCount: Int {
        simulationDayOffset + 1
    }
    
    var frequentActivities: [String] {
        onboardingActivities
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }
    
    var rewardText: String {
        let cleanAmount = rewardAmount.trimmingCharacters(in: .whitespaces)
        let cleanItem = rewardItem.trimmingCharacters(in: .whitespaces)
        
        if !cleanAmount.isEmpty && !cleanItem.isEmpty {
            return "$\(cleanAmount) \(cleanItem) at Level \(levelGoal)"
        } else if !cleanAmount.isEmpty {
            return "$\(cleanAmount) at Level \(levelGoal)"
        } else if !cleanItem.isEmpty {
            return "\(cleanItem) at Level \(levelGoal)"
        } else {
            return "$5 at Level \(levelGoal)"
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#CEE5EA")
                .ignoresSafeArea()
            
            Image("mainScreenBackground")
                .resizable()
                .scaledToFill()
                .offset(x: -24)
                .offset(y: 6)
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image("sugarpalLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 185)
                        .offset(x: -9)
                    
                    Spacer()
                    
                    HStack(spacing: 7) {
                        Text(simulatedDateText)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                        
                        Button {
                            simulationDayOffset = 0
                            loadChecklistData()
                        } label: {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .font(.system(size: 25, weight: .bold))
                                .foregroundColor(Color(hex: "#77A4B3"))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            simulationDayOffset += 1
                            loadChecklistData()
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(hex: "#77A4B3"))
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            resetAllData()
                        } label: {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(Color(hex: "#77A4B3"))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 38)
                .padding(.top, -3)
                
                Text("Hey \(childName.isEmpty ? "there" : childName)!")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                    .padding(.leading, 44)
                    .padding(.top, -2)
                
                Text("Make sure to log all your efforts!")
                    .font(.custom("Roboto-Regular", size: 19))
                    .foregroundColor(Color(hex: "#4E788D"))
                    .padding(.leading, 44)
                    .padding(.top, 8)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 26)
                        .fill(Color(hex: "#F8F4EF").opacity(0.95))
                        .frame(width: 380, height: 495)
                        .overlay(alignment: .topTrailing) {
                            Image("flower2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55)
                                .offset(x: 19, y: -20)
                        }
                        .overlay(alignment: .bottomLeading) {
                            Image("flower1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45)
                                .offset(x: -12, y: 25)
                        }
                    
                    Image("palBackground")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 420)
                        .offset(x: 14, y: -28)
                    
                    Image("sugarPalCharacter")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 390)
                        .offset(x: -12, y: -38)
                        .offset(y: bouncePal ? -6 : 6)
                        .animation(
                            .easeInOut(duration: 1.4)
                            .repeatForever(autoreverses: true),
                            value: bouncePal
                        )
                        .onTapGesture {
                            openDigestPopup()
                        }
                    
                    VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 6) {
                                    Text(palName)
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#E2CDB9"))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.7)
                                    
                                    Button {
                                        draftPalName = palName
                                        showEditPalName = true
                                    } label: {
                                        Image(systemName: "pencil.circle.fill")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color(hex: "#77A4B3"))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .frame(width: 250, alignment: .leading)
                                .padding(.horizontal, -8)
                                .padding(.vertical, -6)
                                
                                Text("Level \(palLevel)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(.gray)
                                    .padding(.leading, -6)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: -7) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(Color(hex: "#E2CDB9"))
                                
                                Text("\(streakCount)")
                                    .font(.system(size: 20, weight: .regular, design: .rounded))
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                            }
                            .padding(.top, 2)
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 16)
                        
                        Spacer()
                    }
                    .frame(width: 380, height: 495)
                    
                    VStack(spacing: 0) {
                        Spacer()
                        
                        Text("Tap me for your daily digest!")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#E2CDB9"))
                            .padding(.bottom, 3)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text("Pal XP")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4E788D"))
                                
                                Spacer()
                                
                                Text("\(palXP)/\(requiredXP) XP")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4E788D"))
                            }
                            
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.gray.opacity(0.25))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(hex: "#4E788D"))
                                    .frame(width: CGFloat(palXP) / CGFloat(requiredXP) * 330, height: 12)
                            }
                        }
                        .frame(width: 330)
                        
                        HStack(spacing: 55) {
                            RewardMiniCard {
                                showRewardPopup = true
                            }
                            
                            GlucoseCard(statusText: glucoseStatus) {
                                showGlucosePopup = true
                            }
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 18)
                    }
                    .frame(width: 380, height: 495)
                }
                .frame(width: 380, height: 495)
                .padding(.leading, 60)
                .padding(.top, 24)

                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(hex: "#F8F4EF").opacity(0.95))
                        .frame(width: 380, height: 118)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Checklist")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .padding(.leading, 20)
                        
                        VStack(spacing: 5) {
                            ChecklistProgressRow(
                                title: "Meal",
                                icon: "fork.knife",
                                progress: "\(mealCount)/3",
                                fillAmount: min(CGFloat(mealCount) / 3.0, 1.0)
                            )
                            
                            ChecklistProgressRow(
                                title: "Mood",
                                icon: "heart.fill",
                                progress: "\(moodCount)/3",
                                fillAmount: min(CGFloat(moodCount) / 3.0, 1.0)
                            )
                            
                            ChecklistProgressRow(
                                title: "Activity",
                                icon: "figure.strengthtraining.traditional",
                                progress: "\(activityCount)/2",
                                fillAmount: min(CGFloat(activityCount) / 2.0, 1.0)
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    .offset(y: -5)
                }
                .frame(width: 380, height: 118)
                .padding(.leading, 60)
                .padding(.top, 12)

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.9))
                        .frame(width: 380, height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(hex: "#8EDAF4"), lineWidth: 2)
                        )
                        .overlay(alignment: .bottomLeading) {
                            Image("flower1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 48)
                                .offset(x: 348, y: 28)
                        }
                    
                    HStack(spacing: 13) {
                        BottomNavButton(title: "Mood", icon: "heart.fill") {
                            showMoodPopup = true
                        }
                        
                        BottomNavButton(title: "Activity", icon: "figure.run") {
                            showActivityPopup = true
                        }
                        
                        BottomNavButton(title: "Food", icon: "camera.fill") {
                            showFoodLogScreen = true
                        }
                        
                        BottomNavButton(title: "Steps", icon: nil, customText: "9.1k") {
                            print("Steps tapped")
                        }

                        BottomNavButton(title: "Diary", icon: "calendar") {
                            showDiaryScreen = true
                        }
                    }
                }
                .frame(width: 380, height: 80)
                .padding(.leading, 60)
                .padding(.bottom, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            if showRewardPopup {
                RewardPopup(
                    rewardText: rewardText,
                    levelGoal: levelGoal,
                    closeAction: {
                        showRewardPopup = false
                    }
                )
            }
            
            if showLevelUpPopup {
                LevelUpPopup(
                    level: palLevel,
                    message: levelUpMessage,
                    closeAction: {
                        showLevelUpPopup = false
                    }
                )
            }
            
            if showMoodPopup {
                MoodPopup(
                    selectedMoods: $selectedMoods,
                    typedMood: $typedMood,
                    closeAction: {
                        showMoodPopup = false
                    },
                    saveAction: {
                        saveMoodLog()
                    }
                )
            }
            
            if showActivityPopup {
                ActivityPopup(
                    frequentActivities: frequentActivities,
                    selectedActivities: $selectedActivityChoices,
                    typedActivity: $typedActivity,
                    activityDuration: $activityDuration,
                    closeAction: {
                        showActivityPopup = false
                    },
                    saveAction: {
                        saveActivityLog()
                    }
                )
            }

            if showGlucosePopup {
                GlucosePopup(
                    closeAction: {
                        showGlucosePopup = false
                    },
                    saveAction: { level in
                        saveGlucoseLog(level: level)
                    }
                )
            }

            if showDigestPopup {
                DigestPopup(
                    isGenerating: isGeneratingDigest,
                    digestText: digestPopupText,
                    errorMessage: digestPopupError,
                    closeAction: {
                        showDigestPopup = false
                    },
                    confirmAction: {
                        confirmGenerateDigest()
                    }
                )
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showDiaryScreen) {
            DiaryView()
        }
        .navigationDestination(isPresented: $showFoodLogScreen) {
            FoodLogView()
        }
        .sheet(isPresented: $showEditPalName) {
            EditPalNameSheet(
                palName: $palName,
                draftPalName: $draftPalName,
                showEditPalName: $showEditPalName
            )
            .presentationDetents([.height(330)])
            .presentationDragIndicator(.visible)
        }
        .onAppear {
            bouncePal = true
            
            if palLevel == 1 && palXP == 0 {
                palXP = 80
            }
            
            loadChecklistData()
        }
    }
    
    func loadChecklistData() {
        let key = DailyDataStore.activeDayKey(simulationDayOffset)
        mealCount = DailyDataStore.loadMealCount(dayKey: key)
        moodCount = DailyDataStore.loadMoodLogs(dayKey: key).count
        activityCount = DailyDataStore.loadActivityLogs(dayKey: key).count
        glucoseStatus = DailyDataStore.loadGlucoseLogs(dayKey: key).first?.level ?? "Not logged"
    }
    
    func addXP(_ amount: Int) {
        let oldLevel = palLevel
        
        palXP += amount
        
        while palXP >= palLevel * 100 {
            palXP -= palLevel * 100
            palLevel += 1
        }
        
        if palLevel > oldLevel {
            levelUpMessage = "Great job! You reached Level \(palLevel). Keep logging and learning your patterns!"
            showLevelUpPopup = true
        }
    }
    
    func resetAllData() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        childName = ""
        palName = "Sugar Booger"
        simulationDayOffset = 0
        onboardingActivities = ""
        
        rewardAmount = ""
        rewardItem = ""
        levelGoal = 2
        
        palLevel = 1
        palXP = 80
        
        selectedMoods.removeAll()
        typedMood = ""
        selectedActivityChoices.removeAll()
        typedActivity = ""
        activityDuration = 30
        
        moodCount = 0
        activityCount = 0
        mealCount = 0
        glucoseStatus = "Not logged"

        showMoodPopup = false
        showActivityPopup = false
        showGlucosePopup = false
        showDigestPopup = false
        isGeneratingDigest = false
        digestPopupText = ""
        digestPopupError = nil
        showRewardPopup = false
        showLevelUpPopup = false
        showDiaryScreen = false
    }
    
    func saveMoodLog() {
        let selected = Array(selectedMoods).sorted()
        let typed = typedMood.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !selected.isEmpty || !typed.isEmpty else {
            showMoodPopup = false
            return
        }
        
        DailyDataStore.addMoodLog(
            dayKey: dayKey,
            moods: selected,
            typedMood: typed
        )
        
        addXP(5)
        
        selectedMoods.removeAll()
        typedMood = ""
        showMoodPopup = false
        loadChecklistData()
    }
    
    func saveActivityLog() {
        let selected = Array(selectedActivityChoices).sorted()
        let typed = typedActivity.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !selected.isEmpty || !typed.isEmpty else {
            showActivityPopup = false
            return
        }
        
        DailyDataStore.addActivityLog(
            dayKey: dayKey,
            activities: selected,
            typedActivity: typed,
            duration: Int(activityDuration)
        )
        
        addXP(5)
        
        selectedActivityChoices.removeAll()
        typedActivity = ""
        activityDuration = 30
        showActivityPopup = false
        loadChecklistData()
    }

    func saveGlucoseLog(level: String) {
        let alreadyLoggedToday = DailyDataStore.hasGlucoseLog(dayKey: dayKey)

        DailyDataStore.setGlucoseLog(dayKey: dayKey, level: level)

        if !alreadyLoggedToday {
            addXP(5)
        }

        showGlucosePopup = false
        loadChecklistData()
    }

    func openDigestPopup() {
        digestPopupText = ""
        digestPopupError = nil
        isGeneratingDigest = false
        showDigestPopup = true
    }

    func confirmGenerateDigest() {
        isGeneratingDigest = true
        digestPopupText = ""
        digestPopupError = nil

        Task {
            let result = await DailyDataStore.regenerateAIDigest(dayKey: dayKey)

            isGeneratingDigest = false

            switch result {
            case .success(let text):
                digestPopupText = text
            case .noLogs:
                digestPopupError = "Log a mood, activity, meal, or glucose reading first so there's something to summarize."
            case .failure(let message):
                digestPopupError = "Couldn't reach the AI: \(message)"
            }
        }
    }
}

// MARK: - Popups

struct MoodPopup: View {
    @Binding var selectedMoods: Set<String>
    @Binding var typedMood: String
    let closeAction: () -> Void
    let saveAction: () -> Void
    
    let moodOptions = [
        "Happy", "Okay", "Tired", "Low energy",
        "Thirsty", "Hungry", "Headache", "Dizzy",
        "Shaky", "Sweaty", "Nervous", "Stomach ache",
        "Irritable", "Focused", "Sad", "Stressed"
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    closeAction()
                }
            
            VStack(spacing: 14) {
                Text("How are you feeling?")
                    .font(.system(size: 27, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                
                Text("Pick one or more. Try logging after each meal.")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(moodOptions, id: \.self) { mood in
                        Button {
                            if selectedMoods.contains(mood) {
                                selectedMoods.remove(mood)
                            } else {
                                selectedMoods.insert(mood)
                            }
                        } label: {
                            Text(mood)
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(selectedMoods.contains(mood) ? .white : Color(hex: "#4E788D"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 38)
                                .background(selectedMoods.contains(mood) ? Color(hex: "#77A4B3") : Color(hex: "#CBE8EE"))
                                .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Or type how you feel")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                    
                    TextField("Example: I feel sleepy after lunch", text: $typedMood)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    Button {
                        selectedMoods.removeAll()
                        typedMood = ""
                    } label: {
                        Text("Clear")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .frame(width: 120, height: 46)
                            .background(Color.white)
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        saveAction()
                    } label: {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 46)
                            .background(Color(hex: "#77A4B3"))
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 340)
            .padding(.vertical, 24)
            .background(Color(hex: "#F8F4EF"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
            )
            .shadow(radius: 12)
        }
    }
}

struct ActivityPopup: View {
    let frequentActivities: [String]
    @Binding var selectedActivities: Set<String>
    @Binding var typedActivity: String
    @Binding var activityDuration: Double
    let closeAction: () -> Void
    let saveAction: () -> Void
    
    let otherActivities = [
        "Walking", "Running", "Soccer", "Basketball",
        "Biking", "Swimming", "Gym", "Dancing",
        "Yoga", "Stretching", "Playground", "School PE",
        "Rest day", "Light chores"
    ]
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    closeAction()
                }
            
            VStack(spacing: 12) {
                Text("What activity did you do?")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                
                Text("Pick activities, duration, and details.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                
                if !frequentActivities.isEmpty {
                    ActivityOptionSection(
                        title: "Your frequent activities",
                        activities: frequentActivities,
                        selectedActivities: $selectedActivities
                    )
                }
                
                ActivityOptionSection(
                    title: "Other activities",
                    activities: otherActivities,
                    selectedActivities: $selectedActivities
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Duration of activity")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                    
                    HStack {
                        Text("\(Int(activityDuration)) min")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .frame(width: 65, alignment: .leading)
                        
                        Slider(value: $activityDuration, in: 5...180, step: 5)
                    }
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Describe your activity")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                    
                    TextField("Example: Played soccer after lunch", text: $typedActivity)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .padding(.horizontal, 14)
                        .frame(height: 48)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                        )
                }
                .padding(.horizontal, 20)
                
                HStack(spacing: 12) {
                    Button {
                        selectedActivities.removeAll()
                        typedActivity = ""
                        activityDuration = 30
                    } label: {
                        Text("Clear")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .frame(width: 120, height: 46)
                            .background(Color.white)
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        saveAction()
                    } label: {
                        Text("Done")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 46)
                            .background(Color(hex: "#77A4B3"))
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(width: 350)
            .padding(.vertical, 22)
            .background(Color(hex: "#F8F4EF"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
            )
            .shadow(radius: 12)
        }
    }
}

struct ActivityOptionSection: View {
    let title: String
    let activities: [String]
    @Binding var selectedActivities: Set<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#4E788D"))
                .padding(.leading, 18)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(activities, id: \.self) { activity in
                    ActivityChoiceButton(
                        title: activity,
                        isSelected: selectedActivities.contains(activity)
                    ) {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }
                }
            }
            .padding(.horizontal, 18)
        }
    }
}

struct ActivityChoiceButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(hex: "#4E788D"))
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isSelected ? Color(hex: "#77A4B3") : Color(hex: "#CBE8EE"))
                .cornerRadius(15)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Glucose Popup

struct GlucosePopup: View {
    let closeAction: () -> Void
    let saveAction: (String) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    closeAction()
                }

            VStack(spacing: 16) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))

                Text("How's your blood sugar?")
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))

                Text("Log what your reading or your body is telling you right now.")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                VStack(spacing: 10) {
                    GlucoseChoiceButton(title: "Low", subtitle: GlucoseRange.text(for: "Low"), color: Color(hex: "#E7A6A0")) {
                        saveAction("Low")
                    }

                    GlucoseChoiceButton(title: "Okay", subtitle: GlucoseRange.text(for: "Okay"), color: Color(hex: "#8FC7A0")) {
                        saveAction("Okay")
                    }

                    GlucoseChoiceButton(title: "High", subtitle: GlucoseRange.text(for: "High"), color: Color(hex: "#E7C56A")) {
                        saveAction("High")
                    }
                }
                .padding(.horizontal, 18)

                Button {
                    closeAction()
                } label: {
                    Text("Cancel")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .frame(width: 140, height: 44)
                        .background(Color.white)
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 340)
            .padding(.vertical, 24)
            .background(Color(hex: "#F8F4EF"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
            )
            .shadow(radius: 12)
        }
    }
}

struct GlucoseChoiceButton: View {
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(color)
            .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Digest Popup

struct DigestPopup: View {
    let isGenerating: Bool
    let digestText: String
    let errorMessage: String?
    let closeAction: () -> Void
    let confirmAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    closeAction()
                }

            VStack(spacing: 16) {
                Image(systemName: "sparkles")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))

                if let errorMessage {
                    Text("Couldn't Generate Digest")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))

                    Text(errorMessage)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)

                    HStack(spacing: 12) {
                        Button {
                            closeAction()
                        } label: {
                            Text("Close")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4E788D"))
                                .frame(width: 120, height: 46)
                                .background(Color.white)
                                .cornerRadius(22)
                        }
                        .buttonStyle(.plain)

                        Button {
                            confirmAction()
                        } label: {
                            Text("Try Again")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 46)
                                .background(Color(hex: "#77A4B3"))
                                .cornerRadius(22)
                        }
                        .buttonStyle(.plain)
                    }
                } else if isGenerating {
                    Text("Generating Your Digest…")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .multilineTextAlignment(.center)

                    ProgressView()
                        .padding(.vertical, 4)

                    Text("This can take a few minutes on a local model.")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                } else if !digestText.isEmpty {
                    Text("Your Daily Digest")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))

                    Text(digestText)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal, 18)

                    Button {
                        closeAction()
                    } label: {
                        Text("Nice!")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 150, height: 46)
                            .background(Color(hex: "#77A4B3"))
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text("Want Your Daily Digest?")
                        .font(.system(size: 23, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))

                    Text("I'll look at everything you've logged today and give you a short pattern summary.")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 18)

                    HStack(spacing: 12) {
                        Button {
                            closeAction()
                        } label: {
                            Text("Not Now")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4E788D"))
                                .frame(width: 130, height: 46)
                                .background(Color.white)
                                .cornerRadius(22)
                        }
                        .buttonStyle(.plain)

                        Button {
                            confirmAction()
                        } label: {
                            Text("Yes, Generate")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(width: 130, height: 46)
                                .background(Color(hex: "#77A4B3"))
                                .cornerRadius(22)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .frame(width: 320)
            .padding(.vertical, 26)
            .background(Color(hex: "#F8F4EF"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
            )
            .shadow(radius: 12)
        }
    }
}

// MARK: - Level Up Popup

struct LevelUpPopup: View {
    let level: Int
    let message: String
    let closeAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    closeAction()
                }
            
            VStack(spacing: 14) {
                Image(systemName: "sparkles")
                    .font(.system(size: 46, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))
                
                Text("Level Up!")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                
                Text("You reached Level \(level)")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#E2CDB9"))
                
                Text(message)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                
                Button {
                    closeAction()
                } label: {
                    Text("Awesome!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 160, height: 48)
                        .background(Color(hex: "#77A4B3"))
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 310)
            .padding(.vertical, 28)
            .background(Color(hex: "#F8F4EF"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
            )
            .shadow(radius: 12)
        }
    }
}

// MARK: - Small Components

struct RewardPopup: View {
    let rewardText: String
    let levelGoal: Int
    let closeAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.18)
                .ignoresSafeArea()
                .onTapGesture {
                    closeAction()
                }
            
            VStack(spacing: 14) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))
                
                Text("Your Reward")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                
                Text(rewardText)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                
                Text("You get this when you reach Level \(levelGoal)!")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 18)
                
                Button {
                    closeAction()
                } label: {
                    Text("Okay!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(width: 150, height: 48)
                        .background(Color(hex: "#77A4B3"))
                        .cornerRadius(22)
                }
                .buttonStyle(.plain)
            }
            .frame(width: 300)
            .padding(.vertical, 26)
            .background(Color(hex: "#F8F4EF"))
            .cornerRadius(28)
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
            )
            .shadow(radius: 12)
        }
    }
}

struct ChecklistProgressRow: View {
    let title: String
    let icon: String
    let progress: String
    let fillAmount: CGFloat
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Color(hex: "#77A4B3"))
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#4E788D"))
                .frame(width: 62, alignment: .leading)
            
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#EFE3D6"))
                    .frame(width: 145, height: 9)
                
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "#E2CDB9"))
                    .frame(width: 145 * fillAmount, height: 9)
            }
            
            Text(progress)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#4E788D"))
                .frame(width: 32, alignment: .trailing)
        }
        .frame(width: 330)
    }
}

struct BottomNavButton: View {
    let title: String
    let icon: String?
    var customText: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 1) {
                if let customText = customText {
                    Text(customText)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .frame(height: 31)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 27, weight: .bold))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .frame(height: 31)
                }
                
                Text(title)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
            }
            .frame(width: 58, height: 62)
            .background(Color(hex: "#CBE8EE"))
            .cornerRadius(14)
        }
        .buttonStyle(.plain)
    }
}

struct RewardMiniCard: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))
                
                Text("Reward")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 10)
            .frame(width: 145, height: 55)
            .background(Color(hex: "#CBE8EE"))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct GlucoseCard: View {
    let statusText: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 31, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))

                VStack(alignment: .leading, spacing: 1) {
                    Text("Glucose")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)

                    Text(statusText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 10)
            .frame(width: 145, height: 55)
            .background(Color(hex: "#CBE8EE"))
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct EditPalNameSheet: View {
    @Binding var palName: String
    @Binding var draftPalName: String
    @Binding var showEditPalName: Bool
    
    var body: some View {
        ZStack {
            Color(hex: "#D3EAEE")
                .ignoresSafeArea()
            
            VStack(spacing: 18) {
                Text("Rename Your Pal")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                
                Text("Give your SugarPal a fun name!")
                    .font(.custom("Roboto-Regular", size: 18))
                    .foregroundColor(Color(hex: "#4E788D"))
                
                TextField("Enter pal name", text: $draftPalName)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .frame(width: 310, height: 55)
                    .background(Color.white)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                    )
                
                HStack(spacing: 14) {
                    Button {
                        showEditPalName = false
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .frame(width: 135, height: 50)
                            .background(Color.white)
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        if !draftPalName.trimmingCharacters(in: .whitespaces).isEmpty {
                            palName = draftPalName.trimmingCharacters(in: .whitespaces)
                        }
                        showEditPalName = false
                    } label: {
                        Text("Save")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(width: 135, height: 50)
                            .background(Color(hex: "#77A4B3"))
                            .cornerRadius(22)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
    }
}


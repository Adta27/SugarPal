import SwiftUI

struct DiaryView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("simulationDayOffset") private var simulationDayOffset = 0
    
    @State private var selectedDayKey: String = DailyDataStore.activeDayKey(0)
    @State private var digestText: String = ""

    var dayKeys: [String] {
        DailyDataStore.diaryDayKeys(simulationDayOffset: simulationDayOffset)
    }

    var moodLogs: [MoodLogEntry] {
        DailyDataStore.loadMoodLogs(dayKey: selectedDayKey)
    }

    var activityLogs: [ActivityLogEntry] {
        DailyDataStore.loadActivityLogs(dayKey: selectedDayKey)
    }

    var mealCount: Int {
        DailyDataStore.loadMealCount(dayKey: selectedDayKey)
    }

    var mealLogs: [MealLogEntry] {
        DailyDataStore.loadMealLogs(dayKey: selectedDayKey)
    }

    var glucoseLogs: [GlucoseLogEntry] {
        DailyDataStore.loadGlucoseLogs(dayKey: selectedDayKey)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "#CEE5EA")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(Color(hex: "#4E788D"))
                    }
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("Diary")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                    
                    Spacer()
                    
                    Image(systemName: "book.fill")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#77A4B3"))
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)
                
                Text("Tap a day to see what was logged.")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.top, 6)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(dayKeys, id: \.self) { key in
                            Button {
                                selectedDayKey = key
                                digestText = DailyDataStore.loadDigest(dayKey: key)
                            } label: {
                                VStack(spacing: 4) {
                                    Text(DailyDataStore.displayDate(from: key))
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(selectedDayKey == key ? .white : Color(hex: "#4E788D"))
                                        .lineLimit(1)
                                    
                                    if DailyDataStore.hasAnyLog(dayKey: key) {
                                        Circle()
                                            .fill(selectedDayKey == key ? Color.white : Color(hex: "#77A4B3"))
                                            .frame(width: 7, height: 7)
                                    } else {
                                        Circle()
                                            .fill(Color.clear)
                                            .frame(width: 7, height: 7)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 56)
                                .background(selectedDayKey == key ? Color(hex: "#77A4B3") : Color(hex: "#F8F4EF"))
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "#CBE8EE"), lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        Text(DailyDataStore.displayDate(from: selectedDayKey))
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .padding(.top, 20)
                        
                        DiarySummaryCard(
                            mealCount: mealCount,
                            moodCount: moodLogs.count,
                            activityCount: activityLogs.count
                        )
                        
                        DiarySectionCard(title: "Daily Digest", icon: "sparkles") {
                            Text(digestText)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.leading)
                        }

                        DiarySectionCard(title: "Glucose", icon: "heart.text.square.fill") {
                            if glucoseLogs.isEmpty {
                                EmptyDiaryText(text: "No glucose logged for this day yet.")
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(glucoseLogs) { log in
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Text(log.level)
                                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                                    .foregroundColor(Color(hex: "#4E788D"))

                                                Spacer()

                                                Text(log.timeText)
                                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.gray)
                                            }

                                            Text(GlucoseRange.text(for: log.level))
                                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                                .foregroundColor(.gray)
                                        }
                                        .padding(12)
                                        .background(Color(hex: "#CBE8EE"))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }

                        DiarySectionCard(title: "Mood Logs", icon: "heart.fill") {
                            if moodLogs.isEmpty {
                                EmptyDiaryText(text: "No mood logged for this day yet.")
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(Array(moodLogs.enumerated()), id: \.element.id) { index, log in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("Mood \(index + 1) of 3 • \(log.timeText)")
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#4E788D"))
                                            
                                            if !log.moods.isEmpty {
                                                Text(log.moods.joined(separator: ", "))
                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            if !log.typedMood.isEmpty {
                                                Text(log.typedMood)
                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(Color(hex: "#CBE8EE"))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        
                        DiarySectionCard(title: "Activity Logs", icon: "figure.run") {
                            if activityLogs.isEmpty {
                                EmptyDiaryText(text: "No activity logged for this day yet.")
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(activityLogs) { log in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("\(log.durationMinutes) min • \(log.timeText)")
                                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#4E788D"))
                                            
                                            if !log.activities.isEmpty {
                                                Text(log.activities.joined(separator: ", "))
                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.gray)
                                            }
                                            
                                            if !log.typedActivity.isEmpty {
                                                Text(log.typedActivity)
                                                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(Color(hex: "#CBE8EE"))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                        
                        DiarySectionCard(title: "Food", icon: "fork.knife") {
                            if mealLogs.isEmpty {
                                EmptyDiaryText(text: "No meals logged for this day yet.")
                            } else {
                                VStack(spacing: 10) {
                                    Text("\(mealCount) of 3 meals logged.")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#4E788D"))
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    ForEach(mealLogs) { log in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(log.timeText)
                                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                                .foregroundColor(Color(hex: "#4E788D"))

                                            Text(log.aiDescription)
                                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                                .foregroundColor(.gray)

                                            if !log.userDescription.isEmpty {
                                                Text("Note: \(log.userDescription)")
                                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                                    .foregroundColor(.gray)
                                                    .italic()
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(12)
                                        .background(Color(hex: "#CBE8EE"))
                                        .cornerRadius(16)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            selectedDayKey = DailyDataStore.activeDayKey(simulationDayOffset)
            digestText = DailyDataStore.loadDigest(dayKey: selectedDayKey)
        }
        .onReceive(NotificationCenter.default.publisher(for: .digestDidUpdate)) { note in
            guard let updatedDayKey = note.userInfo?["dayKey"] as? String, updatedDayKey == selectedDayKey else {
                return
            }
            digestText = DailyDataStore.loadDigest(dayKey: selectedDayKey)
        }
    }
}

struct DiarySummaryCard: View {
    let mealCount: Int
    let moodCount: Int
    let activityCount: Int
    
    var body: some View {
        HStack(spacing: 10) {
            DiaryMiniStat(title: "Meals", value: "\(mealCount)/3", icon: "fork.knife")
            DiaryMiniStat(title: "Moods", value: "\(moodCount)/3", icon: "heart.fill")
            DiaryMiniStat(title: "Activity", value: "\(activityCount)", icon: "figure.run")
        }
    }
}

struct DiaryMiniStat: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Color(hex: "#77A4B3"))
            
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#4E788D"))
            
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 95)
        .background(Color(hex: "#F8F4EF"))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "#CBE8EE"), lineWidth: 2)
        )
    }
}

struct DiarySectionCard<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 9) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(hex: "#77A4B3"))
                
                Text(title)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundColor(Color(hex: "#4E788D"))
            }
            
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color(hex: "#F8F4EF"))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color(hex: "#CBE8EE"), lineWidth: 2)
        )
    }
}

struct EmptyDiaryText: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold, design: .rounded))
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        DiaryView()
    }
}


import Foundation

enum DigestError: LocalizedError {
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The AI didn't send back a digest. Try again."
        case .server(let message):
            return "Couldn't reach the AI: \(message)"
        }
    }
}

struct DigestService {
    static let baseURL = FoodScanService.baseURL

    static var model = FoodScanService.model

    static func generateDigest(
        foodLogs: [MealLogEntry],
        moodLogs: [MoodLogEntry],
        activityLogs: [ActivityLogEntry],
        glucoseLogs: [GlucoseLogEntry]
    ) async throws -> String {
        let systemPrompt = buildSystemPrompt()
        let userPrompt = buildUserPrompt(
            foodLogs: foodLogs,
            moodLogs: moodLogs,
            activityLogs: activityLogs,
            glucoseLogs: glucoseLogs
        )

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userPrompt]
            ],
            "max_tokens": 1500,
            "chat_template_kwargs": ["enable_thinking": false]
        ]

        guard let url = URL(string: "\(baseURL)/v1/chat/completions") else {
            throw DigestError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        request.timeoutInterval = 240

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw DigestError.server(message)
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any]
        else {
            throw DigestError.invalidResponse
        }

        let content = (message["content"] as? String) ?? ""
        if !content.isEmpty {
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }

       
        if let reasoning = message["reasoning_content"] as? String,
           let finished = extractFinishedDraft(fromReasoning: reasoning) {
            return finished
        }

        throw DigestError.invalidResponse
    }

    private static let requiredClosingLine = "This is only a pattern summary, not medical advice."

    private static func extractFinishedDraft(fromReasoning reasoning: String) -> String? {
        
        guard let markerRange = reasoning.range(of: requiredClosingLine, options: .backwards) else {
            return nil
        }

        let textUpToMarkerEnd = reasoning[..<markerRange.upperBound]

        let paragraphStart = textUpToMarkerEnd.range(of: "\n\n", options: .backwards)?.upperBound
            ?? textUpToMarkerEnd.startIndex

        var candidate = String(textUpToMarkerEnd[paragraphStart...])
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let colonIndex = candidate.firstIndex(of: ":"),
           candidate.distance(from: candidate.startIndex, to: colonIndex) < 24 {
            let label = candidate[candidate.startIndex..<colonIndex].lowercased()
            if label.contains("draft") || label.contains("final") || label.contains("version") || label.contains("polish") {
                candidate = String(candidate[candidate.index(after: colonIndex)...])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
            }

        guard candidate.count < 900, candidate.hasSuffix(requiredClosingLine) else {
            return nil
        }

        return candidate
    }

    private static func buildSystemPrompt() -> String {
        """
        You are writing a Daily Digest for SugarPal, a diabetes companion app for kids and teens.
        Use the child's food, mood, activity, and glucose logs from today to write a helpful, kid-friendly pattern summary.

        Content requirements:
        - You MUST reference every category below that has at least one entry today (food, mood, activity, glucose). Do not skip food, or any other category, just because another category seems more notable — mention all of them.
        - Don't just list what happened — connect the dots. For at least one pattern you notice, briefly explain a possible "why" behind it (e.g. why a big activity, a specific food, or a mood might relate to how they felt or their glucose reading).
        - Include one gentle, practical, non-medical tip the child could try (e.g. about timing, resting, hydration, or logging habits) — never a dosing, insulin, carb-counting, or treatment tip.
        - If something looks concerning or repeated, say specifically what stood out and suggest showing a parent or diabetes care team — don't just tack on a generic "talk to someone" line.

        Tone and safety rules:
        - Never shame the child or call any food "bad."
        - Never give insulin advice, dosing advice, diagnosis, carb counting, or treatment instructions.
        - Never say a food is safe or unsafe.
        - Use words like "may," "might," "could," and "worth noticing" instead of definite medical claims.
        - Keep the tone warm, encouraging, and age-appropriate.

        Format:
        - Write 4-6 short sentences — this is shown in a popup, not a full page, so stay concise but cover food, the "why," and the tip.
        - End with exactly this sentence: "This is only a pattern summary, not medical advice."

        Respond with ONLY the finished digest text. Do not include reasoning, notes, drafts, or restate these instructions.
        """
    }

    private static func buildUserPrompt(
        foodLogs: [MealLogEntry],
        moodLogs: [MoodLogEntry],
        activityLogs: [ActivityLogEntry],
        glucoseLogs: [GlucoseLogEntry]
    ) -> String {
        let foodText = foodLogs.isEmpty
            ? "None logged today."
            : foodLogs.map { log in
                let note = log.userDescription.trimmingCharacters(in: .whitespacesAndNewlines)
                let suffix = note.isEmpty ? "" : " (note: \(note))"
                return "- \(log.timeText): \(log.aiDescription)\(suffix)"
            }.joined(separator: "\n")

        let moodText = moodLogs.isEmpty
            ? "None logged today."
            : moodLogs.map { log in
                let parts = [log.moods.joined(separator: ", "), log.typedMood].filter { !$0.isEmpty }
                return "- \(log.timeText): \(parts.joined(separator: " — "))"
            }.joined(separator: "\n")

        let activityText = activityLogs.isEmpty
            ? "None logged today."
            : activityLogs.map { log in
                let parts = [log.activities.joined(separator: ", "), log.typedActivity].filter { !$0.isEmpty }
                return "- \(log.timeText) (\(log.durationMinutes) min): \(parts.joined(separator: " — "))"
            }.joined(separator: "\n")

        let glucoseText = glucoseLogs.isEmpty
            ? "None logged today."
            : glucoseLogs.map { "- \($0.timeText): \($0.level) (\(GlucoseRange.text(for: $0.level)))" }.joined(separator: "\n")

        return """
        Today's data:
        Food logs:
        \(foodText)

        Mood logs:
        \(moodText)

        Activity logs:
        \(activityText)

        Glucose logs:
        \(glucoseText)

        Write the Daily Digest now — cover food, mood, activity, and glucose if any of them have entries above, explain a possible "why," and include one tip. Just the digest text, nothing else.
        """
    }
}

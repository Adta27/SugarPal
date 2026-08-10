//
//  FoodScanService.swift
//  SugarPalNEW
//
//  Sends a food photo (and optional note) to a local LM Studio server for identification.
//

import UIKit

enum FoodScanError: LocalizedError {
    case invalidImage
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "Couldn't read the photo."
        case .invalidResponse:
            return "The AI didn't send back a description. Try again."
        case .server(let message):
            return "Couldn't reach the AI: \(message)"
        }
    }
}

struct FoodScanService {
    // Your Mac's LAN IP running LM Studio's local server
    static let baseURL = "http://192.168.2.16:1234"

    //Must match the model identifier shown in LM Studio's server tab exactly.
    static let model = "google/gemma-4-12b-qat"

    static func analyzeFood(image: UIImage, userNote: String = "") async throws -> String {
        guard let jpegData = image.jpegData(compressionQuality: 0.7) else {
            throw FoodScanError.invalidImage
        }
        let base64 = jpegData.base64EncodedString()

        var prompt = "What food is in this image? Identify it and briefly describe it in 1-2 sentences."
        let trimmedNote = userNote.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedNote.isEmpty {
            prompt += " The person logging this meal added this note: \"\(trimmedNote)\". Factor it into your description."
        }

        let body: [String: Any] = [
            "model": model,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(base64)"]]
                    ]
                ]
            ],
            "max_tokens": 1200
        ]

        guard let url = URL(string: "\(baseURL)/v1/chat/completions") else {
            throw FoodScanError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw FoodScanError.server(message)
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let message = choices.first?["message"] as? [String: Any]
        else {
            throw FoodScanError.invalidResponse
        }

        let content = (message["content"] as? String) ?? ""
        if !content.isEmpty {
            return content
        }

      
        if let reasoning = message["reasoning_content"] as? String, !reasoning.isEmpty {
            return reasoning
        }

        throw FoodScanError.invalidResponse
    }
}

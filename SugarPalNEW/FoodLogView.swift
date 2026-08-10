
import SwiftUI
import UIKit

struct FoodLogView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("simulationDayOffset") private var simulationDayOffset = 0
    @AppStorage("palXP") private var palXP = 80
    @AppStorage("palLevel") private var palLevel = 1

    @State private var selectedImage: UIImage?
    @State private var showPicker = false
    @State private var pickerSource: UIImagePickerController.SourceType = .camera
    @State private var userNote = ""
    @State private var isLoading = false
    @State private var errorText: String?
    @State private var savedDescription: String?
    @State private var earnedXP: Int?

    var dayKey: String {
        DailyDataStore.activeDayKey(simulationDayOffset)
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

                    Text("Log Food")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))

                    Spacer()

                    Image(systemName: "fork.knife")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "#77A4B3"))
                }
                .padding(.horizontal, 28)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        Text("Take a photo of your food and your AI pal will figure out what it is!")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.top, 10)

                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 280, height: 220)
                                .clipped()
                                .cornerRadius(22)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 22)
                                .fill(Color(hex: "#F8F4EF"))
                                .frame(width: 280, height: 220)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(Color(hex: "#CBE8EE"), lineWidth: 3)
                                )
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 36, weight: .bold))
                                            .foregroundColor(Color(hex: "#77A4B3"))
                                        Text("No photo yet")
                                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                                            .foregroundColor(.gray)
                                    }
                                )
                        }

                        HStack(spacing: 14) {
                            Button {
                                pickerSource = .camera
                                showPicker = true
                            } label: {
                                Label("Take Photo", systemImage: "camera.fill")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(width: 155, height: 46)
                                    .background(Color(hex: "#77A4B3"))
                                    .cornerRadius(18)
                            }
                            .buttonStyle(.plain)
                            .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
                            .opacity(UIImagePickerController.isSourceTypeAvailable(.camera) ? 1 : 0.4)

                            Button {
                                pickerSource = .photoLibrary
                                showPicker = true
                            } label: {
                                Label("Camera Roll", systemImage: "photo.fill")
                                    .font(.system(size: 15, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4E788D"))
                                    .frame(width: 155, height: 46)
                                    .background(Color(hex: "#CBE8EE"))
                                    .cornerRadius(18)
                            }
                            .buttonStyle(.plain)
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Describe your food (optional)")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4E788D"))

                            TextField("Example: half a plate, extra sauce, mixed dish", text: $userNote)
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

                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 14, weight: .bold))
                                Text("Giving a description gives you TRIPLE XP!")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Color(hex: "#E2CDB9"))
                        }
                        .padding(.horizontal, 24)

                        Button {
                            scanAndSave()
                        } label: {
                            Text(isLoading ? "Scanning..." : "Scan & Save")
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(selectedImage == nil || isLoading ? Color.gray.opacity(0.4) : Color(hex: "#77A4B3"))
                                .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                        .disabled(selectedImage == nil || isLoading)
                        .padding(.horizontal, 24)

                        if isLoading {
                            ProgressView()
                        }

                        if let errorText {
                            Text(errorText)
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 24)
                        }

                        if let savedDescription {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(hex: "#77A4B3"))

                                    Text("Saved to your diary!")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundColor(Color(hex: "#4E788D"))

                                    if let earnedXP {
                                        Text("+\(earnedXP) XP")
                                            .font(.system(size: 15, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color(hex: "#E2CDB9"))
                                            .cornerRadius(12)
                                    }
                                }

                                Text(savedDescription)
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.leading)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(18)
                            .background(Color(hex: "#F8F4EF"))
                            .cornerRadius(22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 22)
                                    .stroke(Color(hex: "#CBE8EE"), lineWidth: 2)
                            )
                            .padding(.horizontal, 24)

                            Button {
                                resetForAnother()
                            } label: {
                                Text("Log Another Meal")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#4E788D"))
                                    .frame(width: 220, height: 46)
                                    .background(Color.white)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        Spacer(minLength: 20)
                    }
                    .padding(.top, 6)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showPicker) {
            ImagePicker(sourceType: pickerSource, image: $selectedImage)
        }
    }

    private func scanAndSave() {
        guard let selectedImage else { return }
        isLoading = true
        errorText = nil

        Task {
            do {
                let description = try await FoodScanService.analyzeFood(image: selectedImage, userNote: userNote)
                await MainActor.run {
                    finishLogging(description: description)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorText = error.localizedDescription
                }
            }
        }
    }

    private func finishLogging(description: String) {
        let trimmedNote = userNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let mealCountBefore = DailyDataStore.loadMealCount(dayKey: dayKey)

        DailyDataStore.addMealLog(dayKey: dayKey, aiDescription: description, userDescription: trimmedNote)

        var xpGained = 0
        if mealCountBefore < 3 {
            xpGained = trimmedNote.isEmpty ? 5 : 15
            addXP(xpGained)
        }

        isLoading = false
        savedDescription = description
        earnedXP = xpGained > 0 ? xpGained : nil
    }

    private func addXP(_ amount: Int) {
        palXP += amount
        while palXP >= palLevel * 100 {
            palXP -= palLevel * 100
            palLevel += 1
        }
    }

    private func resetForAnother() {
        selectedImage = nil
        userNote = ""
        savedDescription = nil
        earnedXP = nil
        errorText = nil
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        FoodLogView()
    }
}

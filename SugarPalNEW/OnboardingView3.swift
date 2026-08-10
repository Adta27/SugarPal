import SwiftUI

struct OnboardingView3: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("rewardAmount") private var rewardAmount = ""
    @AppStorage("rewardItem") private var rewardItem = ""
    @AppStorage("levelGoal") private var levelGoal = 2
    
    @AppStorage("morningEnabled") private var morningEnabled = true
    @AppStorage("schoolEnabled") private var schoolEnabled = true
    @AppStorage("eveningEnabled") private var eveningEnabled = true
    
    @State private var morningTime = Date()
    @State private var schoolTime = Date()
    @State private var eveningTime = Date()
    
    var body: some View {
        ZStack {
            Color(hex: "#D3EAEE")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // FIXED TOP ROW ONLY
                ZStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "arrowshape.turn.up.left.fill")
                                .font(.system(size: 37, weight: .bold))
                                .foregroundColor(Color(hex: "#4E788D"))
                                .frame(width: 55, height: 55)
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 21)
                    
                    Image("sugarpalLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230)
                }
                .padding(.top, 0)
                
                // EVERYTHING BELOW SCROLLS
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Text("Parental Settings")
                            .font(.custom("Roboto-Black", size: 33))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .padding(.top, 5)
                        
                        Text("Set rewards and check in times around\nyour child’s school schedule.")
                            .font(.custom("Roboto-Regular", size: 21))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .padding(.horizontal, 15)
                            .padding(.top, 10)
                        
                        // Reward Amount
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reward Amount")
                                .font(.custom("Roboto-Black", size: 25))
                                .foregroundColor(Color(hex: "#4E788D"))
                            
                            HStack(spacing: 12) {
                                Text("$")
                                    .font(.system(size: 38, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(hex: "#77A4B3"))
                                
                                TextField("Enter amount", text: $rewardAmount)
                                    .font(.custom("Roboto-Regular", size: 24))
                                    .foregroundColor(.black)
                                    .keyboardType(.decimalPad)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 58)
                            .background(Color.white)
                            .cornerRadius(17)
                            .overlay(
                                RoundedRectangle(cornerRadius: 17)
                                    .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 28)
                        
                        // Reward Item
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reward Item")
                                .font(.custom("Roboto-Black", size: 25))
                                .foregroundColor(Color(hex: "#4E788D"))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(Color(hex: "#E2CDB9"))
                                    .frame(width: 34)
                                
                                TextField("Example: toy, book, game", text: $rewardItem)
                                    .font(.custom("Roboto-Regular", size: 22))
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal, 16)
                            .frame(height: 58)
                            .background(Color.white)
                            .cornerRadius(17)
                            .overlay(
                                RoundedRectangle(cornerRadius: 17)
                                    .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 18)
                        
                        // Level Goal
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "flame.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#E2CDB9"))
                                
                                Text("Level Goal")
                                    .font(.custom("Roboto-Black", size: 25))
                                    .foregroundColor(Color(hex: "#4E788D"))
                            }
                            
                            HStack {
                                Button {
                                    if levelGoal > 1 {
                                        levelGoal -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(Color(hex: "#77A4B3"))
                                }
                                .buttonStyle(.plain)
                                
                                Spacer()
                                
                                Text("Level \(levelGoal)")
                                    .font(.custom("Roboto-Black", size: 28))
                                    .foregroundColor(Color(hex: "#4E788D"))
                                
                                Spacer()
                                
                                Button {
                                    if levelGoal < 20 {
                                        levelGoal += 1
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 34, weight: .bold))
                                        .foregroundColor(Color(hex: "#77A4B3"))
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 18)
                            .frame(height: 70)
                            .background(Color.white)
                            .cornerRadius(18)
                            .overlay(
                                RoundedRectangle(cornerRadius: 18)
                                    .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
                            )
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 28)
                        
                        // Notification heading
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#E2CDB9"))
                                
                                Text("Child Notification Times")
                                    .font(.custom("Roboto-Black", size: 24))
                                    .foregroundColor(Color(hex: "#4E788D"))
                            }
                            
                            Text("Choose times that fit school, meals, and bedtime")
                                .font(.custom("Roboto-Regular", size: 19))
                                .foregroundColor(Color(hex: "#4E788D"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .padding(.top, 30)
                        
                        VStack(spacing: 16) {
                            NotificationTimeCard(
                                title: "Morning",
                                icon: "sunrise.fill",
                                time: $morningTime,
                                isOn: $morningEnabled
                            )
                            
                            NotificationTimeCard(
                                title: "Afternoon",
                                icon: "backpack.fill",
                                time: $schoolTime,
                                isOn: $schoolEnabled
                            )
                            
                            NotificationTimeCard(
                                title: "Evening",
                                icon: "moon.zzz.fill",
                                time: $eveningTime,
                                isOn: $eveningEnabled
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        
                        NavigationLink(destination: MainView()) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(hex: "#77A4B3"))
                                    .frame(width: 340, height: 62)
                                
                                Text("Finish")
                                    .font(.system(size: 27, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Image("flower1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 52)
                                    .offset(x: -158, y: -24)
                            }
                        }
                        .padding(.top, 36)
                        
                        Text("3-3")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 12)
                            .padding(.bottom, 25)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// NOTIFICATION TIME CARD
struct NotificationTimeCard: View {
    let title: String
    let icon: String
    @Binding var time: Date
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 25, weight: .bold))
                        .foregroundColor(Color(hex: "#77A4B3"))
                    
                    Text(title)
                        .font(.custom("Roboto-Black", size: 22))
                        .foregroundColor(.black)
                }
                
                Spacer()
                
                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .scaleEffect(0.75)
            }
            
            HStack {
                Spacer()
                
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .scaleEffect(0.9)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(width: 340, height: 100)
        .background(Color.white)
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
        )
    }
}

#Preview {
    NavigationStack {
        OnboardingView3()
    }
}

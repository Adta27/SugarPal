import SwiftUI

struct OnboardingView2: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("selectedActivities") private var selectedActivitiesText = ""
    @AppStorage("otherActivity") private var otherActivity = ""
    
    @State private var selectedActivities: Set<String> = ["Soccer", "Basketball", "Swimming"]
    
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
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(Color(hex: "#4E788D"))
                        }
                        .buttonStyle(.plain)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 28)
                    
                    Image("sugarpalLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 230)
                }
                .padding(.top, 0)
                
                // EVERYTHING BELOW SCROLLS
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        
                        Text("What do you do often?")
                            .font(.custom("Roboto-Black", size: 31))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .padding(.top, 18)
                        
                        Text("Pick common activities so you can log\nthem faster")
                            .font(.custom("Roboto-Regular", size: 22))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .multilineTextAlignment(.center)
                            .lineSpacing(5)
                            .padding(.top, 8)
                        
                        VStack(spacing: 26) {
                            
                            HStack(spacing: 28) {
                                ActivityCard(title: "Soccer", icon: "soccerball", isSelected: selectedActivities.contains("Soccer")) {
                                    toggleActivity("Soccer")
                                }
                                
                                ActivityCard(title: "Basketball", icon: "basketball.fill", isSelected: selectedActivities.contains("Basketball")) {
                                    toggleActivity("Basketball")
                                }
                                
                                ActivityCard(title: "Swimming", icon: "figure.pool.swim", isSelected: selectedActivities.contains("Swimming")) {
                                    toggleActivity("Swimming")
                                }
                            }
                            
                            HStack(spacing: 28) {
                                ActivityCard(title: "Running", icon: "figure.run", isSelected: selectedActivities.contains("Running")) {
                                    toggleActivity("Running")
                                }
                                
                                ActivityCard(title: "Gym", icon: "figure.strengthtraining.traditional", isSelected: selectedActivities.contains("Gym")) {
                                    toggleActivity("Gym")
                                }
                                
                                ActivityCard(title: "Biking", icon: "bicycle", isSelected: selectedActivities.contains("Biking")) {
                                    toggleActivity("Biking")
                                }
                            }
                            
                            HStack(spacing: 28) {
                                ActivityCard(title: "Rest", icon: "bed.double.fill", isSelected: selectedActivities.contains("Rest")) {
                                    toggleActivity("Rest")
                                }
                                
                                ActivityCard(title: "Sick", icon: "cross.case.fill", isSelected: selectedActivities.contains("Sick")) {
                                    toggleActivity("Sick")
                                }
                                
                                ActivityCard(title: "PE", icon: "building.columns.fill", isSelected: selectedActivities.contains("PE")) {
                                    toggleActivity("PE")
                                }
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 22)
                        .background(Color.white.opacity(0.82))
                        .cornerRadius(28)
                        .padding(.horizontal, 22)
                        .padding(.top, 22)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Other")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(Color(hex: "#4E788D"))
                            
                            TextField("Enter here", text: $otherActivity)
                                .font(.custom("Roboto-Regular", size: 25))
                                .foregroundColor(.black)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                                .frame(height: 52)
                                .background(Color.white)
                                .cornerRadius(18)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color(hex: "#0F5D7A"), lineWidth: 2)
                                )
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 12)
                        
                        Text("\(selectedActivities.count) Selected")
                            .font(.custom("Roboto-Bold", size: 25))
                            .foregroundColor(.gray)
                            .padding(.top, 22)
                        
                        NavigationLink(destination: OnboardingView3()) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(hex: "#77A4B3"))
                                    .frame(width: 340, height: 62)
                                
                                Text("Continue")
                                    .font(.system(size: 27, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Image("flower1")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 52)
                                    .offset(x: -158, y: -24)
                            }
                        }
                        .padding(.top, 28)
                        
                        Text("2-3")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 12)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            if selectedActivitiesText.isEmpty {
                selectedActivitiesText = selectedActivities.sorted().joined(separator: ",")
            } else {
                selectedActivities = Set(
                    selectedActivitiesText
                        .split(separator: ",")
                        .map { String($0) }
                )
            }
        }
    }
    
    func toggleActivity(_ activity: String) {
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
        
        selectedActivitiesText = selectedActivities.sorted().joined(separator: ",")
    }
}

// ACTIVITY CARD
struct ActivityCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .frame(width: 96, height: 110)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(hex: "#0F5D7A"), lineWidth: 2)
                    )
                
                Circle()
                    .fill(isSelected ? Color(hex: "#8EF2C8") : Color.gray.opacity(0.25))
                    .frame(width: 13, height: 13)
                    .padding(.leading, 9)
                    .padding(.top, 9)
                
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color(hex: "#E7CDB9"))
                        .frame(height: 44)
                        .opacity(isSelected ? 1.0 : 0.95)
                    
                    Text(title)
                        .font(.custom("Roboto-Black", size: 16))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                .frame(width: 96, height: 110)
                .padding(.top, 8)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        OnboardingView2()
    }
}

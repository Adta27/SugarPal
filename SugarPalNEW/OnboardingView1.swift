import SwiftUI

struct OnboardingView1: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("childName") private var childName = ""
    @AppStorage("childAge") private var childAge = ""
    @AppStorage("cgmAppID") private var cgmAppID = ""
    @AppStorage("parentEmail") private var parentEmail = ""
    
    var body: some View {
        ZStack {
            Color(hex: "#D3EAEE")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
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
                        
                        Text("Set Up Your SugarPal")
                            .font(.custom("Roboto-Black", size: 28))
                            .foregroundColor(Color(hex: "#4E788D"))
                            .padding(.top, 18)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            
                            OnboardingTextField(
                                title: "Name",
                                placeholder: "Enter your name",
                                icon: "person.fill",
                                text: $childName
                            )
                            
                            OnboardingTextField(
                                title: "Age",
                                placeholder: "Enter your age",
                                icon: "birthday.cake.fill",
                                text: $childAge
                            )
                            .keyboardType(.numberPad)
                            
                            OnboardingTextField(
                                title: "CGM App ID",
                                placeholder: "Example: CGM12345",
                                icon: "iphone",
                                text: $cgmAppID
                            )
                            
                            OnboardingTextField(
                                title: "Parent Email",
                                placeholder: "Enter parent email",
                                icon: "person.2.fill",
                                text: $parentEmail
                            )
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        }
                        .padding(.horizontal, 32)
                        .padding(.top, 25)
                        
                        Image("onboardingPicture")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 235)
                            .padding(.top, 18)
                        
                        NavigationLink(destination: OnboardingView2()) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(Color(hex: "#77A4B3"))
                                    .frame(width: 340, height: 58)
                                
                                Text("Continue")
                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Image("flower2")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .offset(x: 158, y: -24)
                            }
                        }
                        .padding(.top, 18)
                        
                        Text("1-3")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(.gray)
                            .padding(.top, 10)
                            .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// FUNCTION FOR TEXTFIELDS
struct OnboardingTextField: View {
    let title: String
    let placeholder: String
    let icon: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .foregroundColor(Color(hex: "#4E788D"))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 21, weight: .bold))
                    .foregroundColor(Color(hex: "#E2CDB9"))
                    .frame(width: 28)
                
                TextField(placeholder, text: $text)
                    .font(.custom("Roboto-Regular", size: 17))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 16)
            .frame(height: 47)
            .background(Color.white)
            .cornerRadius(17)
            .overlay(
                RoundedRectangle(cornerRadius: 17)
                    .stroke(Color(hex: "#77A4B3"), lineWidth: 2)
            )
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingView1()
    }
}

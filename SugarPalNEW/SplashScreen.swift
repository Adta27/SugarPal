import SwiftUI

struct SplashScreen: View {
    @State private var bounceHeart = false
    
    var body: some View {
        GeometryReader { geo in
            let logoWidth = min(geo.size.width * 0.88, 390)
            let buttonWidth = min(geo.size.width * 0.82, 340)
            
            ZStack {
                Color(hex: "#CEE5EA")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    
                    Spacer()
                    
                    ZStack {
                        Image("sugarpalLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: logoWidth)
                            .offset(y: 25)
                        
                        Image("sugarpalChar")
                            .resizable()
                            .scaledToFit()
                            .frame(width: logoWidth * 0.34)
                            .offset(y: -72)
                            .offset(y: bounceHeart ? -6 : 6)
                    }
                    .frame(width: geo.size.width, height: 230)
                    
                    Text("Track your day. Learn your patterns. Grow your pal.")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(hex: "#4E788D"))
                        .multilineTextAlignment(.center)
                        .frame(width: min(geo.size.width * 0.78, 300))
                        .offset(y: -25)
                    
                    Spacer()
                    
                    NavigationLink(destination: OnboardingView1()) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color(hex: "#77A4B3"))
                                .frame(width: buttonWidth, height: 56)

                            Text("Get Started")
                                .font(.system(size: 23, weight: .bold, design: .rounded))
                                .foregroundColor(.white)

                            Image("flower1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55)
                                .offset(x: -buttonWidth / 2 + 15, y: 22)

                            Image("flower2")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 55)
                                .offset(x: buttonWidth / 2 - 15, y: -25)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 35)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
        }
        .onAppear {
            bounceHeart = false
            
            withAnimation(
                .easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                bounceHeart = true
            }
        }
    }
}

#Preview {
    NavigationStack {
        SplashScreen()
    }
}

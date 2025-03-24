import SwiftUI

struct JoinCreateSlider: View {
    let screenHeight = UIScreen.main.bounds.height
    let screenWidth = UIScreen.main.bounds.width
    
    var onJoinTap: () -> Void
    var onCreateTap: () -> Void
    
    var body: some View {
        VStack {
          
          
            HStack(spacing: 40) {
                  
                Button(action: onJoinTap) {
                    VStack {
                        Image("joingroup")
                            .resizable()
                            .frame(width: 75, height: 75)
                        Text("Join Group")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.white)
                    }
                }
                
                Button(action: onCreateTap) {
                    VStack {
                        Image("creategroup")
                            .resizable()
                            .frame(width: 75, height: 75)
                        Text("Create Group")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .frame(width: screenWidth, height: screenHeight * 0.3)
        .background(Color("Secondary"))
        
    }
}

#Preview {
    JoinCreateSlider(
        onJoinTap: { print("Join Group Tapped") },
        onCreateTap: { print("Create Group Tapped") }
    )
}


//
//  SmallWidgetView.swift
//  VITTY
//
//  Created by Ananya George on 2/26/22.
//

import SwiftUI

struct SmallWidgetView: View {
    var widgetData: VITTYWidgetDataModel
    var body: some View {
        VStack {
            ZStack {
                if widgetData.classesCompleted < widgetData.classInfo.count && widgetData.error == nil {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.secGrad)
                        WidgetSmallClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                    }
                    .padding(5)
                }
                else {
                    VStack {
                        Text("No more class today!")
                            .font(Font.custom("Poppins-Bold", size: 24))
                        Text(RemoteConfigManager.sharedInstance.onlineMode
                             ? StringConstants.noClassQuotesOnline.randomElement() ?? "Have fun today!" : StringConstants.noClassQuotesOffline.randomElement() ?? "Have fun today!")
                            .font(Font.custom("Poppins-Regular",size:20))
                    }
                    .foregroundColor(Color.white)
                }
                
            }
        }
        .background(Color.widgbg).edgesIgnoringSafeArea(.all)
    }
}

//struct SmallWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        SmallWidgetView()
//    }
//}

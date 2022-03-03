//
//  LargeWidgetView.swift
//  VITTY
//
//  Created by Ananya George on 2/26/22.
//

import SwiftUI

struct LargeWidgetView: View {
    var widgetData: VITTYWidgetDataModel
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if widgetData.classesCompleted < widgetData.classInfo.count && widgetData.error == nil {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Your next class")
                        .font(Font.custom("Poppins-Regular",size:14))
                        .foregroundColor(Color.vprimary)
                        .padding(.leading, 10)
                        .padding(.top, 5)
                        .padding(.bottom, 4)
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.secGrad)
                        WidgetLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                    }
                    .padding(.horizontal, 3)
                    .padding(.bottom, 8)
                    if widgetData.classesCompleted + 1 < widgetData.classInfo.count {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkbg)
                            WidgetLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted + 1], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                        }
                        .padding(.horizontal, 3)
                        .padding(.bottom, 8)
                        if widgetData.classesCompleted + 2 < widgetData.classInfo.count {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.darkbg)
                                WidgetLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted + 2], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                            }
                            .padding(.horizontal, 3)
                            .padding(.bottom, 5)
                        } else {
                            Spacer()
                        }
                    } else {
                        Spacer()
                    }
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.darkbg)
                    VStack {
                        Text("No more class today!")
                            .font(Font.custom("Poppins-Bold", size: 15))
                        Text(RemoteConfigManager.sharedInstance.onlineMode
                             ? StringConstants.noClassQuotesOnline.randomElement() ?? "Have fun today!" : StringConstants.noClassQuotesOffline.randomElement() ?? "Have fun today!")
                            .font(Font.custom("Poppins-Regular",size:12))
                    }
                    .foregroundColor(Color.white)
                }
            }
        }
        .padding(5)
        .background(Color.widgbg)
    }
}

//struct LargeWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargeWidgetView()
//    }
//}

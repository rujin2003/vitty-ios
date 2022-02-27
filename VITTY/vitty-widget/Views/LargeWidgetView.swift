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
        VStack {
            VStack {
                if widgetData.classesCompleted < widgetData.classInfo.count && widgetData.error == nil {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient.secGrad)
                        WidgetMLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                    }
                    .padding(3)
                    if widgetData.classesCompleted + 1 < widgetData.classInfo.count {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.darkbg)
                            WidgetMLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted + 1], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                        }
                        .padding(3)
                        if widgetData.classesCompleted + 2 < widgetData.classInfo.count {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.darkbg)
                                WidgetMLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted + 2], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                            }
                            .padding(3)
                            if widgetData.classesCompleted + 3 < widgetData.classInfo.count {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.darkbg)
                                    WidgetMLClassCard(classInfo: widgetData.classInfo[widgetData.classesCompleted + 3], onlineMode: RemoteConfigManager.sharedInstance.onlineMode)
                                }
                                .padding(3)
                            } else {
                                Spacer()
                            }
                        } else {
                            Spacer()
                        }
                    } else {
                        Spacer()
                    }
                } else {
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
            .padding(5)
        }
        .background(Color.widgbg)
    }
}

//struct LargeWidgetView_Previews: PreviewProvider {
//    static var previews: some View {
//        LargeWidgetView()
//    }
//}

//
//  TimeTableView.swift
//  VITTY
//
//  Created by Chandram Dutta on 09/02/24.
//

import OSLog
import SwiftData
import SwiftUI

struct TimeTableView: View {
	@Environment(AuthViewModel.self) private var authViewModel
	private let daysOfWeek = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

	@State private var viewModel = TimeTableViewModel()
	@State private var selectedLecture: Lecture? = nil

	let friend: Friend?

	private let logger = Logger(
		subsystem: Bundle.main.bundleIdentifier!,
		category: String(
			describing: TimeTableView.self
		)
	)

	var body: some View {
		NavigationStack {
			ZStack {
				BackgroundView()
				switch viewModel.stage {
					case .loading:
						VStack {
							Spacer()
							ProgressView()
							Spacer()
						}
					case .error:
						VStack {
							Spacer()
							Text("It's an error!")
								.font(Font.custom("Poppins-Bold", size: 24))
							Text("Sorry if you are late for your class!")
							Spacer()
						}
					case .data:
						VStack(spacing: 0) {
							ScrollView(.horizontal) {
								HStack {
									ForEach(daysOfWeek, id: \.self) { day in
										Text(day)
											.foregroundStyle(daysOfWeek[viewModel.dayNo] == day
															 ? Color("Background") : Color("Accent"))
											.frame(width: 60, height: 54)
											.background(
												daysOfWeek[viewModel.dayNo] == day
													? Color("Accent") : Color.clear
											)
											.onTapGesture {
												withAnimation {
													viewModel.dayNo = daysOfWeek.firstIndex(
														of: day
													)!
													viewModel.changeDay()
												}
											}
											.clipShape(RoundedRectangle(cornerRadius: 10))
									}
								}
							}
							.scrollIndicators(.hidden)
							.background(Color("Secondary"))
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.padding(.horizontal)
							if viewModel.lectures == [] {
								Spacer()
								Text("No classes today!")
									.font(Font.custom("Poppins-Bold", size: 24))
								Text(StringConstants.noClassQuotesOffline.randomElement()!)
							}
							else {
								List(viewModel.lectures.sorted()) { lecture in
									VStack(alignment: .leading) {
										Text(lecture.name)
											.font(.headline)
										HStack {
											Text(
												"\(formatTime(time: lecture.startTime)) - \(formatTime(time: lecture.endTime))"
											)
											Spacer()
											Text("\(lecture.venue)")
										}
										.foregroundColor(Color("Accent"))
										.font(.caption)
									}
									.onTapGesture {
										selectedLecture = lecture
									}
									.padding(.bottom)
									.listRowBackground(
										RoundedRectangle(cornerRadius: 15)
											.fill(Color("Secondary"))
											.padding(.bottom)
									)
									.listRowSeparator(.hidden)
								}
                                .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: 100, trailing: 0))
								.sheet(item: $selectedLecture) { lecture in
									LectureDetailView(lecture: lecture)
								}
								.scrollContentBackground(.hidden)
							}
							Spacer()
						}
				}

			}
			.navigationTitle(friend?.name ?? "Schedule")
			.toolbar {
				Menu {
					if friend == nil {
						NavigationLink {
							SettingsView()
						} label: {
							Label("Settings", systemImage: "gear")
						}
						Button(role: .destructive) {
							authViewModel.signOut()
						} label: {
							Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
						}
					}
					else {
						Button {
							let url = URL(
								string:
									"\(APIConstants.base_url)/api/v2/friends/\(friend?.username ?? "")"
							)!
							var request = URLRequest(url: url)
							request.httpMethod = "DELETE"
							request.addValue(
								"Token \(authViewModel.loggedInBackendUser?.token ?? "")",
								forHTTPHeaderField: "Authorization"
							)
							let task = URLSession.shared.dataTask(with: request) {
								(data, response, error) in
								if let error = error {
									logger.error("\(error.localizedDescription)")
									return
								}
							}
							task.resume()
						} label: {
							Label("Unfriend", systemImage: "person.fill.xmark")
						}
					}
				} label: {
					UserImage(
						url: friend?.picture ?? (authViewModel.loggedInBackendUser?.picture ?? ""),
						height: 30,
						width: 40
					)
				}
			}
		}
		.onAppear {
			Task {
				await viewModel.fetchTimeTable(
					username: friend?.username
						?? (authViewModel.loggedInBackendUser?.username ?? ""),
					authToken: authViewModel.loggedInBackendUser?.token ?? ""
				)
			}
		}
	}

	private func formatTime(time: String) -> String {
		var timeComponents = time.components(separatedBy: "T").last ?? ""
		timeComponents = timeComponents.components(separatedBy: "Z").first ?? ""

		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "HH:mm:ss"
		if let date = dateFormatter.date(from: timeComponents) {
			dateFormatter.dateFormat = "h:mm a"
			let formattedTime = dateFormatter.string(from: date)
			return (formattedTime)
		}
		else {
			return ("Failed to parse the time string.")
		}
	}
}

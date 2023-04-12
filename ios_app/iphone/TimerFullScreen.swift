import SwiftUI
import Combine
import shared

extension View {

    func attachTimerFullScreenView() -> some View {
        modifier(TimerFullScreen__ViewModifier())
    }
}

///
///

private struct TimerFullScreen__ViewModifier: ViewModifier {

    @State private var isPresented = false

    private let statePublisher: AnyPublisher<KotlinBoolean, Never> = FullScreenUI.shared.state.toPublisher()

    func body(content: Content) -> some View {

        content
                /// Скрывание status bar в .statusBar(...)
                .fullScreenCover(isPresented: $isPresented) {
                    TimerFullScreen__FullScreenCoverView()
                }
                .onReceive(statePublisher) { newValue in
                    isPresented = newValue.boolValue
                }
    }
}

private struct TimerFullScreen__FullScreenCoverView: View {

    @State private var vm = FullScreenVM()

    var body: some View {

        VMView(vm: vm, stack: .ZStack()) { state in

            Color.black.edgesIgnoringSafeArea(.all)
                    .statusBar(hidden: true)

            VStack(spacing: 0) {

                VStack(spacing: 0) {

                    Button(
                            action: {
                                vm.toggleIsTaskCancelVisible()
                            },
                            label: {
                                Text(state.title)
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                            }
                    )

                    if (state.isTaskCancelVisible) {

                        Button(
                                action: {
                                    vm.cancelTask()
                                },
                                label: {
                                    Text(state.cancelTaskText)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .background(
                                                    RoundedRectangle(cornerRadius: 99, style: .circular)
                                                            .fill(.blue)
                                            )
                                            .padding(.vertical, 12)
                                }
                        )
                    }
                }

                Spacer()
            }

            if let checklistUI = state.checklistUI {
                VStack {
                    TimerFullScreen__TimerView(vm: vm, state: state, isCompact: true)
                            .padding(.top, 20)

                    VStack {
                        ScrollView {
                            ForEach(checklistUI.itemsUI, id: \.item.id) { itemUI in
                                Button(
                                        action: {
                                            itemUI.toggle()
                                        },
                                        label: {
                                            Text(itemUI.item.text + (itemUI.item.isChecked ? "  ✅" : ""))
                                                    .padding(.vertical, 4)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 18))
                                        }
                                )
                            }
                            Spacer()
                        }
                    }
                            .padding(.top, 20)

                    TimerFullScreen__CloseView()
                }
            } else {
                VStack {
                    Spacer()
                    TimerFullScreen__CloseView()
                }
                TimerFullScreen__TimerView(vm: vm, state: state, isCompact: false)
            }
        }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
    }
}

private struct TimerFullScreen__TimerView: View {

    let vm: FullScreenVM
    let state: FullScreenVM.State
    let isCompact: Bool

    var body: some View {

        VStack(spacing: 0) {

            let timerData = state.timerData

            Text(timerData.subtitle ?? "")
                    .font(.system(size: 26, weight: .bold))
                    .tracking(5)
                    .foregroundColor(timerData.subtitleColor.toColor())
                    .opacity(0.9)
                    .padding(.bottom, isCompact ? 5 : 20)

            Text(timerData.title)
                    .font(.system(size: 72, design: .monospaced))
                    .foregroundColor(timerData.titleColor.toColor())
                    .opacity(0.9)

            Button(
                    action: {
                        vm.restart()
                    },
                    label: {
                        Text("Restart")
                                .font(.system(size: 25, weight: .light))
                                .foregroundColor(.white)
                                .tracking(1)
                    }
            )
                    ///
                    .opacity(timerData.title == nil ? 0 : 1)
                    .disabled(timerData.title == nil)
                    ///
                    .padding(.top, isCompact ? 5 : 20)
        }
                .padding(.bottom, 20)
    }
}

private struct TimerFullScreen__CloseView: View {

    var body: some View {

        Button(
                action: {
                    FullScreenUI.shared.close()
                },
                label: {
                    Image(systemName: "xmark")
                            .font(.system(size: 26, weight: .thin))
                            .foregroundColor(.white)
                }
        )
                .padding(.bottom, 30)
                .opacity(0.8)
    }
}

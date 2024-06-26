import SwiftUI
import shared

struct MyListSwipeToActionItem<Content: View>: View {

    var bgColor: Color = c.sheetFg
    let deletionHint: String
    let deletionConfirmationNote: String?
    let onEdit: () -> Void
    let onDelete: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var xSwipeOffset = 0.0
    @State private var width = 999.0
    @State private var itemHeight = 0.0

    var body: some View {

        ZStack(alignment: .bottom) {

            GeometryReader { proxy in
                ZStack {
                }
                        .onAppear {
                            width = proxy.size.width
                        }
                        /// https://stackoverflow.com/a/71380539
                        /// Fix. On scroll by diagonal, sometimes the issue:
                        /// swipe starts to show, but stops on onEnd on DragGesture.
                        .onChange(of: proxy.frame(in: .global).minY) { _ in
                            xSwipeOffset = 0
                        }
            }
                    .frame(height: 1) /// Otherwise short list on full screen

            if (xSwipeOffset > 0) {
                HStack {
                    Text("Edit")
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                    Spacer()
                }
                        .frame(maxHeight: itemHeight)
                        .background(.blue)
                        .offset(x: xSwipeOffset > 0 ? 0 : xSwipeOffset)
            }

            if (xSwipeOffset < 0) {

                HStack {

                    Text(deletionHint)
                            .padding(.leading, 20)
                            .padding(.trailing, 4)
                            .foregroundColor(.white)
                            .lineLimit(1)
                            .font(.system(size: 13, weight: .light))

                    Spacer()

                    Button("Cancel") {
                        xSwipeOffset = 0
                    }
                            .foregroundColor(.white)
                            .padding(.trailing, 12)

                    Button(
                            action: {
                                if let deletionConfirmationNote = deletionConfirmationNote {
                                    Utils_kmpKt.showUiConfirmation(data: UIConfirmationData(
                                            text: deletionConfirmationNote,
                                            buttonText: "Delete",
                                            isRed: true
                                    ) {
                                        withAnimation {
                                            xSwipeOffset = 0
                                            onDelete()
                                        }
                                    })
                                } else {
                                    xSwipeOffset = 0
                                    onDelete()
                                }
                            },
                            label: {
                                Text("Delete")
                                        .fontWeight(.bold)
                                        .padding(.horizontal, 9)
                                        .padding(.vertical, 5)
                                        .foregroundColor(.red)
                            }
                    )
                            .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(.white))
                            .padding(.trailing, 12)
                }
                        .frame(maxHeight: itemHeight)
                        .background(.red)
                        .offset(x: xSwipeOffset < 0 ? 0 : xSwipeOffset)
            }

            content()
                    .background(GeometryReader { geometry -> Color in
                        /// Otherwise "Modifying state during view update, this will cause undefined behavior."
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            itemHeight = geometry.size.height
                        }
                        return bgColor
                    })
                    .highPriorityGesture(gesture)
                    .offset(x: xSwipeOffset)
        }
                .frame(maxWidth: .infinity)
                .animation(Animation.easeOut(duration: 0.25), value: xSwipeOffset)
    }

    private var gesture: some Gesture {
        /// Fix the onChange issue above
        DragGesture(minimumDistance: 15, coordinateSpace: .global)
                .onChanged { value in
                    xSwipeOffset = value.translation.width
                }
                .onEnded { value in
                    if value.translation.width < -80 {
                        xSwipeOffset = width * -1
                    } else if value.translation.width > 60 {
                        xSwipeOffset = 0
                        onEdit()
                    } else {
                        xSwipeOffset = 0
                    }
                }
    }
}

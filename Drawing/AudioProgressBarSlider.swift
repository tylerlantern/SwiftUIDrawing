import SwiftUI

struct AudioProgressBarSlider<V>: View where V: BinaryFloatingPoint, V.Stride: BinaryFloatingPoint {
    @Binding private var value: V
    var onDrag: (() -> Void)?
    private let bounds: ClosedRange<V>
    private let step: V.Stride

    private let length: CGFloat = 25
    private let lineWidth: CGFloat = 2

    @State private var ratio: CGFloat = 0
    @State private var startX: CGFloat? = nil

    init(value: Binding<V>, in bounds: ClosedRange<V>, step: V.Stride = 1, onDrag: (() -> Void)? = nil) {
        _value = value
        self.bounds = bounds
        self.step = step
        self.onDrag = onDrag
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                // MARK: - Track

                RoundedRectangle(cornerRadius: length / 2)
                    .foregroundColor(backgroundSecondaryColor)
                    .frame(height: length * 0.38)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded {
                                onDrag?()
                                updateOnTap(value: $0, proxy: proxy)
                            }
                    )
                RoundedRectangle(cornerRadius: length / 2)
                    .foregroundColor(primaryColor)
                    .frame(width: proxy.size.width * ratio, height: length * 0.38)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onEnded {
                                onDrag?()
                                updateOnTap(value: $0, proxy: proxy)
                            }
                    )
                // MARK: - Thumb

                Circle()
                    .foregroundColor(primaryColor)
                    .frame(width: length, height: length)
                    .offset(x: (proxy.size.width - length) * ratio)
                    .gesture(DragGesture(minimumDistance: 0)
                        .onChanged {
                            updateStatus(value: $0, proxy: proxy)
                            onDrag?()
                        }
                        .onEnded { _ in startX = nil })
            }
            .onChange(of: value, perform: { _ in
                ratio = min(1, max(0, CGFloat(value / bounds.upperBound)))
            })
            .frame(height: length)
            .simultaneousGesture(DragGesture(minimumDistance: 0)
                .onChanged { update(value: $0, proxy: proxy) })
            .onAppear {
                ratio = min(1, max(0, CGFloat(value / bounds.upperBound)))
            }.offset(x: 0, y: proxy.size.height / 2 - length / 2)
        }
    }

    private func updateStatus(value: DragGesture.Value, proxy: GeometryProxy) {
        guard startX == nil else { return }

        let delta = value.startLocation.x - (proxy.size.width - length) * ratio
        startX = (length < value.startLocation.x && delta > 0) ? delta : value.startLocation.x
    }

    private func updateOnTap(value: DragGesture.Value, proxy: GeometryProxy) {
        let ratio = value.location.x / proxy.size.width
        self.ratio = ratio
        self.value = V(bounds.upperBound) * V(self.ratio)
    }

    private func update(value: DragGesture.Value, proxy: GeometryProxy) {
        guard let x = startX else { return }
        startX = min(length, max(0, x))

        var point = value.location.x - x
        let delta = proxy.size.width - length

        // Check the boundary
        if point < 0 {
            startX = value.location.x
            point = 0

        } else if delta < point {
            startX = value.location.x - delta
            point = delta
        }

        // Ratio
        var ratio = point / delta

        // Step
        if step != 1 {
            let unit = CGFloat(step) / CGFloat(bounds.upperBound)

            let remainder = ratio.remainder(dividingBy: unit)
            if remainder != 0 {
                ratio = ratio - CGFloat(remainder)
            }
        }

        self.ratio = ratio
        self.value = V(bounds.upperBound) * V(ratio)
    }
}

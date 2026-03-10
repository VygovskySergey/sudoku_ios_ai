import SwiftUI

struct NumberPadView: View {
    let onNumber: (Int) -> Void
    let onErase: () -> Void
    let isExhausted: (Int) -> Bool

    var body: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 6
            let columns = 10 // 9 numbers + erase
            let totalSpacing = spacing * CGFloat(columns - 1)
            let buttonSize = min((geo.size.width - totalSpacing) / CGFloat(columns), 54)

            HStack(spacing: spacing) {
                ForEach(1...9, id: \.self) { n in
                    numberButton(n, size: buttonSize, exhausted: isExhausted(n))
                }
                eraseButton(size: buttonSize)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 54)
    }

    private func numberButton(_ n: Int, size: CGFloat, exhausted: Bool) -> some View {
        Button { onNumber(n) } label: {
            Text("\(n)")
                .font(.system(size: size * 0.4, weight: .bold))
                .frame(width: size, height: size)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .opacity(exhausted ? 0.25 : 1)
        }
        .foregroundColor(.primary)
        .disabled(exhausted)
    }

    private func eraseButton(size: CGFloat) -> some View {
        Button(action: onErase) {
            Image(systemName: "delete.backward")
                .font(.system(size: size * 0.35))
                .frame(width: size, height: size)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundColor(.primary)
    }
}

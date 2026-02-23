import SwiftUI

struct NumberPadView: View {
    let onNumber: (Int) -> Void
    let onErase: () -> Void

    private let buttonSize: CGFloat = 54

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...9, id: \.self) { n in
                numberButton(n)
            }
            eraseButton
        }
    }

    private func numberButton(_ n: Int) -> some View {
        Button { onNumber(n) } label: {
            Text("\(n)")
                .font(.title2.bold())
                .frame(width: buttonSize, height: buttonSize)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundColor(.primary)
    }

    private var eraseButton: some View {
        Button(action: onErase) {
            Image(systemName: "delete.backward")
                .font(.title3)
                .frame(width: buttonSize, height: buttonSize)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .foregroundColor(.primary)
    }
}

import SwiftUI

// MARK: - Board

struct BoardView: View {
    @ObservedObject var game: SudokuGame
    let onTap: (Int, Int) -> Void

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let cellSize = size / 9

            ZStack(alignment: .topLeading) {
                // Cell grid
                VStack(spacing: 0) {
                    ForEach(0..<9, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<9, id: \.self) { col in
                                CellView(
                                    cell: game.cells[row][col],
                                    isSelected: game.isSelected(row: row, col: col),
                                    isHighlighted: game.isHighlighted(row: row, col: col),
                                    hasSameValue: game.hasSameValue(row: row, col: col),
                                    size: cellSize
                                )
                                .onTapGesture { onTap(row, col) }
                            }
                        }
                    }
                }

                // Grid lines drawn on top
                Canvas { ctx, canvasSize in
                    let cs = canvasSize.width / 9
                    for i in 1..<9 {
                        let isBox = i % 3 == 0
                        let lineWidth: CGFloat = isBox ? 2.5 : 0.5
                        let color: GraphicsContext.Shading = isBox
                            ? .color(Color.primary)
                            : .color(Color.gray.opacity(0.4))

                        // Vertical
                        let x = cs * CGFloat(i)
                        var vPath = Path()
                        vPath.move(to: CGPoint(x: x, y: 0))
                        vPath.addLine(to: CGPoint(x: x, y: canvasSize.height))
                        ctx.stroke(vPath, with: color, lineWidth: lineWidth)

                        // Horizontal
                        let y = cs * CGFloat(i)
                        var hPath = Path()
                        hPath.move(to: CGPoint(x: 0, y: y))
                        hPath.addLine(to: CGPoint(x: canvasSize.width, y: y))
                        ctx.stroke(hPath, with: color, lineWidth: lineWidth)
                    }
                }
                .allowsHitTesting(false)

                // Outer border
                Rectangle()
                    .stroke(Color.primary, lineWidth: 2.5)
                    .allowsHitTesting(false)
            }
            .frame(width: size, height: size)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Cell

struct CellView: View {
    let cell: SudokuGame.Cell
    let isSelected: Bool
    let isHighlighted: Bool
    let hasSameValue: Bool
    let size: CGFloat

    var body: some View {
        ZStack {
            backgroundColor
            if cell.value != 0 {
                Text("\(cell.value)")
                    .font(.system(size: size * 0.48, weight: cell.isGiven ? .bold : .regular))
                    .foregroundColor(textColor)
            }
        }
        .frame(width: size, height: size)
    }

    private var backgroundColor: Color {
        if isSelected    { return Color.blue.opacity(0.35) }
        if hasSameValue  { return Color.blue.opacity(0.20) }
        if isHighlighted { return Color.blue.opacity(0.10) }
        return Color(.systemBackground)
    }

    private var textColor: Color {
        if cell.isGiven { return Color.primary }
        if cell.isError { return Color.red }
        return Color.blue
    }
}

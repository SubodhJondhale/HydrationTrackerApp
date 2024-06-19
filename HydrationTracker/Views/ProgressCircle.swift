import SwiftUI

struct ProgressCircle: View {
    var progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 20.0)
                .opacity(0.3)
                .foregroundColor(Color.blue)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(self.progress, 1.0)))
                .stroke(style: StrokeStyle(lineWidth: 20.0, lineCap: .round, lineJoin: .round))
                .foregroundColor(Color.blue)
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear,value: progress)

            Text(String(format: "%.0f %%", min(self.progress, 1.0) * 100.0))
                .font(.largeTitle)
                .bold()
                .foregroundColor(Color.blue)
        }
    }
}
struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle(progress: 0.75)
    }
}



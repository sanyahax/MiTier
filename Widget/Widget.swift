import WidgetKit
import SwiftUI

struct PlaceholderView: View {
  let colors: [Color] = [.red, .orange, .yellow, .green,
                         .blue, .purple, .pink, .white]
  var body: some View {
    ZStack {
      ForEach(0..<colors.count) { index in
        ContainerRelativeShape()
          .inset(by: CGFloat(index) * 3)
          .fill(colors[index])
      }

      Text("Five Stars")
        .font(.title)
        .bold()
    }
    .previewContext(Widget_Previews)
  }
}

struct Widget_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
        
    }
    
}

import SwiftUI

struct ContentView2: View {

    var body: some View {
        VStack(alignment: .center) {
            ClockView()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}

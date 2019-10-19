import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Text("apple")
                Text("banana")
                Text("orange")
                Text("peaches")
            }            .navigationBarTitle("Strings list")
            
        }
        
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environment(\.locale, Locale(identifier: "en"))
            ContentView()
                .environment(\.locale, Locale(identifier: "ja"))
        }
    }
}
#endif

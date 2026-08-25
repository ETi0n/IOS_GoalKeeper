import SwiftUI

struct OverflowMenu<MenuItems: View>: View {
    @ViewBuilder let menuItems: () -> MenuItems
    
    var body: some View {
        Menu {
            menuItems()
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 12))
                .foregroundStyle(.gray.opacity(0.5))
                .padding(6)
        }
    }
}

import SwiftUI
import SwiftData

struct CategorySection: View {
    let milestone: Milestone
    @State private var draftTitle = ""
    @Binding var selectedCategory: Category?
    @Environment(\.modelContext) private var context
    @Environment(UndoManager.self) private var undoManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Metrics.Spacing.md){
                Text("카테고리")
                    .font(.caption).foregroundStyle(Color.gkGray)
                
                ForEach(milestone.orderedCategories.filter { !undoManager.isPending($0.id) }) { category in
                    let isSelected = selectedCategory?.id == category.id

                    CategoryRow(milestone: milestone, category: category,
                                isSelected: isSelected, onDelete: {
                        if selectedCategory?.id == category.id {
                            selectedCategory = nil
                        }
                    })
                    .onTapGesture {
                        selectedCategory = category
                    }
                }
                
                HStack {
                    TextField("+ 카테고리 추가", text: $draftTitle)
                        .textFieldStyle(.plain)
                        .padding(.horizontal, Metrics.Spacing.md)
                        .frame(height: 36)
                        .background(.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Metrics.Radius.card))
                        .overlay(RoundedRectangle(cornerRadius: Metrics.Radius.card).stroke(Color.gkHairline, style: StrokeStyle(lineWidth: Metrics.Stroke.dashed, dash: [4])))
                        .onSubmit(addCategory)
                    
                    Button("추가", action: addCategory)
                        .disabled(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        .foregroundStyle(draftTitle.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gkGray : .gkGreen )
                }
            }
            .padding(Metrics.Spacing.lg)
        }
        .frame(width: 260)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Color.gkSurface)
    }
    
    private func addCategory() {
        if draftTitle.trimmingCharacters(in: .whitespaces).isEmpty { return }
        
        let newCategory = Category(name: draftTitle, tasks: [])
        context.insert(newCategory)
        milestone.categories.append(newCategory)
        try? context.save()
        draftTitle = ""
    }
}

#Preview {
    CategorySection(milestone: Goal.samples[0].milestones[0],
                     selectedCategory: .constant(Goal.samples[0].milestones[0].categories.first))
        .environment(UndoManager())
        .modelContainer(for: Goal.self, inMemory: true)
}

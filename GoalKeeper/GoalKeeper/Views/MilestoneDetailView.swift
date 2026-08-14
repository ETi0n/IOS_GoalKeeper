import SwiftUI

struct MilestoneDetailView: View {
    let milestone: Milestone
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // == 헤더 ==
                HStack {
                    Text(milestone.status)
                        .font(.caption)
                        .foregroundStyle(milestone.status == "대기" ? Color.gkGray : .gkGreen)
                         .padding(.horizontal, 8).padding(.vertical, 4)
                         .overlay(RoundedRectangle(cornerRadius: 8)
                         .stroke(milestone.status == "대기" ? Color.gkGray.opacity(0.4) : .gkGreen.opacity(0.4), lineWidth: 1))
                    Text(milestone.due).font(.caption).foregroundStyle(Color.gkGray)
                }
                Text(milestone.title).font(.title2).fontWeight(.medium)
                
                // == 카테고리별 ==
                ForEach(milestone.categories) { category in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(category.name)
                            .font(.caption).foregroundStyle(Color.gkGray)
                        
                        ForEach(category.tasks) { task in
                            TaskRow(task: task)
                        }
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.gkSurface)
    }
}

struct TaskRow: View {
    let task: TaskItem
    
    var body: some View {
        HStack(spacing: 11) {
            // 체크 아이콘
            Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(task.isDone ? Color.gkGreen : Color.gray.opacity(0.4))
            
            // 제목
            Text(task.title)
                .frame(maxWidth: .infinity, alignment: .leading) // 남는 공간 처리
                .strikethrough(task.isDone)
                .foregroundStyle(task.isDone ? Color.gkGray : .gkInk)
            
            // 태그 배지
            Text(task.tag)
                .font(.caption)
                .foregroundStyle(tagColor)
                .padding(.horizontal, 7).padding(.vertical, 4)
                .background(tagBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .padding(.horizontal, 14).padding(.vertical, 13)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 0.5))
    }
    
    // MARK: - helper
    private var tagColor: Color {
        switch task.tag {
        case "Must":    return .gkRed
        case "Should":  return .gkGreen
        default:        return .gkGray
        }
    }
    
    private var tagBackground: Color {
        switch task.tag {
        case "Must":    return .gkRedBG
        case "Should":  return .gkGreen.opacity(0.1)
        default:        return .clear
        }
    }
}

#Preview {
    MilestoneDetailView(milestone: Goal.samples[0].milestones[0])
}

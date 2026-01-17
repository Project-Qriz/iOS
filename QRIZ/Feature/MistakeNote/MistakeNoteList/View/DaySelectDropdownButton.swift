//
//  DaySelectDropdownButton.swift
//  QRIZ
//
//  Created by Claude on 1/13/26.
//

import SwiftUI

struct DaySelectDropdownButton: View {
    
    // MARK: - Properties
    
    let days: [String]
    @Binding var selectedDay: String
    @Binding var isExpanded: Bool
    
    // MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        } label: {
            HStack {
                Text(selectedDay)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(uiColor: .coolNeutral600))
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(uiColor: .coolNeutral500))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 14)
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(uiColor: .coolNeutral200), lineWidth: 1)
        )
    }
}

// MARK: - Dropdown List

struct DaySelectDropdownList: View {
    
    let days: [String]
    @Binding var selectedDay: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("회차 선택")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(uiColor: .coolNeutral600))
                .padding(.horizontal, 8)
                .padding(.vertical, 16)
            
            Divider()
            
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(days, id: \.self) { day in
                        dayRow(for: day)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(uiColor: .coolNeutral200), lineWidth: 1)
        )
        .shadow(
            color: Color(uiColor: .coolNeutral300).opacity(0.12),
            radius: 4,
            x: 0,
            y: 1
        )
    }
    
    private func dayRow(for day: String) -> some View {
        let isSelected = selectedDay == day
        
        return Button {
            selectedDay = day
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded = false
            }
        } label: {
            Text(day)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(uiColor: .coolNeutral800))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 8)
                .padding(.vertical, 14)
                .background(isSelected ? Color(uiColor: .customBlue200) : Color.clear)
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedDay = "Day6 (주간 복습)"
        @State private var isExpanded = true
        
        var body: some View {
            VStack {
                DaySelectDropdownButton(
                    days: ["Day6", "Day5", "Day4", "Day3", "Day2", "Day1"],
                    selectedDay: $selectedDay,
                    isExpanded: $isExpanded
                )
                
                if isExpanded {
                    DaySelectDropdownList(
                        days: ["Day6", "Day5", "Day4", "Day3", "Day2", "Day1"],
                        selectedDay: $selectedDay,
                        isExpanded: $isExpanded
                    )
                }
            }
            .padding()
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
    
    return PreviewWrapper()
}

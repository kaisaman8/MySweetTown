//
//  ShowcaseView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import CoreData

struct ShowcaseView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Sweet.earnedDate, ascending: false)],
        animation: .default)
    private var sweets: FetchedResults<Sweet>
    
    @State private var selectedRarity: SweetRarity? = nil
    @State private var selectedType: SweetType? = nil
    @State private var searchText = ""
    
    private let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 16)
    ]
    
    var filteredSweets: [Sweet] {
        var filtered = Array(sweets)
        
        // Filter by rarity
        if let selectedRarity = selectedRarity {
            filtered = filtered.filter { sweet in
                SweetRarity(rawValue: sweet.rarity ?? "common") == selectedRarity
            }
        }
        
        // Filter by type
        if let selectedType = selectedType {
            filtered = filtered.filter { sweet in
                SweetType(rawValue: sweet.sweetType ?? "candy") == selectedType
            }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { sweet in
                (sweet.name ?? "").localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    var sweetsByRarity: [SweetRarity: Int] {
        var counts: [SweetRarity: Int] = [:]
        for rarity in SweetRarity.allCases {
            counts[rarity] = 0
        }
        
        for sweet in sweets {
            let rarity = SweetRarity(rawValue: sweet.rarity ?? "common") ?? .common
            counts[rarity, default: 0] += 1
        }
        
        return counts
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Enhanced Statistics header
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🍭 Sweet Collection")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("Your delicious rewards showcase")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("\(sweets.count)")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            
                            Text("Total")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    
                    // Enhanced Rarity statistics
                    VStack(spacing: 12) {
                        HStack {
                            Text("📊 Collection by Rarity")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(SweetRarity.allCases, id: \.self) { rarity in
                                    RarityStatCard(
                                        rarity: rarity,
                                        count: sweetsByRarity[rarity] ?? 0,
                                        isSelected: selectedRarity == rarity
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedRarity = selectedRarity == rarity ? nil : rarity
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical, 20)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [Color(.systemGray6), Color(.systemBackground)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Filters and search
                VStack(spacing: 12) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        
                        TextField("Search sweets...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    
                    // Filter buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            // Rarity filter
                            Menu {
                                Button("All Rarities") {
                                    selectedRarity = nil
                                }
                                
                                ForEach(SweetRarity.allCases, id: \.self) { rarity in
                                    Button(rarity.displayName) {
                                        selectedRarity = rarity
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedRarity?.displayName ?? "All Rarities")
                                    Image(systemName: "chevron.down")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedRarity != nil ? Color.blue.opacity(0.2) : Color(.systemGray5))
                                .cornerRadius(6)
                            }
                            
                            // Type filter
                            Menu {
                                Button("All Types") {
                                    selectedType = nil
                                }
                                
                                ForEach(SweetType.allCases, id: \.self) { type in
                                    Button(type.displayName) {
                                        selectedType = type
                                    }
                                }
                            } label: {
                                HStack {
                                    Text(selectedType?.displayName ?? "All Types")
                                    Image(systemName: "chevron.down")
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedType != nil ? Color.blue.opacity(0.2) : Color(.systemGray5))
                                .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                // Sweet collection
                ScrollView {
                    if filteredSweets.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: sweets.isEmpty ? "star.circle" : "magnifyingglass")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            
                            Text(sweets.isEmpty ? "No sweets yet!" : "No sweets match your filters")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Text(sweets.isEmpty ? "Complete tasks to start your collection" : "Try adjusting your search or filters")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 50)
                    } else {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredSweets, id: \.id) { sweet in
                                ShowcaseSweetCardView(sweet: sweet)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct ShowcaseSweetCardView: View {
    let sweet: Sweet
    @State private var isAnimating = false
    
    private var rarity: SweetRarity {
        SweetRarity(rawValue: sweet.rarity ?? "common") ?? .common
    }
    
    private var rarityColor: Color {
        Color(rarity.color)
    }
    
    private var earnedDateString: String {
        guard let earnedDate = sweet.earnedDate else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: earnedDate)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(rarityColor.opacity(0.2))
                    .frame(width: 70, height: 70)
                
                Circle()
                    .stroke(rarityColor, lineWidth: 2)
                    .frame(width: 70, height: 70)
                
                Text(sweet.iconName ?? "🍬")
                    .font(.system(size: 35))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            VStack(spacing: 4) {
                Text(sweet.name ?? "Sweet")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(rarity.displayName)
                    .font(.subheadline)
                    .foregroundColor(rarityColor)
                    .fontWeight(.medium)
                
                Text("Earned:")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text(earnedDateString)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: rarityColor.opacity(0.3), radius: 6, x: 0, y: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(rarityColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Supporting Views

struct RarityStatCard: View {
    let rarity: SweetRarity
    let count: Int
    let isSelected: Bool
    @State private var isAnimating = false
    
    private var rarityColor: Color {
        Color(rarity.color)
    }
    
    private var rarityIcon: String {
        switch rarity {
        case .common:
            return "🥉"
        case .uncommon:
            return "🥈"
        case .rare:
            return "🥇"
        case .epic:
            return "💎"
        case .legendary:
            return "👑"
        }
    }
    
    private var rarityGradient: LinearGradient {
        switch rarity {
        case .common:
            return LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .uncommon:
            return LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .rare:
            return LinearGradient(colors: [.blue.opacity(0.3), .blue.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .epic:
            return LinearGradient(colors: [.purple.opacity(0.3), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .legendary:
            return LinearGradient(colors: [.orange.opacity(0.4), .yellow.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Icon and count section
            ZStack {
                // Background circle with gradient
                Circle()
                    .fill(rarityGradient)
                    .frame(width: 60, height: 60)
                
                // Animated border
                Circle()
                    .stroke(rarityColor, lineWidth: isSelected ? 3 : 2)
                    .frame(width: 60, height: 60)
                    .scaleEffect(isAnimating && rarity == .legendary ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                
                // Icon and count
                VStack(spacing: 2) {
                    Text(rarityIcon)
                        .font(.system(size: 24))
                        .scaleEffect(isAnimating && isSelected ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("\(count)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(rarityColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color(.systemBackground))
                                .shadow(color: rarityColor.opacity(0.3), radius: 2, x: 0, y: 1)
                        )
                }
            }
            
            // Text information
            VStack(spacing: 4) {
                Text(rarity.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? rarityColor : .primary)
                
                HStack(spacing: 4) {
                    Text("\(Int(rarity.probability * 100))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    // Rarity indicator stars
                    HStack(spacing: 1) {
                        ForEach(0..<rarityStars, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.system(size: 6))
                                .foregroundColor(rarityColor)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? AnyShapeStyle(rarityGradient) : AnyShapeStyle(Color(.systemBackground)))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(rarityColor.opacity(isSelected ? 0.6 : 0.3), lineWidth: isSelected ? 2 : 1)
                )
                .shadow(
                    color: isSelected ? rarityColor.opacity(0.4) : .black.opacity(0.1),
                    radius: isSelected ? 8 : 3,
                    x: 0,
                    y: isSelected ? 4 : 2
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        .onAppear {
            isAnimating = true
        }
    }
    
    private var rarityStars: Int {
        switch rarity {
        case .common: return 1
        case .uncommon: return 2
        case .rare: return 3
        case .epic: return 4
        case .legendary: return 5
        }
    }
}

#Preview {
    ShowcaseView()
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}

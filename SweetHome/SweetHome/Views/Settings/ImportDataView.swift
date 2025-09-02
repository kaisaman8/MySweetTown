//
//  ImportDataView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportDataView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var coreDataManager: CoreDataManager
    
    @State private var showingFilePicker = false
    @State private var showingImportAlert = false
    @State private var importSuccess = false
    @State private var importError: String?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.down.circle")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                VStack(spacing: 12) {
                    Text("Import Data")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Import your Sweet Town data from a previously exported JSON file")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    Label("Supported Format", systemImage: "doc.text")
                        .font(.headline)
                    
                    Text("JSON files exported from Sweet Town")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                VStack(spacing: 12) {
                    Label("Warning", systemImage: "exclamationmark.triangle")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Importing will replace all current data including tasks, sweets, and settings. This action cannot be undone.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                Button(action: {
                    showingFilePicker = true
                }) {
                    Label("Choose File to Import", systemImage: "folder")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Import Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [UTType.json],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result)
            }
            .alert("Import Result", isPresented: $showingImportAlert) {
                Button("OK") {
                    if importSuccess {
                        dismiss()
                    }
                }
            } message: {
                if importSuccess {
                    Text("Data imported successfully!")
                } else {
                    Text("Import failed: \(importError ?? "Unknown error")")
                }
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let exportService = ExportImportService()
                
                let success = exportService.importData(data, context: viewContext, coreDataManager: coreDataManager)
                
                importSuccess = success
                if !success {
                    importError = "Invalid file format or corrupted data"
                }
                showingImportAlert = true
                
            } catch {
                importSuccess = false
                importError = error.localizedDescription
                showingImportAlert = true
            }
            
        case .failure(let error):
            importSuccess = false
            importError = error.localizedDescription
            showingImportAlert = true
        }
    }
}

#Preview {
    ImportDataView()
        .environmentObject(CoreDataManager.shared)
        .environment(\.managedObjectContext, CoreDataManager.shared.context)
}

//
//  ExportDataView.swift
//  SweetHome
//
//  Created by Lukos on 8/12/25.
//

import SwiftUI

struct ExportDataView: View {
    @Environment(\.dismiss) private var dismiss
    let data: Data
    
    @State private var showingShareSheet = false
    
    private var fileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm"
        return "SweetTown_Export_\(formatter.string(from: Date())).json"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 12) {
                    Text("Export Ready")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Your Sweet Town data has been prepared for export")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        Text("File Size:")
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .file))
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Format:")
                        Spacer()
                        Text("JSON")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("File Name:")
                        Spacer()
                        Text(fileName)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button(action: {
                    showingShareSheet = true
                }) {
                    Label("Share Export File", systemImage: "square.and.arrow.up")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingShareSheet) {
                ShareSheet(items: [createTemporaryFile()])
            }
        }
    }
    
    private func createTemporaryFile() -> URL {
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("Error writing temporary file: \(error)")
        }
        
        return fileURL
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    let sampleData = "Sample export data".data(using: .utf8)!
    return ExportDataView(data: sampleData)
}

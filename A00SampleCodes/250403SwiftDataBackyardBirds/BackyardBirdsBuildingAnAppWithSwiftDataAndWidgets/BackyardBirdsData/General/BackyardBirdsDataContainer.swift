/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
The model's container.
*/

import SwiftUI
import SwiftData

public extension View {
    func backyardBirdsDataContainer(inMemory: Bool = DataGenerationOptions.inMemoryPersistence) -> some View {
        modifier(BackyardBirdsDataContainerViewModifier(inMemory: inMemory))
    }
}

private struct BackyardBirdsDataContainerViewModifier: ViewModifier {
    let container: ModelContainer
    
    init(inMemory: Bool) {
        container = try! ModelContainer(for: DataGeneration.schema, configurations: [ModelConfiguration(isStoredInMemoryOnly: inMemory)])
    }
    
    func body(content: Content) -> some View {
        content
            .generateData()
            .modelContainer(container)
    }
}

private extension View {
    func generateData() -> some View {
        modifier(GenerateDataViewModifier())
    }
}

private struct GenerateDataViewModifier: ViewModifier {
    @Environment(\.modelContext) private var modelContext
    
    func body(content: Content) -> some View {
        content.onAppear {
            DataGeneration.generateAllData(modelContext: modelContext)
        }
    }
}

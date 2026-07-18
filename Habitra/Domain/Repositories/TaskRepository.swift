import Foundation

@MainActor
protocol TaskRepository {
    func fetchAll() throws -> [TaskItem]
    func add(_ task: TaskItem) throws
    func update(_ task: TaskItem) throws
    func delete(id: UUID) throws

    @discardableResult
    func toggleCompletion(id: UUID) throws -> Bool
}

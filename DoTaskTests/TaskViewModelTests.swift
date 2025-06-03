import XCTest
import FirebaseDatabase
@testable import DoTask

final class TaskViewModelTests: XCTestCase {
    var taskVM: TaskViewModel!
    let testUserId = "testUser123" // Use a dedicated test user id to avoid messing real data

    override func setUp() {
        super.setUp()
        taskVM = TaskViewModel(userId: testUserId)
        
        // Clear all tasks for test user before each test (synchronously)
        let expectation = self.expectation(description: "Clear test data")
        taskVM.testDatabaseRef.removeValue { error, _ in
            XCTAssertNil(error, "Failed to clear test data: \(error!.localizedDescription)")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 5)
    }

    override func tearDown() {
        taskVM = nil
        super.tearDown()
    }

    func testAddTask() {
        let addExpectation = expectation(description: "Add task")
        taskVM.addTask(title: "Test Title", details: "Test Details")

        // Wait a bit for async Firebase write
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.taskVM.loadTasks() // Reload tasks to confirm added

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssertFalse(self.taskVM.tasks.isEmpty)
                XCTAssertEqual(self.taskVM.tasks.first?.title, "Test Title")
                XCTAssertEqual(self.taskVM.tasks.first?.details, "Test Details")
                addExpectation.fulfill()
            }
        }
        wait(for: [addExpectation], timeout: 10)
    }

    func testDeleteTask() {
        let addExpectation = expectation(description: "Add task before delete")
        taskVM.addTask(title: "Delete Me", details: "Details")

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.taskVM.loadTasks()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                XCTAssertFalse(self.taskVM.tasks.isEmpty)
                let indexSet = IndexSet(integer: 0)
                self.taskVM.deleteTask(at: indexSet)

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.taskVM.loadTasks()
                    XCTAssertTrue(self.taskVM.tasks.isEmpty)
                    addExpectation.fulfill()
                }
            }
        }
        wait(for: [addExpectation], timeout: 15)
    }

    func testToggleTask() {
        let expectationToggle = expectation(description: "Toggle task completion")

        // Add task first
        taskVM.addTask(title: "Toggle Me", details: "Details")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.taskVM.loadTasks()
            guard let task = self.taskVM.tasks.first else {
                XCTFail("No task found to toggle")
                return
            }
            let originalStatus = task.completed

            self.taskVM.toggleTask(task)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.taskVM.loadTasks()
                let toggledTask = self.taskVM.tasks.first
                XCTAssertEqual(toggledTask?.completed, !originalStatus)
                expectationToggle.fulfill()
            }
        }
        wait(for: [expectationToggle], timeout: 15)
    }

    func testUpdateTask() {
        let expectationUpdate = expectation(description: "Update task")

        taskVM.addTask(title: "Old Title", details: "Old Details")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.taskVM.loadTasks()
            guard let task = self.taskVM.tasks.first else {
                XCTFail("No task found to update")
                return
            }

            self.taskVM.updateTask(task: task, newTitle: "New Title", newDetails: "New Details")

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.taskVM.loadTasks()
                let updatedTask = self.taskVM.tasks.first
                XCTAssertEqual(updatedTask?.title, "New Title")
                XCTAssertEqual(updatedTask?.details, "New Details")
                expectationUpdate.fulfill()
            }
        }
        wait(for: [expectationUpdate], timeout: 15)
    }
}

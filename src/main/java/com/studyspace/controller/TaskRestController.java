package com.studyspace.controller;

import com.studyspace.data.DataStore;
import com.studyspace.model.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/tasks")
public class TaskRestController {

    private final DataStore dataStore;
    private final ReminderManager reminderManager;

    public TaskRestController(DataStore dataStore, ReminderManager reminderManager) {
        this.dataStore = dataStore;
        this.reminderManager = reminderManager;
    }

    @GetMapping
    public ResponseEntity<List<Task>> getAllTasks() {
        return ResponseEntity.ok(dataStore.getAllTasks());
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getTaskById(@PathVariable String id) {
        Task task = dataStore.findTaskById(id);
        if (task == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(task);
    }

    @PostMapping
    public ResponseEntity<Task> createTask(@RequestBody Map<String, Object> body) {
        String type = (String) body.getOrDefault("type", "ASSIGNMENT");
        String title = (String) body.get("title");
        String deadlineStr = (String) body.get("deadline");
        int difficulty = body.containsKey("difficultyLevel") ? (int) body.get("difficultyLevel") : 1;
        String subjectCode = (String) body.get("subjectCode");

        LocalDateTime deadline = deadlineStr != null ? LocalDateTime.parse(deadlineStr) : LocalDateTime.now().plusDays(7);
        String taskId = "TASK-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        Task task;
        if ("EXAM".equalsIgnoreCase(type)) {
            @SuppressWarnings("unchecked")
            List<String> syllabus = (List<String>) body.getOrDefault("syllabusList", new ArrayList<>());
            task = new ExamTask(taskId, title, deadline, difficulty, syllabus);
        } else {
            String attachment = (String) body.get("attachmentLink");
            task = new AssignmentTask(taskId, title, deadline, difficulty, attachment);
        }

        String status = (String) body.getOrDefault("status", "TODO");
        task.setStatus(status);

        // Add to subject if provided
        if (subjectCode != null) {
            Subject subject = dataStore.findSubjectByCode(subjectCode);
            if (subject != null) {
                subject.addTask(task);
            } else {
                task.setSubjectCode(subjectCode);
            }
        }

        dataStore.getAllTasks().add(task);
        reminderManager.addTaskToQueue(task);

        return ResponseEntity.ok(task);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<?> updateTaskStatus(@PathVariable String id, @RequestBody Map<String, String> body) {
        Task task = dataStore.findTaskById(id);
        if (task == null) {
            return ResponseEntity.notFound().build();
        }

        String newStatus = body.get("status");
        if (newStatus != null) {
            task.setStatus(newStatus);
            if ("DONE".equalsIgnoreCase(newStatus)) {
                task.markAsCompleted();
            }
        }

        return ResponseEntity.ok(task);
    }

    @PutMapping("/{id}/complete")
    public ResponseEntity<?> completeTask(@PathVariable String id) {
        Task task = dataStore.findTaskById(id);
        if (task == null) {
            return ResponseEntity.notFound().build();
        }

        task.markAsCompleted();
        dataStore.getUser().addXP(100);
        reminderManager.rebuildQueue(dataStore.getAllTasks());

        Map<String, Object> response = new HashMap<>();
        response.put("task", task);
        response.put("xpAwarded", 100);
        response.put("totalXP", dataStore.getUser().getTotalXP());

        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTask(@PathVariable String id) {
        Task task = dataStore.findTaskById(id);
        if (task == null) {
            return ResponseEntity.notFound().build();
        }

        dataStore.getAllTasks().remove(task);
        reminderManager.removeFromQueue(task);

        // Remove from subject
        if (task.getSubjectCode() != null) {
            Subject subject = dataStore.findSubjectByCode(task.getSubjectCode());
            if (subject != null) {
                subject.getTasks().remove(task);
            }
        }

        return ResponseEntity.ok(Map.of("message", "Task deleted", "taskId", id));
    }

    @GetMapping("/priority-queue")
    public ResponseEntity<List<Task>> getPriorityQueue() {
        return ResponseEntity.ok(reminderManager.getSortedTasks());
    }
}

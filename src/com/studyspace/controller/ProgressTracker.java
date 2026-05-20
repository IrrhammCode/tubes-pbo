package com.studyspace.controller;

import com.studyspace.model.Subject;
import com.studyspace.model.Task;
import java.util.List;

public class ProgressTracker {

    public double calculateSubjectCompletion(Subject subject) {
        List<Task> tasks = subject.getTasks();
        if (tasks.isEmpty()) {
            return 0.0; // Avoid division by zero
        }

        int completedCount = 0;
        for (Task task : tasks) {
            if (task.isCompleted()) {
                completedCount++;
            }
        }

        return ((double) completedCount / tasks.size()) * 100;
    }

    public void generatePerformanceReport(Subject subject) {
        double completionPercentage = calculateSubjectCompletion(subject);
        System.out.println("=== Performance Report: " + subject.getSubjectName() + " ===");
        System.out.printf("Completion Rate: %.2f%%\n", completionPercentage);
        System.out.println("Total Tasks: " + subject.getTasks().size());
        
        long completedTasks = subject.getTasks().stream().filter(Task::isCompleted).count();
        System.out.println("Completed: " + completedTasks);
        System.out.println("Pending: " + (subject.getTasks().size() - completedTasks));
        System.out.println("=========================================");
    }
}

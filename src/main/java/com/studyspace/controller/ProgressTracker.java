package com.studyspace.controller;

import com.studyspace.model.Subject;
import com.studyspace.model.Task;
import org.springframework.stereotype.Service;
import java.util.*;

@Service
public class ProgressTracker {

    public double calculateSubjectCompletion(Subject subject) {
        List<Task> tasks = subject.getTasks();
        if (tasks.isEmpty()) return 0.0;
        int completedCount = 0;
        for (Task task : tasks) {
            if (task.isCompleted()) completedCount++;
        }
        return ((double) completedCount / tasks.size()) * 100;
    }

    public Map<String, Object> getSubjectProgressData(Subject subject) {
        Map<String, Object> data = new HashMap<>();
        data.put("subjectCode", subject.getSubjectCode());
        data.put("subjectName", subject.getSubjectName());
        data.put("completionPercentage", Math.round(calculateSubjectCompletion(subject)));
        data.put("totalTasks", subject.getTasks().size());
        data.put("completedTasks", subject.getTasks().stream().filter(Task::isCompleted).count());
        return data;
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

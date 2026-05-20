package com.studyspace.controller;

import com.studyspace.model.Task;
import java.util.PriorityQueue;
import java.util.Comparator;

public class ReminderManager {
    // PriorityQueue to automatically sort tasks based on priority score
    private PriorityQueue<Task> taskQueue;

    public ReminderManager() {
        // Higher priority score comes first
        taskQueue = new PriorityQueue<>(new Comparator<Task>() {
            @Override
            public int compare(Task t1, Task t2) {
                return Double.compare(t2.calculatePriorityScore(), t1.calculatePriorityScore());
            }
        });
    }

    public void addTaskToQueue(Task task) {
        if (!task.isCompleted()) {
            taskQueue.offer(task);
        }
    }

    public Task getMostUrgentTask() {
        return taskQueue.peek(); // Returns the task with highest priority without removing
    }

    public void displayQueue() {
        System.out.println("--- Task Priority Queue ---");
        // Note: Iterating over PriorityQueue doesn't guarantee sorted order, 
        // so we clone and poll to show sorted order
        PriorityQueue<Task> tempQueue = new PriorityQueue<>(taskQueue);
        int rank = 1;
        while (!tempQueue.isEmpty()) {
            Task t = tempQueue.poll();
            System.out.printf("%d. %s (Score: %.2f)\n", rank++, t.getTitle(), t.calculatePriorityScore());
        }
    }
}

package com.studyspace.controller;

import com.studyspace.model.Task;
import java.util.*;

public class ReminderManager {
    private PriorityQueue<Task> taskQueue;

    public ReminderManager() {
        taskQueue = new PriorityQueue<>((t1, t2) ->
            Double.compare(t2.calculatePriorityScore(), t1.calculatePriorityScore()));
    }

    public void addTaskToQueue(Task task) {
        if (!task.isCompleted()) taskQueue.offer(task);
    }

    public void removeFromQueue(Task task) {
        taskQueue.remove(task);
    }

    public void rebuildQueue(List<Task> allTasks) {
        taskQueue.clear();
        for (Task t : allTasks) {
            if (!t.isCompleted()) taskQueue.offer(t);
        }
    }

    public Task getMostUrgentTask() { return taskQueue.peek(); }

    public List<Task> getSortedTasks() {
        List<Task> sorted = new ArrayList<>();
        PriorityQueue<Task> tempQueue = new PriorityQueue<>(taskQueue);
        while (!tempQueue.isEmpty()) sorted.add(tempQueue.poll());
        return sorted;
    }

    public void displayQueue() {
        System.out.println("--- Task Priority Queue ---");
        PriorityQueue<Task> tempQueue = new PriorityQueue<>(taskQueue);
        int rank = 1;
        while (!tempQueue.isEmpty()) {
            Task t = tempQueue.poll();
            System.out.printf("%d. %s (Score: %.2f)\n", rank++, t.getTitle(), t.calculatePriorityScore());
        }
    }
}

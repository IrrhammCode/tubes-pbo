package com.studyspace.model;

import com.studyspace.interfaces.Prioritizable;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public abstract class Task extends Activity implements Prioritizable {
    protected LocalDateTime deadline;
    protected int difficultyLevel; // e.g., 1 (Low) to 5 (High)
    protected boolean isCompleted;

    public Task(String activityId, String title, LocalDateTime deadline, int difficultyLevel) {
        super(activityId, title);
        this.deadline = deadline;
        this.difficultyLevel = difficultyLevel;
        this.isCompleted = false;
    }

    // Implementing polymorphic priority calculation
    @Override
    public double calculatePriorityScore() {
        if (isCompleted) return -1; // Completed tasks have lowest priority

        long hoursUntilDeadline = ChronoUnit.HOURS.between(LocalDateTime.now(), deadline);
        if (hoursUntilDeadline <= 0) hoursUntilDeadline = 1; // Prevent division by zero or negative

        // Algorithm: Weighting difficulty against remaining time
        // High difficulty and low hours means high priority score
        return ((double) difficultyLevel / hoursUntilDeadline) * 100;
    }

    // Getters and Setters
    public LocalDateTime getDeadline() { return deadline; }
    public void setDeadline(LocalDateTime deadline) { this.deadline = deadline; }
    public int getDifficultyLevel() { return difficultyLevel; }
    public boolean isCompleted() { return isCompleted; }
    
    public void markAsCompleted() {
        this.isCompleted = true;
    }
}

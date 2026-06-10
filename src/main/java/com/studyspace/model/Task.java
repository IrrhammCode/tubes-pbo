package com.studyspace.model;

import com.studyspace.interfaces.Prioritizable;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public abstract class Task extends Activity implements Prioritizable {
    protected LocalDateTime deadline;
    protected int difficultyLevel;
    protected boolean isCompleted;
    protected String status; // "TODO", "IN_PROGRESS", "IN_REVIEW", "DONE"
    protected String subjectCode;

    public Task() { super(); } // Jackson

    public Task(String activityId, String title, LocalDateTime deadline, int difficultyLevel) {
        super(activityId, title);
        this.deadline = deadline;
        this.difficultyLevel = difficultyLevel;
        this.isCompleted = false;
        this.status = "TODO";
    }

    @Override
    public double calculatePriorityScore() {
        if (isCompleted) return -1;
        long hoursUntilDeadline = ChronoUnit.HOURS.between(LocalDateTime.now(), deadline);
        if (hoursUntilDeadline <= 0) hoursUntilDeadline = 1;
        return ((double) difficultyLevel / hoursUntilDeadline) * 100;
    }

    public LocalDateTime getDeadline() { return deadline; }
    public void setDeadline(LocalDateTime deadline) { this.deadline = deadline; }
    public int getDifficultyLevel() { return difficultyLevel; }
    public void setDifficultyLevel(int difficultyLevel) { this.difficultyLevel = difficultyLevel; }
    public boolean isCompleted() { return isCompleted; }
    public boolean getIsCompleted() { return isCompleted; }
    public void setCompleted(boolean completed) { isCompleted = completed; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }

    public void markAsCompleted() {
        this.isCompleted = true;
        this.status = "DONE";
    }
}

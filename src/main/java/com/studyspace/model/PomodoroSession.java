package com.studyspace.model;

import java.time.LocalDateTime;

public class PomodoroSession {
    private String sessionId;
    private LocalDateTime startTime;
    private LocalDateTime endTime;
    private int durationMinutes;
    private String linkedTaskId;
    private boolean completed;

    public PomodoroSession() {}

    public PomodoroSession(String sessionId, int durationMinutes) {
        this.sessionId = sessionId;
        this.startTime = LocalDateTime.now();
        this.durationMinutes = durationMinutes;
        this.completed = false;
    }

    public void complete() {
        this.endTime = LocalDateTime.now();
        this.completed = true;
    }

    // Getters and setters
    public String getSessionId() { return sessionId; }
    public void setSessionId(String id) { this.sessionId = id; }
    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime t) { this.startTime = t; }
    public LocalDateTime getEndTime() { return endTime; }
    public void setEndTime(LocalDateTime t) { this.endTime = t; }
    public int getDurationMinutes() { return durationMinutes; }
    public void setDurationMinutes(int m) { this.durationMinutes = m; }
    public String getLinkedTaskId() { return linkedTaskId; }
    public void setLinkedTaskId(String id) { this.linkedTaskId = id; }
    public boolean isCompleted() { return completed; }
    public void setCompleted(boolean c) { this.completed = c; }
}

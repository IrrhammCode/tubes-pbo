package com.studyspace.model;

import java.time.LocalDateTime;

public abstract class Activity {
    protected String activityId;
    protected String title;
    protected LocalDateTime createdAt;

    public Activity(String activityId, String title) {
        this.activityId = activityId;
        this.title = title;
        this.createdAt = LocalDateTime.now();
    }

    // Getters and Setters
    public String getActivityId() { return activityId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}

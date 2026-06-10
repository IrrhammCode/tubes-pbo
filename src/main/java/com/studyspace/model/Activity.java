package com.studyspace.model;

import java.time.LocalDateTime;

public abstract class Activity {
    protected String activityId;
    protected String title;
    protected LocalDateTime createdAt;

    public Activity() {} // Jackson needs default constructor

    public Activity(String activityId, String title) {
        this.activityId = activityId;
        this.title = title;
        this.createdAt = LocalDateTime.now();
    }

    public String getActivityId() { return activityId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setActivityId(String activityId) { this.activityId = activityId; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}

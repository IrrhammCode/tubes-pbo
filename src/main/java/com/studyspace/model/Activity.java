package com.studyspace.model;

import com.fasterxml.jackson.annotation.JsonTypeInfo;
import com.fasterxml.jackson.annotation.JsonSubTypes;
import java.time.LocalDateTime;

@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, property = "type")
@JsonSubTypes({
    @JsonSubTypes.Type(value = AssignmentTask.class, name = "ASSIGNMENT"),
    @JsonSubTypes.Type(value = ExamTask.class, name = "EXAM"),
    @JsonSubTypes.Type(value = TextNote.class, name = "TEXT_NOTE"),
    @JsonSubTypes.Type(value = ChecklistNote.class, name = "CHECKLIST_NOTE")
})
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

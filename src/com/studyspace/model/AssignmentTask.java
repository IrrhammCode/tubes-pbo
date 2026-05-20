package com.studyspace.model;

import java.time.LocalDateTime;

public class AssignmentTask extends Task {
    private String attachmentLink;

    public AssignmentTask(String activityId, String title, LocalDateTime deadline, int difficultyLevel, String attachmentLink) {
        super(activityId, title, deadline, difficultyLevel);
        this.attachmentLink = attachmentLink;
    }

    public String getAttachmentLink() { return attachmentLink; }
    public void setAttachmentLink(String attachmentLink) { this.attachmentLink = attachmentLink; }
}

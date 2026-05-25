package com.studyspace.model;

import java.time.LocalDateTime;

public abstract class Note extends Activity {
    protected LocalDateTime lastModified;

    public Note() { super(); }

    public Note(String activityId, String title) {
        super(activityId, title);
        this.lastModified = LocalDateTime.now();
    }

    public void updateModificationTime() { this.lastModified = LocalDateTime.now(); }
    public LocalDateTime getLastModified() { return lastModified; }
    public void setLastModified(LocalDateTime lastModified) { this.lastModified = lastModified; }
}

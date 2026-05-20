package com.studyspace.model;

import com.studyspace.interfaces.Exportable;

public class TextNote extends Note implements Exportable {
    private String content;

    public TextNote(String activityId, String title, String content) {
        super(activityId, title);
        this.content = content;
    }

    public String getContent() { return content; }
    public void setContent(String content) { 
        this.content = content; 
        updateModificationTime();
    }

    @Override
    public String exportContent() {
        return "Title: " + getTitle() + "\n" +
               "Last Modified: " + getLastModified() + "\n" +
               "Content:\n" + content;
    }
}

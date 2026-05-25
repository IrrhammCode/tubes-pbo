package com.studyspace.model;

import com.studyspace.interfaces.Exportable;
import java.util.List;
import java.util.ArrayList;

public class ChecklistNote extends Note implements Exportable {
    private List<String> items;

    public ChecklistNote() { super(); this.items = new ArrayList<>(); }

    public ChecklistNote(String activityId, String title, List<String> items) {
        super(activityId, title);
        this.items = items;
    }

    public List<String> getItems() { return items; }
    public void setItems(List<String> items) { this.items = items; updateModificationTime(); }

    @Override
    public String exportContent() {
        StringBuilder sb = new StringBuilder();
        sb.append("Title: ").append(getTitle()).append("\n");
        sb.append("Last Modified: ").append(getLastModified()).append("\n");
        sb.append("Checklist:\n");
        for (String item : items) { sb.append("- [ ] ").append(item).append("\n"); }
        return sb.toString();
    }
}

package com.studyspace.model;

import java.util.ArrayList;
import java.util.List;

public class Subject {
    private String subjectCode;
    private String subjectName;
    private List<Task> tasks;
    private List<Note> notes;

    // Aggregation: Subject aggregates Tasks and Notes
    public Subject(String subjectCode, String subjectName) {
        this.subjectCode = subjectCode;
        this.subjectName = subjectName;
        this.tasks = new ArrayList<>();
        this.notes = new ArrayList<>();
    }

    public void addTask(Task task) {
        tasks.add(task);
    }

    public void addNote(Note note) {
        notes.add(note);
    }

    public List<Task> getTasks() { return tasks; }
    public List<Note> getNotes() { return notes; }
    public String getSubjectCode() { return subjectCode; }
    public String getSubjectName() { return subjectName; }
}

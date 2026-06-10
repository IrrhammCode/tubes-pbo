package com.studyspace.model;

import java.util.ArrayList;
import java.util.List;

public class Subject {
    private String subjectCode;
    private String subjectName;
    private List<Task> tasks;
    private List<Note> notes;

    public Subject() { this.tasks = new ArrayList<>(); this.notes = new ArrayList<>(); }

    public Subject(String subjectCode, String subjectName) {
        this.subjectCode = subjectCode;
        this.subjectName = subjectName;
        this.tasks = new ArrayList<>();
        this.notes = new ArrayList<>();
    }

    public void addTask(Task task) { tasks.add(task); task.setSubjectCode(this.subjectCode); }
    public void addNote(Note note) { notes.add(note); }
    public List<Task> getTasks() { return tasks; }
    public List<Note> getNotes() { return notes; }
    public String getSubjectCode() { return subjectCode; }
    public void setSubjectCode(String subjectCode) { this.subjectCode = subjectCode; }
    public String getSubjectName() { return subjectName; }
    public void setSubjectName(String subjectName) { this.subjectName = subjectName; }
}

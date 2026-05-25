package com.studyspace.data;

import com.studyspace.model.*;
import org.springframework.stereotype.Component;
import java.util.ArrayList;
import java.util.List;

@Component
public class DataStore {
    private User user;
    private List<Subject> subjects = new ArrayList<>();
    private List<Task> allTasks = new ArrayList<>();
    private List<Note> allNotes = new ArrayList<>();
    private List<PomodoroSession> pomodoroSessions = new ArrayList<>();

    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }

    public List<Subject> getSubjects() { return subjects; }
    public void setSubjects(List<Subject> subjects) { this.subjects = subjects; }

    public List<Task> getAllTasks() { return allTasks; }
    public void setAllTasks(List<Task> allTasks) { this.allTasks = allTasks; }

    public List<Note> getAllNotes() { return allNotes; }
    public void setAllNotes(List<Note> allNotes) { this.allNotes = allNotes; }

    public List<PomodoroSession> getPomodoroSessions() { return pomodoroSessions; }
    public void setPomodoroSessions(List<PomodoroSession> pomodoroSessions) { this.pomodoroSessions = pomodoroSessions; }

    public Subject findSubjectByCode(String code) {
        return subjects.stream()
                .filter(s -> s.getSubjectCode().equals(code))
                .findFirst()
                .orElse(null);
    }

    public Task findTaskById(String id) {
        return allTasks.stream()
                .filter(t -> t.getActivityId().equals(id))
                .findFirst()
                .orElse(null);
    }
}

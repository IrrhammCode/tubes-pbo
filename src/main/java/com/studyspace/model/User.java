package com.studyspace.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import java.util.ArrayList;
import java.util.List;

public class User {
    private String username;
    private String email;
    private int totalXP;
    private int pomodoroSessionsCount;
    private int totalFocusMinutes;
    private String joinedDate;
    @JsonIgnore
    private List<Subject> subjects;

    public User() { this.subjects = new ArrayList<>(); }

    public User(String username, String email) {
        this.username = username;
        this.email = email;
        this.totalXP = 0;
        this.pomodoroSessionsCount = 0;
        this.totalFocusMinutes = 0;
        this.joinedDate = "Agt 2026";
        this.subjects = new ArrayList<>();
    }

    public Subject createSubject(String subjectCode, String subjectName) {
        Subject newSubject = new Subject(subjectCode, subjectName);
        this.subjects.add(newSubject);
        return newSubject;
    }

    public void deleteSubject(Subject subject) { this.subjects.remove(subject); }

    public void addXP(int points) {
        if (points > 0) {
            this.totalXP += points;
            System.out.println("XP Added! Total XP is now: " + this.totalXP);
        }
    }

    public int getLevel() { return (totalXP / 1000) + 1; }
    public int getXpForNextLevel() { return 1000 - (totalXP % 1000); }
    public int getLevelProgressPercent() { return (totalXP % 1000) / 10; }

    public List<Subject> getSubjects() { return subjects; }
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public int getTotalXP() { return totalXP; }
    public void setTotalXP(int totalXP) { this.totalXP = totalXP; }
    public int getPomodoroSessionsCount() { return pomodoroSessionsCount; }
    public void setPomodoroSessionsCount(int count) { this.pomodoroSessionsCount = count; }
    public int getTotalFocusMinutes() { return totalFocusMinutes; }
    public void setTotalFocusMinutes(int min) { this.totalFocusMinutes = min; }
    public String getJoinedDate() { return joinedDate; }
    public void setJoinedDate(String joinedDate) { this.joinedDate = joinedDate; }
}

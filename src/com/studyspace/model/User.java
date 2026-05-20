package com.studyspace.model;

import java.util.ArrayList;
import java.util.List;

public class User {
    private String username;
    private String email;
    private int totalXP;
    private List<Subject> subjects;

    public User(String username, String email) {
        this.username = username;
        this.email = email;
        this.totalXP = 0;
        this.subjects = new ArrayList<>();
    }

    // Composition: User controls the lifecycle of Subjects
    public Subject createSubject(String subjectCode, String subjectName) {
        Subject newSubject = new Subject(subjectCode, subjectName);
        this.subjects.add(newSubject);
        return newSubject;
    }

    public void deleteSubject(Subject subject) {
        // If user removes subject, all tasks/notes inside are logically dropped from user's scope
        this.subjects.remove(subject);
    }

    public void addXP(int points) {
        if (points > 0) {
            this.totalXP += points;
            System.out.println("XP Added! Total XP is now: " + this.totalXP);
        }
    }

    public List<Subject> getSubjects() { return subjects; }
    public String getUsername() { return username; }
    public String getEmail() { return email; }
    public int getTotalXP() { return totalXP; }
}

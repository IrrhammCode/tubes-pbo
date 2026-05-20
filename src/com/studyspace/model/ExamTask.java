package com.studyspace.model;

import java.time.LocalDateTime;
import java.util.List;

public class ExamTask extends Task {
    private List<String> syllabusList;

    public ExamTask(String activityId, String title, LocalDateTime deadline, int difficultyLevel, List<String> syllabusList) {
        super(activityId, title, deadline, difficultyLevel);
        this.syllabusList = syllabusList;
    }

    public List<String> getSyllabusList() { return syllabusList; }
    public void setSyllabusList(List<String> syllabusList) { this.syllabusList = syllabusList; }
}

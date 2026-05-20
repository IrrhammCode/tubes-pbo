package com.studyspace;

import com.studyspace.controller.ProgressTracker;
import com.studyspace.controller.ReminderManager;
import com.studyspace.model.*;
import java.time.LocalDateTime;
import java.util.Arrays;

public class Main {
    public static void main(String[] args) {
        System.out.println("=== StudySpace Backend Initialized ===");

        // 1. Core Entity & Composition
        User user = new User("ahmad123", "ahmad@student.telkomuniversity.ac.id");
        Subject pbo = user.createSubject("IF-2030", "Pemrograman Berorientasi Objek");
        Subject matdis = user.createSubject("IF-2026", "Matematika Diskret");

        // 2. Activity Hierarchy & Polymorphism
        Task pboTask1 = new AssignmentTask("T1", "Tubes PBO Bab 1", LocalDateTime.now().plusHours(48), 4, "http://github.com/tubes");
        Task pboExam = new ExamTask("E1", "Ujian Tengah Semester PBO", LocalDateTime.now().plusHours(12), 5, Arrays.asList("Inheritance", "Polymorphism"));
        
        Task matdisTask = new AssignmentTask("T2", "Latihan Logika Proposisi", LocalDateTime.now().plusHours(120), 2, "http://drive.google.com/soal");

        // 3. Aggregation (Adding tasks to subject)
        pbo.addTask(pboTask1);
        pbo.addTask(pboExam);
        matdis.addTask(matdisTask);

        // Add a Note (Polymorphism)
        Note summaryNote = new TextNote("N1", "Rangkuman OOP", "OOP adalah paradigma...");
        pbo.addNote(summaryNote);

        // 4. ReminderManager (Priority Queue Logic)
        ReminderManager reminderManager = new ReminderManager();
        reminderManager.addTaskToQueue(pboTask1);
        reminderManager.addTaskToQueue(pboExam);
        reminderManager.addTaskToQueue(matdisTask);

        // Priority calculation demo:
        // pboExam has high difficulty (5) and short time (12h) -> Highest priority
        // matdisTask has low difficulty (2) and long time (120h) -> Lowest priority
        reminderManager.displayQueue();

        System.out.println("\nMost urgent task is: " + reminderManager.getMostUrgentTask().getTitle());

        // 5. Gamification Feature
        System.out.println("\nCompleting task...");
        pboTask1.markAsCompleted();
        user.addXP(100); // addXP points logic

        // 6. ProgressTracker
        System.out.println();
        ProgressTracker tracker = new ProgressTracker();
        tracker.generatePerformanceReport(pbo);
    }
}

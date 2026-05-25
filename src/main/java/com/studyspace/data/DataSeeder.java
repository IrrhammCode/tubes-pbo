package com.studyspace.data;

import com.studyspace.controller.ReminderManager;
import com.studyspace.model.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;

@Component
public class DataSeeder implements CommandLineRunner {

    private final DataStore dataStore;
    private final ReminderManager reminderManager;

    public DataSeeder(DataStore dataStore, ReminderManager reminderManager) {
        this.dataStore = dataStore;
        this.reminderManager = reminderManager;
    }

    @Override
    public void run(String... args) {
        // === Create User ===
        User user = new User("Ahmad", "ahmad@student.telkomuniversity.ac.id");
        user.setTotalXP(4250);
        user.setPomodoroSessionsCount(42);
        user.setTotalFocusMinutes(2520);
        dataStore.setUser(user);

        // === Create Subjects ===
        Subject matdis = new Subject("IF-2026", "Matematika Diskret");
        Subject pbo = new Subject("IF-2030", "PBO (Java)");
        Subject bio = new Subject("KU-1011", "Biologi Dasar");

        dataStore.getSubjects().addAll(List.of(matdis, pbo, bio));
        user.getSubjects().addAll(List.of(matdis, pbo, bio));

        // === Matematika Diskret Tasks (target ~90% = 9/10 completed) ===
        ExamTask ujianMat1 = new ExamTask("TASK-001", "Ujian Matematika 1",
                LocalDateTime.now().plusDays(2), 5,
                Arrays.asList("Logika Proposisi", "Himpunan", "Relasi"));
        ujianMat1.setStatus("TODO");
        matdis.addTask(ujianMat1);

        AssignmentTask latihanLogika = new AssignmentTask("TASK-002", "Latihan Logika Proposisi",
                LocalDateTime.now().minusDays(5), 2, null);
        latihanLogika.markAsCompleted();
        matdis.addTask(latihanLogika);

        // Additional completed Matematika tasks for ~90%
        for (int i = 3; i <= 9; i++) {
            AssignmentTask t = new AssignmentTask("TASK-MAT-" + i, "Tugas Matdis " + i,
                    LocalDateTime.now().minusDays(i), 2 + (i % 3), null);
            t.markAsCompleted();
            matdis.addTask(t);
        }

        // One more incomplete to reach 10 tasks total, 9 completed
        AssignmentTask matPending = new AssignmentTask("TASK-MAT-10", "Tugas Matdis Tambahan",
                LocalDateTime.now().plusDays(5), 3, null);
        matPending.setStatus("TODO");
        matdis.addTask(matPending);

        // === PBO Tasks (target ~65% = 13/20 completed) ===
        AssignmentTask tubesPBO1 = new AssignmentTask("TASK-010", "Tubes PBO Bab 1",
                LocalDateTime.now().plusHours(48), 4, "https://drive.google.com/tubes-pbo-1");
        tubesPBO1.setStatus("TODO");
        pbo.addTask(tubesPBO1);

        ExamTask utsPBO = new ExamTask("TASK-011", "UTS PBO",
                LocalDateTime.now().plusHours(12), 5,
                Arrays.asList("OOP Concepts", "Inheritance", "Polymorphism", "Design Patterns"));
        utsPBO.setStatus("IN_REVIEW");
        pbo.addTask(utsPBO);

        // Completed PBO tasks (13 total completed)
        for (int i = 1; i <= 13; i++) {
            AssignmentTask t = new AssignmentTask("TASK-PBO-C" + i, "PBO Praktikum " + i,
                    LocalDateTime.now().minusDays(i + 2), 2 + (i % 4), null);
            t.markAsCompleted();
            pbo.addTask(t);
        }

        // More incomplete PBO tasks to reach 20 total (2 already above + 13 completed = 15, need 5 more incomplete)
        for (int i = 1; i <= 5; i++) {
            AssignmentTask t = new AssignmentTask("TASK-PBO-P" + i, "PBO Tugas Lanjutan " + i,
                    LocalDateTime.now().plusDays(i + 3), 3, null);
            t.setStatus("TODO");
            pbo.addTask(t);
        }

        // === Biologi Tasks (target ~30% = 3/10 completed) ===
        AssignmentTask laporanBio = new AssignmentTask("TASK-020", "Laporan Biologi",
                LocalDateTime.now().plusDays(6), 3, "https://drive.google.com/laporan-bio");
        laporanBio.setStatus("IN_PROGRESS");
        bio.addTask(laporanBio);

        // Completed Bio tasks (3 total)
        for (int i = 1; i <= 3; i++) {
            AssignmentTask t = new AssignmentTask("TASK-BIO-C" + i, "Praktikum Biologi " + i,
                    LocalDateTime.now().minusDays(i + 5), 2, null);
            t.markAsCompleted();
            bio.addTask(t);
        }

        // Incomplete Bio tasks (to reach 10 total: 1 + 3 + 6 = 10)
        for (int i = 1; i <= 6; i++) {
            AssignmentTask t = new AssignmentTask("TASK-BIO-P" + i, "Tugas Biologi " + i,
                    LocalDateTime.now().plusDays(i + 1), 2 + (i % 3), null);
            t.setStatus("TODO");
            bio.addTask(t);
        }

        // === Cross-subject tasks ===
        AssignmentTask tugasSejarah = new AssignmentTask("TASK-030", "Tugas Sejarah",
                LocalDateTime.now().plusDays(4), 3, null);
        tugasSejarah.setStatus("IN_PROGRESS");

        AssignmentTask esaiBahasa = new AssignmentTask("TASK-031", "Esai Bahasa Inggris",
                LocalDateTime.now().minusDays(2), 2, null);
        esaiBahasa.markAsCompleted();

        // === Collect all tasks into DataStore ===
        dataStore.getAllTasks().addAll(matdis.getTasks());
        dataStore.getAllTasks().addAll(pbo.getTasks());
        dataStore.getAllTasks().addAll(bio.getTasks());
        dataStore.getAllTasks().add(tugasSejarah);
        dataStore.getAllTasks().add(esaiBahasa);

        // === Create Notes ===
        TextNote textNote = new TextNote("NOTE-001", "Catatan OOP",
                "Object-Oriented Programming terdiri dari 4 pilar utama:\n" +
                "1. Encapsulation\n2. Inheritance\n3. Polymorphism\n4. Abstraction");
        pbo.addNote(textNote);

        ChecklistNote checklistNote = new ChecklistNote("NOTE-002", "Checklist Persiapan UTS PBO",
                Arrays.asList("Review materi Inheritance", "Latihan soal Polymorphism",
                        "Buat ringkasan Design Patterns", "Mock test OOP"));
        pbo.addNote(checklistNote);

        dataStore.getAllNotes().add(textNote);
        dataStore.getAllNotes().add(checklistNote);

        // === Initialize ReminderManager with incomplete tasks ===
        for (Task task : dataStore.getAllTasks()) {
            reminderManager.addTaskToQueue(task);
        }

        System.out.println("=== StudySpace Data Seeder ===");
        System.out.println("User: " + user.getUsername() + " (Level " + user.getLevel() + ")");
        System.out.println("Subjects: " + dataStore.getSubjects().size());
        System.out.println("Total Tasks: " + dataStore.getAllTasks().size());
        System.out.println("Total Notes: " + dataStore.getAllNotes().size());
        System.out.println("Priority Queue initialized.");
        reminderManager.displayQueue();
        System.out.println("==============================");
    }
}

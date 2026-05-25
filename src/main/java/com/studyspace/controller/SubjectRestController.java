package com.studyspace.controller;

import com.studyspace.data.DataStore;
import com.studyspace.model.Subject;
import com.studyspace.model.Task;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/subjects")
public class SubjectRestController {

    private final DataStore dataStore;
    private final ProgressTracker progressTracker;

    public SubjectRestController(DataStore dataStore, ProgressTracker progressTracker) {
        this.dataStore = dataStore;
        this.progressTracker = progressTracker;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getAllSubjects() {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Subject subject : dataStore.getSubjects()) {
            Map<String, Object> info = new HashMap<>();
            info.put("subjectCode", subject.getSubjectCode());
            info.put("subjectName", subject.getSubjectName());
            info.put("taskCount", subject.getTasks().size());
            info.put("noteCount", subject.getNotes().size());
            result.add(info);
        }
        return ResponseEntity.ok(result);
    }

    @GetMapping("/progress")
    public ResponseEntity<List<Map<String, Object>>> getAllProgress() {
        List<Map<String, Object>> progressList = dataStore.getSubjects().stream()
                .map(progressTracker::getSubjectProgressData)
                .collect(Collectors.toList());
        return ResponseEntity.ok(progressList);
    }

    @GetMapping("/{code}")
    public ResponseEntity<?> getSubjectByCode(@PathVariable String code) {
        Subject subject = dataStore.findSubjectByCode(code);
        if (subject == null) {
            return ResponseEntity.notFound().build();
        }

        Map<String, Object> response = new HashMap<>();
        response.put("subjectCode", subject.getSubjectCode());
        response.put("subjectName", subject.getSubjectName());
        response.put("taskCount", subject.getTasks().size());
        response.put("noteCount", subject.getNotes().size());
        response.put("completionPercentage", Math.round(progressTracker.calculateSubjectCompletion(subject)));

        return ResponseEntity.ok(response);
    }

    @GetMapping("/{code}/tasks")
    public ResponseEntity<?> getSubjectTasks(@PathVariable String code) {
        Subject subject = dataStore.findSubjectByCode(code);
        if (subject == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(subject.getTasks());
    }
}

package com.studyspace.controller;

import com.studyspace.data.DataStore;
import com.studyspace.model.PomodoroSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/pomodoro")
public class PomodoroRestController {

    private final DataStore dataStore;

    public PomodoroRestController(DataStore dataStore) {
        this.dataStore = dataStore;
    }

    @PostMapping("/start")
    public ResponseEntity<PomodoroSession> startSession(@RequestBody(required = false) Map<String, Object> body) {
        int duration = 25; // default pomodoro duration
        String linkedTaskId = null;

        if (body != null) {
            if (body.containsKey("durationMinutes")) {
                duration = (int) body.get("durationMinutes");
            }
            linkedTaskId = (String) body.get("linkedTaskId");
        }

        String sessionId = "POMO-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        PomodoroSession session = new PomodoroSession(sessionId, duration);

        if (linkedTaskId != null) {
            session.setLinkedTaskId(linkedTaskId);
        }

        dataStore.getPomodoroSessions().add(session);
        return ResponseEntity.ok(session);
    }

    @PostMapping("/complete")
    public ResponseEntity<?> completeSession(@RequestBody(required = false) Map<String, String> body) {
        // Find the most recent incomplete session
        PomodoroSession session = null;

        if (body != null && body.containsKey("sessionId")) {
            String sessionId = body.get("sessionId");
            session = dataStore.getPomodoroSessions().stream()
                    .filter(s -> s.getSessionId().equals(sessionId) && !s.isCompleted())
                    .findFirst()
                    .orElse(null);
        } else {
            // Find last incomplete session
            List<PomodoroSession> sessions = dataStore.getPomodoroSessions();
            for (int i = sessions.size() - 1; i >= 0; i--) {
                if (!sessions.get(i).isCompleted()) {
                    session = sessions.get(i);
                    break;
                }
            }
        }

        if (session == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "No active pomodoro session found"));
        }

        session.complete();
        dataStore.getUser().addXP(50);
        dataStore.getUser().setPomodoroSessionsCount(
                dataStore.getUser().getPomodoroSessionsCount() + 1);
        dataStore.getUser().setTotalFocusMinutes(
                dataStore.getUser().getTotalFocusMinutes() + session.getDurationMinutes());

        Map<String, Object> response = new HashMap<>();
        response.put("session", session);
        response.put("xpAwarded", 50);
        response.put("totalXP", dataStore.getUser().getTotalXP());
        response.put("pomodoroSessionsCount", dataStore.getUser().getPomodoroSessionsCount());

        return ResponseEntity.ok(response);
    }

    @GetMapping("/history")
    public ResponseEntity<List<PomodoroSession>> getTodaySessions() {
        LocalDate today = LocalDate.now();
        List<PomodoroSession> todaySessions = dataStore.getPomodoroSessions().stream()
                .filter(s -> s.getStartTime() != null && s.getStartTime().toLocalDate().equals(today))
                .collect(Collectors.toList());
        return ResponseEntity.ok(todaySessions);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getStats() {
        List<PomodoroSession> sessions = dataStore.getPomodoroSessions();

        long completedSessions = sessions.stream().filter(PomodoroSession::isCompleted).count();
        int totalFocusMinutes = dataStore.getUser().getTotalFocusMinutes();

        // Estimate break minutes: 5 min break per completed session
        long totalBreakMinutes = completedSessions * 5;

        Map<String, Object> response = new HashMap<>();
        response.put("completedSessions", completedSessions);
        response.put("totalFocusMinutes", totalFocusMinutes);
        response.put("totalBreakMinutes", totalBreakMinutes);
        response.put("totalSessionsToday", sessions.stream()
                .filter(s -> s.getStartTime() != null &&
                        s.getStartTime().toLocalDate().equals(LocalDate.now()))
                .count());

        return ResponseEntity.ok(response);
    }
}

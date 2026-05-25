package com.studyspace.controller;

import com.studyspace.data.DataStore;
import com.studyspace.model.Task;
import com.studyspace.model.User;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/user")
public class UserRestController {

    private final DataStore dataStore;

    public UserRestController(DataStore dataStore) {
        this.dataStore = dataStore;
    }

    @GetMapping
    public ResponseEntity<Map<String, Object>> getUser() {
        User user = dataStore.getUser();
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        Map<String, Object> response = new HashMap<>();
        response.put("username", user.getUsername());
        response.put("email", user.getEmail());
        response.put("totalXP", user.getTotalXP());
        response.put("level", user.getLevel());
        response.put("xpForNextLevel", user.getXpForNextLevel());
        response.put("levelProgressPercent", user.getLevelProgressPercent());
        response.put("pomodoroSessionsCount", user.getPomodoroSessionsCount());
        response.put("totalFocusMinutes", user.getTotalFocusMinutes());
        response.put("joinedDate", user.getJoinedDate());

        return ResponseEntity.ok(response);
    }

    @PutMapping
    public ResponseEntity<Map<String, Object>> updateUser(@RequestBody Map<String, String> body) {
        User user = dataStore.getUser();
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        if (body.containsKey("username")) {
            user.setUsername(body.get("username"));
        }
        if (body.containsKey("email")) {
            user.setEmail(body.get("email"));
        }

        Map<String, Object> response = new HashMap<>();
        response.put("username", user.getUsername());
        response.put("email", user.getEmail());
        response.put("message", "User updated successfully");

        return ResponseEntity.ok(response);
    }

    @PostMapping("/xp")
    public ResponseEntity<Map<String, Object>> addXP(@RequestBody Map<String, Integer> body) {
        User user = dataStore.getUser();
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        int points = body.getOrDefault("points", 0);
        user.addXP(points);

        Map<String, Object> response = new HashMap<>();
        response.put("totalXP", user.getTotalXP());
        response.put("level", user.getLevel());
        response.put("xpForNextLevel", user.getXpForNextLevel());
        response.put("levelProgressPercent", user.getLevelProgressPercent());
        response.put("pointsAdded", points);

        return ResponseEntity.ok(response);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getUserStats() {
        User user = dataStore.getUser();
        if (user == null) {
            return ResponseEntity.notFound().build();
        }

        long totalTasksCompleted = dataStore.getAllTasks().stream()
                .filter(Task::isCompleted)
                .count();

        int totalMinutes = user.getTotalFocusMinutes();
        int hours = totalMinutes / 60;
        int minutes = totalMinutes % 60;
        String formattedTime = hours + "h " + minutes + "m";

        Map<String, Object> response = new HashMap<>();
        response.put("totalTasksCompleted", totalTasksCompleted);
        response.put("totalFocusTime", formattedTime);
        response.put("totalFocusMinutes", totalMinutes);
        response.put("activeSubjects", dataStore.getSubjects().size());
        response.put("joinedDate", user.getJoinedDate());
        response.put("pomodoroSessionsCount", user.getPomodoroSessionsCount());
        response.put("totalXP", user.getTotalXP());
        response.put("level", user.getLevel());

        return ResponseEntity.ok(response);
    }
}

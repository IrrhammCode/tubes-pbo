CREATE DATABASE IF NOT EXISTS studyspace;
USE studyspace;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL,
    password VARCHAR(255) NOT NULL,
    totalXP INT DEFAULT 0,
    pomodoroSessionsCount INT DEFAULT 0,
    totalFocusMinutes INT DEFAULT 0,
    joinedDate VARCHAR(50) DEFAULT '2026'
);

CREATE TABLE IF NOT EXISTS subjects (
    subjectCode VARCHAR(20) PRIMARY KEY,
    subjectName VARCHAR(100) NOT NULL,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS tasks (
    activityId VARCHAR(50) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    taskType VARCHAR(50) NOT NULL, -- 'ASSIGNMENT' or 'EXAM'
    deadline DATETIME NOT NULL,
    difficultyLevel INT NOT NULL,
    isCompleted BOOLEAN DEFAULT FALSE,
    status VARCHAR(20) DEFAULT 'TODO', -- 'TODO', 'IN_PROGRESS', 'DONE'
    subjectCode VARCHAR(20),
    attachmentLink VARCHAR(255), -- for AssignmentTask
    syllabusList TEXT, -- for ExamTask, comma separated
    priorityScore DOUBLE DEFAULT 0, -- calculated from Prioritizable interface
    user_id INT,
    FOREIGN KEY (subjectCode) REFERENCES subjects(subjectCode) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS notes (
    activityId VARCHAR(50) PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    noteType VARCHAR(50) NOT NULL, -- 'TEXT_NOTE' or 'CHECKLIST_NOTE'
    lastModified DATETIME NOT NULL,
    content TEXT, -- for TextNote
    checklistItems TEXT, -- for ChecklistNote, JSON or comma separated
    subjectCode VARCHAR(20),
    user_id INT,
    FOREIGN KEY (subjectCode) REFERENCES subjects(subjectCode) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS pomodoro_sessions (
    sessionId VARCHAR(50) PRIMARY KEY,
    startTime DATETIME NOT NULL,
    endTime DATETIME,
    durationMinutes INT NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    user_id INT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert Default Admin User
INSERT IGNORE INTO users (id, username, email, password, totalXP, pomodoroSessionsCount, totalFocusMinutes, joinedDate) 
VALUES (1, 'admin', 'admin@studyspace.com', 'admin123', 2500, 12, 300, 'Agt 2026');

-- Insert Sample Subjects
INSERT IGNORE INTO subjects (subjectCode, subjectName, user_id) VALUES 
('IF101', 'Matematika Diskret', 1),
('IF102', 'Pemrograman Berorientasi Objek', 1),
('IF103', 'Biologi Dasar', 1);

-- Insert Sample Tasks
INSERT IGNORE INTO tasks (activityId, title, taskType, deadline, difficultyLevel, isCompleted, status, subjectCode, user_id) VALUES
('task-1', 'Tugas Besar PBO', 'ASSIGNMENT', DATE_ADD(NOW(), INTERVAL 2 DAY), 5, FALSE, 'IN_PROGRESS', 'IF102', 1),
('task-2', 'Kuis Aljabar Boolean', 'EXAM', DATE_ADD(NOW(), INTERVAL 1 DAY), 4, FALSE, 'TODO', 'IF101', 1),
('task-3', 'Laporan Praktikum Anatomi', 'ASSIGNMENT', DATE_SUB(NOW(), INTERVAL 1 DAY), 3, TRUE, 'DONE', 'IF103', 1);


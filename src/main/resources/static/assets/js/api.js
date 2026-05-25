/**
 * StudySpace - API Service Layer
 * Centralized fetch-based API calls for all backend endpoints.
 * Includes a Mock Mode fallback if the Spring Boot backend is unavailable.
 */

// URL Backend (jika tidak dijalankan dari localhost yang sama, ubah string ini)
// Jika kosong '', akan mengarah ke domain/host yang sama dengan frontend.
let API_BASE = window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1' 
    ? 'http://localhost:8080' 
    : '';

// ==========================================
// MOCK DATA & MOCK SERVICE
// Digunakan otomatis jika API gagal dijangkau (misal saat di Vercel tanpa backend)
// ==========================================

let isMockMode = false;

const MOCK_DB = {
    user: {
        username: "Ahmad",
        email: "ahmad@example.com",
        totalXP: 2500,
        level: 3,
        xpForNextLevel: 500,
        levelProgressPercent: 50,
        pomodoroSessionsCount: 12,
        totalFocusMinutes: 300,
        joinedDate: "Agt 2026"
    },
    subjects: [
        { subjectCode: "IF101", subjectName: "Matematika Diskret" },
        { subjectCode: "IF102", subjectName: "Pemrograman Berorientasi Objek" },
        { subjectCode: "IF103", subjectName: "Biologi Dasar" }
    ],
    tasks: [
        {
            activityId: "task-1",
            title: "Tugas Besar PBO",
            type: "ASSIGNMENT",
            deadline: new Date(Date.now() + 86400000 * 2).toISOString(), // +2 days
            difficultyLevel: 5,
            isCompleted: false,
            status: "IN_PROGRESS",
            subjectCode: "IF102",
            priorityScore: 100
        },
        {
            activityId: "task-2",
            title: "Kuis Aljabar Boolean",
            type: "EXAM",
            deadline: new Date(Date.now() + 86400000 * 1).toISOString(), // +1 day
            difficultyLevel: 4,
            isCompleted: false,
            status: "TODO",
            subjectCode: "IF101",
            priorityScore: 120
        },
        {
            activityId: "task-3",
            title: "Laporan Praktikum Anatomi",
            type: "ASSIGNMENT",
            deadline: new Date(Date.now() - 86400000).toISOString(), // -1 day (past due)
            difficultyLevel: 3,
            isCompleted: true,
            status: "DONE",
            subjectCode: "IF103",
            priorityScore: -1
        }
    ],
    pomodoroHistory: []
};

function generateId() {
    return 'id-' + Math.random().toString(36).substr(2, 9);
}

function calculatePriority(task) {
    if (task.isCompleted || task.status === 'DONE') return -1;
    const now = new Date();
    const deadline = new Date(task.deadline);
    let hours = (deadline - now) / (1000 * 60 * 60);
    if (hours <= 0) hours = 1;
    return (task.difficultyLevel / hours) * 100;
}

const MockService = {
    handleRequest: async (url, options) => {
        const method = options.method || 'GET';
        const body = options.body ? JSON.parse(options.body) : null;
        
        console.log(`[MOCK MODE] ${method} ${url}`);

        // --- TASKS ---
        if (url === '/api/tasks' && method === 'GET') {
            return MOCK_DB.tasks;
        }
        if (url === '/api/tasks/priority-queue' && method === 'GET') {
            const sorted = MOCK_DB.tasks
                .map(t => ({ ...t, priorityScore: calculatePriority(t) }))
                .filter(t => t.status !== 'DONE')
                .sort((a, b) => b.priorityScore - a.priorityScore);
            return sorted;
        }
        if (url === '/api/tasks' && method === 'POST') {
            const newTask = {
                ...body,
                activityId: generateId(),
                isCompleted: false,
                status: 'TODO',
                createdAt: new Date().toISOString()
            };
            MOCK_DB.tasks.push(newTask);
            return newTask;
        }
        if (url.match(/\/api\/tasks\/(.+)\/status/) && method === 'PUT') {
            const id = url.split('/')[3];
            const task = MOCK_DB.tasks.find(t => t.activityId === id);
            if (task) {
                task.status = body.status;
                if (body.status === 'DONE') {
                    task.isCompleted = true;
                    MOCK_DB.user.totalXP += (task.difficultyLevel * 10);
                }
                return task;
            }
            throw new Error("Task not found");
        }
        if (url.match(/\/api\/tasks\/(.+)\/complete/) && method === 'PUT') {
            const id = url.split('/')[3];
            const task = MOCK_DB.tasks.find(t => t.activityId === id);
            if (task) {
                task.status = 'DONE';
                task.isCompleted = true;
                MOCK_DB.user.totalXP += (task.difficultyLevel * 20); // Bonus
                return task;
            }
            throw new Error("Task not found");
        }
        if (url.match(/\/api\/tasks\/(.+)/) && method === 'DELETE') {
            const id = url.split('/')[3];
            MOCK_DB.tasks = MOCK_DB.tasks.filter(t => t.activityId !== id);
            return null;
        }

        // --- USER ---
        if (url === '/api/user' && method === 'GET') {
            MOCK_DB.user.level = Math.floor(MOCK_DB.user.totalXP / 1000) + 1;
            MOCK_DB.user.xpForNextLevel = 1000 - (MOCK_DB.user.totalXP % 1000);
            MOCK_DB.user.levelProgressPercent = (MOCK_DB.user.totalXP % 1000) / 10;
            return MOCK_DB.user;
        }
        if (url === '/api/user/stats' && method === 'GET') {
            return {
                completedTasksCount: MOCK_DB.tasks.filter(t => t.status === 'DONE').length,
                totalFocusMinutes: MOCK_DB.user.totalFocusMinutes,
                pomodoroSessionsCount: MOCK_DB.user.pomodoroSessionsCount
            };
        }

        // --- SUBJECTS ---
        if (url === '/api/subjects/progress' && method === 'GET') {
            return MOCK_DB.subjects.map(subj => {
                const subjTasks = MOCK_DB.tasks.filter(t => t.subjectCode === subj.subjectCode);
                const completed = subjTasks.filter(t => t.status === 'DONE').length;
                return {
                    subjectCode: subj.subjectCode,
                    subjectName: subj.subjectName,
                    totalTasks: subjTasks.length,
                    completedTasks: completed,
                    completionPercentage: subjTasks.length > 0 ? (completed / subjTasks.length) * 100 : 0
                };
            });
        }
        if (url === '/api/subjects' && method === 'GET') {
            return MOCK_DB.subjects;
        }

        // --- POMODORO ---
        if (url === '/api/pomodoro/start' && method === 'POST') {
            return { sessionId: generateId(), durationMinutes: body.durationMinutes || 25 };
        }
        if (url === '/api/pomodoro/complete' && method === 'POST') {
            MOCK_DB.user.totalFocusMinutes += 25;
            MOCK_DB.user.pomodoroSessionsCount += 1;
            MOCK_DB.user.totalXP += 50; // XP from pomodoro
            MOCK_DB.pomodoroHistory.push({ date: new Date().toISOString(), duration: 25 });
            return null;
        }
        if (url === '/api/pomodoro/history' && method === 'GET') {
            return MOCK_DB.pomodoroHistory;
        }
        if (url === '/api/pomodoro/stats' && method === 'GET') {
            return {
                todaySessions: MOCK_DB.pomodoroHistory.length,
                todayFocusMinutes: MOCK_DB.pomodoroHistory.length * 25
            };
        }

        console.warn(`[MOCK MODE] Unhandled mock route: ${method} ${url}`);
        return null;
    }
};

// ==========================================
// CORE API FETCH LOGIC
// ==========================================

/**
 * Generic fetch wrapper with error handling & Mock Fallback.
 * @param {string} url
 * @param {object} options
 * @returns {Promise<any>}
 */
async function apiFetch(url, options = {}) {
    if (isMockMode) {
        return MockService.handleRequest(url, options);
    }

    try {
        const res = await fetch(`${API_BASE}${url}`, {
            headers: { 'Content-Type': 'application/json', ...options.headers },
            ...options,
        });

        if (!res.ok) {
            const errorBody = await res.text().catch(() => '');
            throw new Error(`API Error ${res.status}: ${errorBody || res.statusText}`);
        }

        if (res.status === 204 || options.method === 'DELETE' || url === '/api/pomodoro/complete') {
            return null;
        }

        return await res.json();
    } catch (err) {
        // Jika gagal koneksi (NetworkError) atau backend tidak merespons, fallback ke Mock Mode
        if (err.name === 'TypeError' || err.message.includes('Failed to fetch') || err.message.includes('NetworkError')) {
            console.warn(`[API] Connection failed to ${API_BASE}${url}. Switching to Mock Mode!`);
            
            // Tampilkan toast/notifikasi jika ada elemen notifikasi di UI (opsional)
            const alertBox = document.createElement('div');
            alertBox.style.position = 'fixed';
            alertBox.style.bottom = '20px';
            alertBox.style.right = '20px';
            alertBox.style.backgroundColor = '#ffcc00';
            alertBox.style.color = '#333';
            alertBox.style.padding = '10px 20px';
            alertBox.style.borderRadius = '5px';
            alertBox.style.zIndex = '9999';
            alertBox.style.boxShadow = '0 4px 6px rgba(0,0,0,0.1)';
            alertBox.style.fontWeight = 'bold';
            alertBox.innerText = '⚠️ Backend Offline. Menggunakan Mock Data.';
            if (!document.querySelector('.mock-alert')) {
                alertBox.className = 'mock-alert';
                document.body.appendChild(alertBox);
                setTimeout(() => alertBox.remove(), 5000);
            }

            isMockMode = true;
            return MockService.handleRequest(url, options);
        }
        
        console.error(`[API] ${options.method || 'GET'} ${url} failed:`, err);
        throw err;
    }
}

const API = {
    tasks: {
        getAll: () => apiFetch('/api/tasks'),
        getById: (id) => apiFetch(`/api/tasks/${id}`),
        create: (taskData) => apiFetch('/api/tasks', { method: 'POST', body: JSON.stringify(taskData) }),
        updateStatus: (id, status) => apiFetch(`/api/tasks/${id}/status`, { method: 'PUT', body: JSON.stringify({ status }) }),
        complete: (id) => apiFetch(`/api/tasks/${id}/complete`, { method: 'PUT' }),
        delete: (id) => apiFetch(`/api/tasks/${id}`, { method: 'DELETE' }),
        getPriorityQueue: () => apiFetch('/api/tasks/priority-queue'),
    },
    user: {
        get: () => apiFetch('/api/user'),
        update: (data) => apiFetch('/api/user', { method: 'PUT', body: JSON.stringify(data) }),
        getStats: () => apiFetch('/api/user/stats'),
    },
    subjects: {
        getAll: () => apiFetch('/api/subjects'),
        getProgress: () => apiFetch('/api/subjects/progress'),
        getTasks: (code) => apiFetch(`/api/subjects/${code}/tasks`),
    },
    pomodoro: {
        start: (durationMinutes = 25) => apiFetch('/api/pomodoro/start', { method: 'POST', body: JSON.stringify({ durationMinutes }) }),
        complete: () => apiFetch('/api/pomodoro/complete', { method: 'POST' }),
        getHistory: () => apiFetch('/api/pomodoro/history'),
        getStats: () => apiFetch('/api/pomodoro/stats'),
    },
};

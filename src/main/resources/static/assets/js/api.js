/**
 * StudySpace - API Service Layer
 * Centralized fetch-based API calls for all backend endpoints.
 */

const API_BASE = '';

/**
 * Generic fetch wrapper with error handling.
 * @param {string} url
 * @param {object} options
 * @returns {Promise<any>}
 */
async function apiFetch(url, options = {}) {
    try {
        const res = await fetch(`${API_BASE}${url}`, {
            headers: { 'Content-Type': 'application/json', ...options.headers },
            ...options,
        });

        if (!res.ok) {
            const errorBody = await res.text().catch(() => '');
            throw new Error(`API Error ${res.status}: ${errorBody || res.statusText}`);
        }

        // DELETE and 204 responses return no content
        if (res.status === 204 || options.method === 'DELETE') {
            return null;
        }

        return await res.json();
    } catch (err) {
        console.error(`[API] ${options.method || 'GET'} ${url} failed:`, err);
        throw err;
    }
}

const API = {
    // ── Tasks ────────────────────────────────────────────────────────────
    tasks: {
        getAll: () => apiFetch('/api/tasks'),

        getById: (id) => apiFetch(`/api/tasks/${id}`),

        create: (taskData) =>
            apiFetch('/api/tasks', {
                method: 'POST',
                body: JSON.stringify(taskData),
            }),

        updateStatus: (id, status) =>
            apiFetch(`/api/tasks/${id}/status`, {
                method: 'PUT',
                body: JSON.stringify({ status }),
            }),

        complete: (id) =>
            apiFetch(`/api/tasks/${id}/complete`, { method: 'PUT' }),

        delete: (id) =>
            apiFetch(`/api/tasks/${id}`, { method: 'DELETE' }),

        getPriorityQueue: () => apiFetch('/api/tasks/priority-queue'),
    },

    // ── User ─────────────────────────────────────────────────────────────
    user: {
        get: () => apiFetch('/api/user'),

        update: (data) =>
            apiFetch('/api/user', {
                method: 'PUT',
                body: JSON.stringify(data),
            }),

        getStats: () => apiFetch('/api/user/stats'),
    },

    // ── Subjects ─────────────────────────────────────────────────────────
    subjects: {
        getAll: () => apiFetch('/api/subjects'),

        getProgress: () => apiFetch('/api/subjects/progress'),

        getTasks: (code) => apiFetch(`/api/subjects/${code}/tasks`),
    },

    // ── Pomodoro ─────────────────────────────────────────────────────────
    pomodoro: {
        start: (durationMinutes = 25) =>
            apiFetch('/api/pomodoro/start', {
                method: 'POST',
                body: JSON.stringify({ durationMinutes }),
            }),

        complete: () =>
            apiFetch('/api/pomodoro/complete', { method: 'POST' }),

        getHistory: () => apiFetch('/api/pomodoro/history'),

        getStats: () => apiFetch('/api/pomodoro/stats'),
    },
};

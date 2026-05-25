/**
 * StudySpace - Main Application Logic
 * Detects page type and initializes the appropriate controller.
 * Depends on: api.js (must be loaded first)
 */

// ═══════════════════════════════════════════════════════════════════════════
// UTILITY / HELPER FUNCTIONS
// ═══════════════════════════════════════════════════════════════════════════

/** Format deadline to human-readable Indonesian string */
function formatDeadline(deadlineStr) {
    const deadline = new Date(deadlineStr);
    const now = new Date();
    const diffMs = deadline - now;
    const diffHours = Math.round(diffMs / (1000 * 60 * 60));
    const diffDays = Math.round(diffHours / 24);
    if (diffDays <= 0) return 'Terlambat';
    if (diffDays === 1) return '1 hari';
    return `${diffDays} hari`;
}

/** Format a Date object as "dd Mon" (e.g. "15 Okt") */
function formatDateShort(dateStr) {
    const d = new Date(dateStr);
    const months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agt','Sep','Okt','Nov','Des'];
    return `${d.getDate()} ${months[d.getMonth()]}`;
}

/** Get urgency CSS class based on deadline proximity */
function getUrgencyClass(deadlineStr) {
    const deadline = new Date(deadlineStr);
    const now = new Date();
    const diffDays = Math.round((deadline - now) / (1000 * 60 * 60 * 24));
    if (diffDays <= 2) return 'danger';
    if (diffDays <= 5) return 'warning';
    return 'success';
}

/** Get urgency icon based on class */
function getUrgencyIcon(urgencyClass) {
    if (urgencyClass === 'danger') return 'fa-solid fa-triangle-exclamation';
    if (urgencyClass === 'warning') return 'fa-regular fa-clock';
    return 'fa-regular fa-circle-check';
}

/** Get difficulty label from numeric level */
function getDifficultyLabel(level) {
    if (level >= 4) return 'Tinggi';
    if (level >= 3) return 'Sedang';
    return 'Rendah';
}

/** Get difficulty CSS class name */
function getDifficultyClass(level) {
    if (level >= 4) return 'diff-high';
    if (level >= 3) return 'diff-med';
    return 'diff-low';
}

/** Get status badge HTML */
function getStatusBadge(status) {
    const map = {
        'TODO':        '<span class="badge-status badge-todo">Belum Mulai</span>',
        'IN_PROGRESS': '<span class="badge-status badge-progress">Sedang Dikerjakan</span>',
        'IN_REVIEW':   '<span class="badge-status badge-progress">Dalam Peninjauan</span>',
        'DONE':        '<span class="badge-status badge-done">Selesai</span>',
    };
    return map[status] || '<span class="badge-status badge-todo">-</span>';
}

/** Show a toast notification */
function showToast(message, type = 'success') {
    const container = document.getElementById('toast-container');
    if (!container) return;

    const colors = {
        success: 'var(--success)',
        danger:  'var(--danger)',
        warning: 'var(--warning)',
        info:    'var(--accent-indigo)',
    };

    const icons = {
        success: 'fa-circle-check',
        danger:  'fa-circle-xmark',
        warning: 'fa-triangle-exclamation',
        info:    'fa-circle-info',
    };

    const toast = document.createElement('div');
    toast.style.cssText = `
        background: var(--bg-card);
        border: 1px solid var(--border-color);
        border-left: 4px solid ${colors[type] || colors.info};
        border-radius: 12px;
        padding: 1rem 1.25rem;
        margin-bottom: 0.75rem;
        box-shadow: 0 4px 15px rgba(0,0,0,0.08);
        display: flex;
        align-items: center;
        gap: 0.75rem;
        font-weight: 600;
        font-size: 0.9rem;
        color: var(--text-main);
        animation: slideIn 0.3s ease;
        min-width: 280px;
    `;
    toast.innerHTML = `<i class="fa-solid ${icons[type] || icons.info}" style="color:${colors[type] || colors.info}"></i> ${message}`;
    container.appendChild(toast);

    setTimeout(() => {
        toast.style.transition = 'opacity 0.3s ease, transform 0.3s ease';
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(20px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

/** Safely set textContent of an element by ID */
function setText(id, text) {
    const el = document.getElementById(id);
    if (el) el.textContent = text;
}

/** Safely set innerHTML of an element by ID */
function setHTML(id, html) {
    const el = document.getElementById(id);
    if (el) el.innerHTML = html;
}

/** Populate the subject dropdown in the Add Task modal */
async function populateSubjectDropdown() {
    const select = document.getElementById('taskSubject');
    if (!select) return;
    try {
        const subjects = await API.subjects.getAll();
        select.innerHTML = subjects.map(s =>
            `<option value="${s.subjectCode}">${s.subjectName || s.subjectCode}</option>`
        ).join('');
    } catch {
        select.innerHTML = '<option value="">Gagal memuat mata kuliah</option>';
    }
}

/** Wire up difficulty slider label */
function wireDifficultySlider() {
    const slider = document.getElementById('taskDifficulty');
    const label  = document.getElementById('difficultyLabel');
    if (!slider || !label) return;
    slider.addEventListener('input', () => {
        const val = parseInt(slider.value);
        label.textContent = `${getDifficultyLabel(val)} (${val})`;
    });
}

/** Wire up Add Task form submission */
function wireAddTaskForm(onSuccess) {
    const form = document.getElementById('addTaskForm');
    const btn  = document.getElementById('submitTask');
    if (!form || !btn) return;

    btn.addEventListener('click', async () => {
        const title      = document.getElementById('taskTitle').value.trim();
        const type       = document.getElementById('taskType').value;
        const subject    = document.getElementById('taskSubject').value;
        const deadline   = document.getElementById('taskDeadline').value;
        const difficulty = parseInt(document.getElementById('taskDifficulty').value);

        if (!title || !deadline) {
            showToast('Nama tugas dan deadline harus diisi!', 'warning');
            return;
        }

        try {
            await API.tasks.create({
                title,
                type,
                subjectCode: subject,
                deadline: new Date(deadline).toISOString(),
                difficultyLevel: difficulty,
                status: 'TODO',
            });
            showToast('Tugas berhasil ditambahkan! 🎉', 'success');

            // Reset form & close modal
            form.reset();
            const modal = bootstrap.Modal.getInstance(document.getElementById('addTaskModal'));
            if (modal) modal.hide();

            if (typeof onSuccess === 'function') onSuccess();
        } catch {
            showToast('Gagal menambahkan tugas.', 'danger');
        }
    });
}

// ═══════════════════════════════════════════════════════════════════════════
// PAGE: DASHBOARD  (index.html)
// ═══════════════════════════════════════════════════════════════════════════
async function initDashboard() {
    // ── Greeting & user info ──
    try {
        const user = await API.user.get();
        setText('greeting', `Halo, ${user.username}! Siap untuk belajar hari ini?`);
        // Update topbar avatar
        const avatarImg = document.querySelector('.user-profile img');
        if (avatarImg) avatarImg.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username)}&background=4F46E5&color=fff`;
    } catch {
        setText('greeting', 'Halo! Siap untuk belajar hari ini?');
    }

    // ── Subject progress card ──
    try {
        const progress = await API.subjects.getProgress();
        if (progress && progress.length) {
            const total = progress.reduce((s, p) => s + p.completionPercentage, 0);
            const avg = Math.round(total / progress.length);
            const completedCount = progress.reduce((s, p) => s + p.completedTasks, 0);
            const totalCount = progress.reduce((s, p) => s + p.totalTasks, 0);

            setText('progress-percentage', `${avg}%`);
            const bar = document.getElementById('progress-bar');
            if (bar) {
                bar.style.width = `${avg}%`;
                bar.setAttribute('aria-valuenow', avg);
            }
            setText('progress-text', `${completedCount} dari ${totalCount} target minggu ini tercapai`);
        }
    } catch { /* keep defaults */ }

    // ── Upcoming tasks ──
    try {
        const tasks = await API.tasks.getPriorityQueue();
        const upcoming = tasks.filter(t => t.status !== 'DONE').slice(0, 3);
        const ul = document.getElementById('upcoming-tasks');
        if (ul) {
            ul.innerHTML = upcoming.map(t => {
                const urg = getUrgencyClass(t.deadline);
                return `
                <li class="task-mini-item ${urg}">
                    <span><i class="${getUrgencyIcon(urg)} me-2"></i> ${t.title}</span>
                    <span class="text-${urg}" style="font-size: 0.8rem;">(${formatDeadline(t.deadline)})</span>
                </li>`;
            }).join('') || '<li class="task-mini-item text-muted">Tidak ada tugas mendekati deadline 🎉</li>';
        }

        // ── Task table ──
        const tbody = document.getElementById('task-table-body');
        if (tbody) {
            tbody.innerHTML = tasks.map(t => `
                <tr data-task-id="${t.activityId}">
                    <td>${t.title}</td>
                    <td>${t.subjectCode || '-'}</td>
                    <td>${formatDateShort(t.deadline)} (${formatDeadline(t.deadline)})</td>
                    <td>
                        <div style="font-size: 0.85rem;">${getDifficultyLabel(t.difficultyLevel)}</div>
                        <div class="diff-bar-container"><div class="${getDifficultyClass(t.difficultyLevel)}"></div></div>
                    </td>
                    <td>${getStatusBadge(t.status)}</td>
                    <td>
                        <button class="icon-btn me-2 text-success btn-complete" title="Selesaikan"><i class="fa-regular fa-circle-check"></i></button>
                        <button class="icon-btn text-danger btn-delete" title="Hapus"><i class="fa-regular fa-trash-can"></i></button>
                    </td>
                </tr>`).join('') || '<tr><td colspan="6" class="text-center text-muted">Belum ada tugas.</td></tr>';

            wireTableActions(tbody);
        }
    } catch { /* keep empty */ }

    // ── Pomodoro mini widget ──
    initMiniPomodoro();

    // ── Floating rest widget ──
    wireFloatingWidget();

    // ── Add Task button ──
    document.querySelectorAll('.btn-primary').forEach(btn => {
        if (btn.textContent.includes('Tambah Tugas')) {
            btn.setAttribute('data-bs-toggle', 'modal');
            btn.setAttribute('data-bs-target', '#addTaskModal');
        }
    });

    populateSubjectDropdown();
    wireDifficultySlider();
    wireAddTaskForm(() => initDashboard());
}

/** Wire complete/delete buttons in a task table tbody */
function wireTableActions(tbody) {
    tbody.querySelectorAll('.btn-complete').forEach(btn => {
        btn.addEventListener('click', async () => {
            const row = btn.closest('tr');
            const id = row?.dataset.taskId;
            if (!id) return;
            try {
                await API.tasks.complete(id);
                showToast('Tugas selesai! +XP 🎉', 'success');
                const badge = row.querySelector('.badge-status');
                if (badge) { badge.textContent = 'Selesai'; badge.className = 'badge-status badge-done'; }
            } catch { showToast('Gagal menyelesaikan tugas.', 'danger'); }
        });
    });

    tbody.querySelectorAll('.btn-delete').forEach(btn => {
        btn.addEventListener('click', async () => {
            const row = btn.closest('tr');
            const id = row?.dataset.taskId;
            if (!id || !confirm('Hapus tugas ini?')) return;
            try {
                await API.tasks.delete(id);
                row.style.opacity = '0.3';
                setTimeout(() => row.remove(), 400);
                showToast('Tugas dihapus.', 'info');
            } catch { showToast('Gagal menghapus tugas.', 'danger'); }
        });
    });
}

/** Dashboard mini pomodoro timer */
function initMiniPomodoro() {
    const circle = document.getElementById('mini-timer');
    const startBtn = document.getElementById('mini-pomo-start');
    const sessionLabel = document.getElementById('mini-pomo-session');
    if (!circle || !startBtn) return;

    let seconds = 25 * 60;
    let interval = null;
    let running = false;

    function render() {
        const m = Math.floor(seconds / 60).toString().padStart(2, '0');
        const s = (seconds % 60).toString().padStart(2, '0');
        circle.textContent = `${m}:${s}`;
    }

    startBtn.addEventListener('click', async () => {
        if (running) {
            clearInterval(interval);
            running = false;
            startBtn.textContent = 'Mulai';
            return;
        }
        running = true;
        startBtn.textContent = 'Berhenti';
        try { await API.pomodoro.start(25); } catch { /* ok */ }
        interval = setInterval(async () => {
            seconds--;
            render();
            if (seconds <= 0) {
                clearInterval(interval);
                running = false;
                startBtn.textContent = 'Mulai';
                try { await API.pomodoro.complete(); } catch { /* ok */ }
                showToast('Sesi Pomodoro selesai! 🎉', 'success');
                seconds = 25 * 60;
                render();
            }
        }, 1000);
    });
}

/** Floating rest widget close/skip */
function wireFloatingWidget() {
    const widget = document.querySelector('.floating-widget');
    if (!widget) return;
    const closeBtn = widget.querySelector('.btn-close');
    if (closeBtn) closeBtn.addEventListener('click', () => widget.style.display = 'none');
    const skipBtn = widget.querySelector('.btn-outline');
    if (skipBtn) skipBtn.addEventListener('click', () => { widget.style.display = 'none'; });
}


// ═══════════════════════════════════════════════════════════════════════════
// PAGE: TASK BOARD  (task-board.html)
// ═══════════════════════════════════════════════════════════════════════════
async function initTaskBoard() {
    const columnMap = {
        'TODO':        'kanban-todo',
        'IN_PROGRESS': 'kanban-progress',
        'IN_REVIEW':   'kanban-review',
        'DONE':        'kanban-done',
    };

    const nextStatus = {
        'TODO':        'IN_PROGRESS',
        'IN_PROGRESS': 'IN_REVIEW',
        'IN_REVIEW':   'DONE',
    };

    try {
        const tasks = await API.tasks.getAll();

        // Clear columns
        Object.values(columnMap).forEach(id => {
            const col = document.getElementById(id);
            if (col) col.innerHTML = '';
        });

        // Group & render
        tasks.forEach(task => {
            const colId = columnMap[task.status] || columnMap['TODO'];
            const col = document.getElementById(colId);
            if (!col) return;

            const urg = getUrgencyClass(task.deadline);
            const isDone = task.status === 'DONE';

            const card = document.createElement('div');
            card.className = `task-card${isDone ? ' border-success border-opacity-50' : ''}`;
            card.dataset.taskId = task.activityId;
            card.innerHTML = `
                <div class="task-card-title">${task.title}</div>
                <div class="task-card-subject">${task.subjectCode || '-'}
                    <span class="float-end text-${isDone ? 'success' : urg}">
                        ${isDone ? 'Selesai' : `<i class="fa-regular fa-clock"></i> ${formatDeadline(task.deadline)}`}
                    </span>
                </div>
                <div class="progress mb-3" style="height: 4px;">
                    <div class="progress-bar bg-${isDone ? 'success' : urg}" role="progressbar"
                         style="width: ${isDone ? 100 : (task.status === 'IN_REVIEW' ? 80 : (task.status === 'IN_PROGRESS' ? 50 : 20))}%"></div>
                </div>
                <div class="task-card-footer d-flex justify-content-between align-items-center">
                    <div>
                        <img src="https://ui-avatars.com/api/?name=${encodeURIComponent(task.title.charAt(0))}&background=random" class="rounded-circle" width="20" height="20">
                    </div>
                    <div class="d-flex gap-2">
                        ${!isDone && nextStatus[task.status] ? `<button class="icon-btn btn-move-next" title="Pindah ke ${nextStatus[task.status]}"><i class="fa-solid fa-arrow-right"></i></button>` : ''}
                        ${!isDone ? `<button class="icon-btn text-success btn-kanban-complete" title="Selesaikan"><i class="fa-regular fa-circle-check"></i></button>` : ''}
                        <button class="icon-btn text-danger btn-kanban-delete" title="Hapus"><i class="fa-regular fa-trash-can"></i></button>
                    </div>
                </div>
            `;

            // Move to next status
            const moveBtn = card.querySelector('.btn-move-next');
            if (moveBtn) {
                moveBtn.addEventListener('click', async () => {
                    const next = nextStatus[task.status];
                    if (!next) return;
                    try {
                        await API.tasks.updateStatus(task.activityId, next);
                        showToast(`Tugas dipindahkan ke ${next.replace('_', ' ')}`, 'info');
                        initTaskBoard(); // reload
                    } catch { showToast('Gagal memindahkan tugas.', 'danger'); }
                });
            }

            // Complete
            const completeBtn = card.querySelector('.btn-kanban-complete');
            if (completeBtn) {
                completeBtn.addEventListener('click', async () => {
                    try {
                        await API.tasks.complete(task.activityId);
                        showToast('Tugas selesai! +XP 🎉', 'success');
                        initTaskBoard();
                    } catch { showToast('Gagal menyelesaikan tugas.', 'danger'); }
                });
            }

            // Delete
            const deleteBtn = card.querySelector('.btn-kanban-delete');
            if (deleteBtn) {
                deleteBtn.addEventListener('click', async () => {
                    if (!confirm('Hapus tugas ini?')) return;
                    try {
                        await API.tasks.delete(task.activityId);
                        showToast('Tugas dihapus.', 'info');
                        card.remove();
                    } catch { showToast('Gagal menghapus tugas.', 'danger'); }
                });
            }

            col.appendChild(card);
        });

        // Show count in column headers
        Object.entries(columnMap).forEach(([status, colId]) => {
            const col = document.getElementById(colId);
            if (!col) return;
            const count = col.querySelectorAll('.task-card').length;
            const header = col.closest('.board-column')?.querySelector('.board-header');
            if (header) {
                const badge = header.querySelector('.col-count');
                if (badge) badge.textContent = count;
            }
        });

    } catch {
        showToast('Gagal memuat tugas.', 'danger');
    }

    // ── Add Task button ──
    document.querySelectorAll('.btn-primary').forEach(btn => {
        if (btn.textContent.includes('Tambah Tugas')) {
            btn.setAttribute('data-bs-toggle', 'modal');
            btn.setAttribute('data-bs-target', '#addTaskModal');
        }
    });

    populateSubjectDropdown();
    wireDifficultySlider();
    wireAddTaskForm(() => initTaskBoard());
}


// ═══════════════════════════════════════════════════════════════════════════
// PAGE: POMODORO  (pomodoro.html)
// ═══════════════════════════════════════════════════════════════════════════
async function initPomodoro() {
    const timeDisplay  = document.getElementById('pomo-time');
    const startBtn     = document.getElementById('pomo-start-btn');
    const resetBtn     = document.getElementById('pomo-reset-btn');
    const skipBtn      = document.getElementById('pomo-skip-btn');
    const sessionLabel = document.getElementById('pomo-session-label');
    const badgeLabel   = document.getElementById('pomo-badge');

    let focusMinutes = 25;
    let breakMinutes = 5;
    let longBreakMinutes = 15;
    let sessionsPerLong = 4;
    let currentSession = 1;
    let seconds = focusMinutes * 60;
    let interval = null;
    let running = false;
    let onBreak = false;

    function render() {
        const m = Math.floor(seconds / 60).toString().padStart(2, '0');
        const s = (seconds % 60).toString().padStart(2, '0');
        if (timeDisplay) timeDisplay.textContent = `${m}:${s}`;
        if (sessionLabel) sessionLabel.textContent = `Sesi ${currentSession} dari ${sessionsPerLong}`;
        if (badgeLabel) badgeLabel.textContent = onBreak ? 'ISTIRAHAT' : `FOKUS (SESI #${currentSession})`;
    }

    render();

    // Load stats
    try {
        const stats = await API.pomodoro.getStats();
        const statsEl = document.getElementById('pomo-stats');
        if (statsEl && stats) {
            const focusH = Math.floor((stats.totalFocusMinutes || 0) / 60);
            const focusM = (stats.totalFocusMinutes || 0) % 60;
            statsEl.innerHTML = `
                <div class="d-flex justify-content-between mb-3 border-bottom pb-2" style="border-color: var(--border-color) !important;">
                    <span class="text-muted">Sesi Fokus Selesai:</span>
                    <span class="fw-bold">${stats.completedSessions || 0}</span>
                </div>
                <div class="d-flex justify-content-between mb-3 border-bottom pb-2" style="border-color: var(--border-color) !important;">
                    <span class="text-muted">Total Waktu Fokus:</span>
                    <span class="fw-bold">${focusH}j ${focusM}m</span>
                </div>
                <div class="d-flex justify-content-between">
                    <span class="text-muted">Waktu Istirahat:</span>
                    <span class="fw-bold">${stats.totalBreakMinutes || 0}m</span>
                </div>
            `;
        }
    } catch { /* keep defaults */ }

    // Load history
    try {
        const history = await API.pomodoro.getHistory();
        const historyEl = document.getElementById('pomo-history');
        if (historyEl && history && history.length) {
            historyEl.innerHTML = history.map((h, i) => {
                const isLast = i === history.length - 1;
                const isFocus = h.type === 'FOCUS' || !h.type;
                return `
                <div class="timeline-item ${isFocus ? 'active' : 'break'} ${isLast ? 'border-0 pb-0' : ''}">
                    <div class="d-flex justify-content-between">
                        <span class="${isFocus ? 'fw-bold' : 'text-muted'}">${isFocus ? `Focus ${h.sessionNumber || (i+1)}` : 'Break'}</span>
                        <span class="text-muted" style="font-size: 0.85rem;"><i class="fa-regular fa-clock me-1"></i> ${h.duration || ''}</span>
                    </div>
                </div>`;
            }).join('');
        }
    } catch { /* keep defaults */ }

    // Timer controls
    if (startBtn) {
        startBtn.addEventListener('click', async () => {
            if (running) {
                clearInterval(interval);
                running = false;
                startBtn.textContent = onBreak ? 'Mulai Istirahat' : 'Mulai Sesi Fokus';
                return;
            }
            running = true;
            startBtn.textContent = 'Berhenti';

            if (!onBreak) {
                try { await API.pomodoro.start(focusMinutes); } catch { /* ok */ }
            }

            interval = setInterval(async () => {
                seconds--;
                render();
                if (seconds <= 0) {
                    clearInterval(interval);
                    running = false;

                    if (!onBreak) {
                        // Focus done
                        try { await API.pomodoro.complete(); } catch { /* ok */ }
                        showToast('Sesi Fokus Selesai! Waktunya istirahat. 🎉', 'success');
                        onBreak = true;
                        const isLong = currentSession % sessionsPerLong === 0;
                        seconds = (isLong ? longBreakMinutes : breakMinutes) * 60;
                        startBtn.textContent = 'Mulai Istirahat';
                    } else {
                        // Break done
                        showToast('Istirahat selesai! Kembali fokus. 💪', 'info');
                        onBreak = false;
                        currentSession++;
                        seconds = focusMinutes * 60;
                        startBtn.textContent = 'Mulai Sesi Fokus';
                    }
                    render();
                }
            }, 1000);
        });
    }

    if (resetBtn) {
        resetBtn.addEventListener('click', () => {
            clearInterval(interval);
            running = false;
            onBreak = false;
            currentSession = 1;
            seconds = focusMinutes * 60;
            if (startBtn) startBtn.textContent = 'Mulai Sesi Fokus';
            render();
        });
    }

    if (skipBtn) {
        skipBtn.addEventListener('click', () => {
            if (onBreak) {
                clearInterval(interval);
                running = false;
                onBreak = false;
                currentSession++;
                seconds = focusMinutes * 60;
                if (startBtn) startBtn.textContent = 'Mulai Sesi Fokus';
                render();
                showToast('Istirahat dilewati.', 'info');
            }
        });
    }

    // Timer settings
    const saveSettingsBtn = document.getElementById('pomo-save-settings');
    if (saveSettingsBtn) {
        saveSettingsBtn.addEventListener('click', () => {
            const fEl = document.getElementById('pomo-focus-min');
            const bEl = document.getElementById('pomo-break-min');
            const lEl = document.getElementById('pomo-long-break-min');
            const sEl = document.getElementById('pomo-sessions-count');
            if (fEl) focusMinutes = parseInt(fEl.value) || 25;
            if (bEl) breakMinutes = parseInt(bEl.value) || 5;
            if (lEl) longBreakMinutes = parseInt(lEl.value) || 15;
            if (sEl) sessionsPerLong = parseInt(sEl.value) || 4;
            if (!running) { seconds = focusMinutes * 60; render(); }
            showToast('Pengaturan disimpan.', 'success');
        });
    }
}


// ═══════════════════════════════════════════════════════════════════════════
// PAGE: PROGRESS  (progress.html)
// ═══════════════════════════════════════════════════════════════════════════
async function initProgress() {
    const subjectIcons = [
        { icon: 'fa-square-root-variable', color: 'var(--accent-cyan)' },
        { icon: 'fa-code',                 color: 'var(--accent-indigo)' },
        { icon: 'fa-microscope',           color: 'var(--danger)' },
        { icon: 'fa-book',                 color: 'var(--warning)' },
        { icon: 'fa-flask',                color: 'var(--success)' },
        { icon: 'fa-globe',                color: 'var(--accent-cyan)' },
    ];

    try {
        const progress = await API.subjects.getProgress();

        // Overall
        if (progress && progress.length) {
            const total = progress.reduce((s, p) => s + p.completionPercentage, 0);
            const avg = Math.round(total / progress.length);
            const overallEl = document.getElementById('overall-percentage');
            if (overallEl) overallEl.textContent = `${avg}%`;

            const overallBadge = document.getElementById('overall-badge');
            if (overallBadge) {
                if (avg >= 80) { overallBadge.textContent = 'Sangat Baik'; overallBadge.className = 'badge bg-success opacity-75'; }
                else if (avg >= 60) { overallBadge.textContent = 'Baik'; overallBadge.className = 'badge bg-warning opacity-75'; }
                else { overallBadge.textContent = 'Perlu Ditingkatkan'; overallBadge.className = 'badge bg-danger opacity-75'; }
            }
        }

        // Subject cards
        const container = document.getElementById('subject-cards');
        if (container && progress) {
            container.innerHTML = progress.map((sub, i) => {
                const style = subjectIcons[i % subjectIcons.length];
                const remaining = sub.totalTasks - sub.completedTasks;
                const pct = sub.completionPercentage;
                const gradEnd = pct >= 80 ? 'var(--success)' : (pct >= 50 ? 'var(--warning)' : 'var(--danger)');
                const remainColor = pct >= 80 ? '' : (pct >= 50 ? 'text-warning' : 'text-danger');
                return `
                <div class="col-md-6 col-lg-4">
                    <div class="custom-card">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <div class="d-flex align-items-center gap-3">
                                <div class="p-2 rounded" style="background: rgba(0,0,0,0.04); color: ${style.color};"><i class="fa-solid ${style.icon} fs-4"></i></div>
                                <div>
                                    <h6 class="mb-0 fw-bold">${sub.subjectName || sub.subjectCode}</h6>
                                    <small class="text-muted">${sub.subjectCode}</small>
                                </div>
                            </div>
                            <span class="fs-5 fw-bold text-main">${pct}%</span>
                        </div>
                        <div class="progress mb-2" style="height: 6px;">
                            <div class="progress-bar" role="progressbar" style="width: ${pct}%; background: linear-gradient(90deg, var(--accent-indigo), ${gradEnd});"></div>
                        </div>
                        <div class="d-flex justify-content-between text-muted" style="font-size: 0.8rem;">
                            <span>Tugas Selesai: ${sub.completedTasks}/${sub.totalTasks}</span>
                            <span class="${remainColor}">${remaining} Tugas Tersisa</span>
                        </div>
                    </div>
                </div>`;
            }).join('');
        }
    } catch {
        showToast('Gagal memuat data progress.', 'danger');
    }

    // Activity log from tasks
    try {
        const tasks = await API.tasks.getAll();
        const completedTasks = tasks
            .filter(t => t.status === 'DONE')
            .slice(0, 5);

        const tbody = document.getElementById('activity-table-body');
        if (tbody) {
            tbody.innerHTML = completedTasks.map(t => `
                <tr>
                    <td class="text-muted">${formatDateShort(t.deadline)}</td>
                    <td>Menyelesaikan <strong>"${t.title}"</strong></td>
                    <td>${t.subjectCode || '-'}</td>
                    <td><span class="text-success"><i class="fa-solid fa-arrow-trend-up me-1"></i> Selesai</span></td>
                </tr>`).join('') || '<tr><td colspan="4" class="text-center text-muted">Belum ada aktivitas.</td></tr>';
        }
    } catch { /* keep defaults */ }
}


// ═══════════════════════════════════════════════════════════════════════════
// PAGE: PROFILE  (profile.html)
// ═══════════════════════════════════════════════════════════════════════════
async function initProfile() {
    // User info
    try {
        const user = await API.user.get();
        setText('profile-name', user.username || 'User');
        setText('profile-email', user.email || '');
        setText('profile-xp', `${(user.totalXP || 0).toLocaleString()} XP`);
        setText('profile-level', user.level || 1);

        // Level progress
        const xpForNext = (user.level || 1) * 1000; // Approximate formula
        const xpInLevel = (user.totalXP || 0) % 1000;
        const pct = Math.round((xpInLevel / 1000) * 100);
        const remaining = 1000 - xpInLevel;
        setText('profile-level-progress', `${remaining} XP lagi`);
        const bar = document.getElementById('profile-level-bar');
        if (bar) {
            bar.style.width = `${pct}%`;
            bar.setAttribute('aria-valuenow', pct);
        }
        const levelLabel = document.getElementById('profile-level-label');
        if (levelLabel) levelLabel.textContent = `Progres Level ${(user.level || 1) + 1}`;

        // Avatar
        const avatar = document.querySelector('.profile-avatar');
        if (avatar) avatar.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username)}&background=4F46E5&color=fff&size=200`;
        const topAvatar = document.querySelector('.user-profile img');
        if (topAvatar) topAvatar.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(user.username)}&background=4F46E5&color=fff`;

        // Pre-fill form
        const usernameInput = document.getElementById('profileUsername');
        const emailInput = document.getElementById('profileEmail');
        if (usernameInput) usernameInput.value = user.username || '';
        if (emailInput) emailInput.value = user.email || '';
    } catch { /* keep defaults */ }

    // Stats
    try {
        const stats = await API.user.getStats();
        const el = document.getElementById('profile-stats');
        if (el && stats) {
            el.innerHTML = `
                <li class="task-mini-item">
                    <span class="text-muted">Total Tugas Selesai</span>
                    <span class="fw-bold">${stats.totalTasksCompleted || 0}</span>
                </li>
                <li class="task-mini-item">
                    <span class="text-muted">Waktu Fokus (Pomodoro)</span>
                    <span class="fw-bold">${stats.totalFocusTime || '0 Jam'}</span>
                </li>
                <li class="task-mini-item">
                    <span class="text-muted">Mata Kuliah Aktif</span>
                    <span class="fw-bold">${stats.activeSubjects || 0}</span>
                </li>
                <li class="task-mini-item">
                    <span class="text-muted">Bergabung Sejak</span>
                    <span class="fw-bold">${stats.joinedDate || '-'}</span>
                </li>
            `;
        }
    } catch { /* keep defaults */ }

    // Save profile
    const saveBtn = document.getElementById('profileSaveBtn');
    if (saveBtn) {
        saveBtn.addEventListener('click', async () => {
            const username = document.getElementById('profileUsername')?.value.trim();
            if (!username) { showToast('Username tidak boleh kosong.', 'warning'); return; }
            try {
                await API.user.update({ username });
                showToast('Profil berhasil disimpan!', 'success');
            } catch { showToast('Gagal menyimpan profil.', 'danger'); }
        });
    }
}


// ═══════════════════════════════════════════════════════════════════════════
// ROUTER - Detect page and initialize
// ═══════════════════════════════════════════════════════════════════════════
document.addEventListener('DOMContentLoaded', () => {
    const page = document.body.dataset.page;

    // Add toast animation style
    const style = document.createElement('style');
    style.textContent = `@keyframes slideIn { from { opacity:0; transform:translateX(20px); } to { opacity:1; transform:translateX(0); } }`;
    document.head.appendChild(style);

    switch (page) {
        case 'dashboard': initDashboard(); break;
        case 'taskboard': initTaskBoard(); break;
        case 'pomodoro':  initPomodoro();  break;
        case 'progress':  initProgress();  break;
        case 'profile':   initProfile();   break;
        default:
            console.log('StudySpace: Unknown page type, no init.');
    }
});

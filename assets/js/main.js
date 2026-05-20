/**
 * StudySpace - Main UI Interactions
 */

document.addEventListener('DOMContentLoaded', () => {
    console.log('StudySpace UI Loaded');

    // --- Pomodoro Timer Logic ---
    const timerDisplay = document.querySelector('.pomodoro-time');
    const miniTimerDisplay = document.querySelector('.pomodoro-circle');
    const startBtn = document.querySelector('.btn-primary'); // This might be ambiguous, let's be careful
    
    let timerInterval;
    let isRunning = false;
    let timeLeft = 25 * 60; // 25 minutes in seconds

    function updateTimerDisplay(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = seconds % 60;
        const formatted = `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
        
        if (timerDisplay) timerDisplay.textContent = formatted;
        if (miniTimerDisplay) miniTimerDisplay.textContent = formatted;
        
        // Update floating widget if it exists
        const floatingTime = document.querySelector('.floating-widget .time');
        if (floatingTime && isRunning) floatingTime.textContent = formatted;
    }

    function toggleTimer() {
        if (isRunning) {
            clearInterval(timerInterval);
            isRunning = false;
            const btn = document.querySelector('.btn-primary');
            if (btn) btn.textContent = 'Mulai Sesi Fokus';
        } else {
            isRunning = true;
            const btn = document.querySelector('.btn-primary');
            if (btn) btn.textContent = 'Berhenti';
            
            timerInterval = setInterval(() => {
                timeLeft--;
                updateTimerDisplay(timeLeft);
                
                if (timeLeft <= 0) {
                    clearInterval(timerInterval);
                    isRunning = false;
                    alert('Sesi Fokus Selesai! Waktunya istirahat.');
                    timeLeft = 25 * 60; // Reset
                    updateTimerDisplay(timeLeft);
                }
            }, 1000);
        }
    }

    // Find the specific Pomodoro Start Button
    const pomodoroBtns = document.querySelectorAll('.btn-primary');
    pomodoroBtns.forEach(btn => {
        if (btn.textContent.includes('Mulai')) {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                toggleTimer();
            });
        }
    });

    // --- Task Actions Mock ---
    const deleteBtns = document.querySelectorAll('.text-danger');
    deleteBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const row = btn.closest('tr') || btn.closest('.task-card');
            if (row && confirm('Hapus tugas ini?')) {
                row.style.opacity = '0.5';
                row.style.pointerEvents = 'none';
                setTimeout(() => row.remove(), 500);
            }
        });
    });

    const checkBtns = document.querySelectorAll('.text-success');
    checkBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            const row = btn.closest('tr');
            if (row) {
                const statusBadge = row.querySelector('.badge-status');
                if (statusBadge) {
                    statusBadge.textContent = 'Selesai';
                    statusBadge.className = 'badge-status badge-done';
                    alert('Selamat! Anda mendapatkan +100 XP');
                }
            }
        });
    });

    // --- Floating Widget Logic ---
    const closeWidget = document.querySelector('.floating-widget .btn-close');
    if (closeWidget) {
        closeWidget.addEventListener('click', () => {
            document.querySelector('.floating-widget').style.display = 'none';
        });
    }

    const skipBreakBtn = document.querySelector('.floating-widget .btn-outline');
    if (skipBreakBtn) {
        skipBreakBtn.addEventListener('click', () => {
            alert('Istirahat dilewati. Kembali ke mode fokus!');
            document.querySelector('.floating-widget').style.display = 'none';
        });
    }
});

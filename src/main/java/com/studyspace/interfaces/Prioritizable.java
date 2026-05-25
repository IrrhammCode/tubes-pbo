package com.studyspace.interfaces;

public interface Prioritizable {
    /**
     * Calculates the priority score based on deadline and difficulty.
     * @return priority score (higher score = higher priority)
     */
    double calculatePriorityScore();
}

package com.studyspace.interfaces;

public interface Exportable {
    /**
     * Exports the content into a specific format (e.g., Markdown, PDF).
     * @return exported string content
     */
    String exportContent();
}

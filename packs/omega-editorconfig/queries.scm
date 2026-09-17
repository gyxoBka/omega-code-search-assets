; --- editorconfig_semantics ---

(preamble
  (pair key: (property) @editorconfig.global.key
        value: (string) @editorconfig.global.value) @editorconfig.global.context)

(section
  (header (glob) @editorconfig.section.pattern)
  (pair key: (property) @editorconfig.setting.key
        value: (string) @editorconfig.setting.value) @editorconfig.setting.context) @editorconfig.section.context

; --- structural-fallback ---

; Supplemental structural fallback. Matches every named syntax node without claiming additional semantic capability.
; This is structural indexing only, not semantic completeness.

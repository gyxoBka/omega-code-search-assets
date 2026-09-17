; omega-ini
;
; INI is a configuration format with no standard: php.ini, tox.ini, setup.cfg,
; .gitconfig, .editorconfig, systemd units, MySQL's my.cnf, pip.conf. A file in
; this format states settings, optionally grouped under section headers, and
; nothing else. The questions asked of one are *where is this setting
; declared*, *what is it set to*, and *what sections does this file define*.
;
; There are three patterns, each rooted at one node, and each answers one of
; those. There is no pattern for the document, for comments, for the brackets
; or for the `=`: none of them names anything a question reaches. There is no
; pattern for containment either -- a setting written under a section header is
; already inside that section's declaration span, and the host derives the
; qualified name from the nesting.

; --- a section header: [client] ---
;
; The span is the whole section, so every setting written under the header lies
; inside this declaration. `section_name` carries the brackets; the name is the
; `text` between them.

(section
  . (section_name (text) @section.name)) @section

; --- a setting with a value: max_connections = 100 ---
;
; The one place a question about configuration lands. The value is short and
; authored, so it is carried with the key rather than stated separately.

(setting
  . (setting_name) @setting.name
  . (setting_value) @setting.value) @setting

; --- a setting written with no value: no_auto_abbrev= ---
;
; An empty value is how several dialects spell "present but unset", so the key
; is still declared. The trailing anchor is what separates this from the shape
; above: it holds only when `setting_name` is the last named child.

(setting
  . (setting_name) @empty.name
  .) @empty

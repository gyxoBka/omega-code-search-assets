; omega-editorconfig
;
; An `.editorconfig` file states editor and formatter settings for a project,
; grouped under section headers whose name is a file glob. It is read by every
; editor and by most linters and formatters, so the questions asked of one are:
; *which file patterns does this project configure*, *where is this setting
; declared*, and *what is it set to*.
;
; Three patterns, each rooted at one node, each answering one of those.
;
; There is no pattern for the document, for a comment, for the brackets or for
; the `=`: none of them names anything a question reaches. There is no pattern
; for containment either -- a setting written under a header lies inside that
; section's declaration span, and the host derives the qualified name from the
; nesting, so the preamble's `root = true` and a section's `indent_size = 4`
; are told apart by where they sit without a pattern per place. That is what
; the old Pack spent two of its two templates on.
;
; The glob's own sub-syntax -- `wildcard`, `brace_expansion`,
; `character_choice`, `character_range`, `integer_range`, `character_escape`
; -- is deliberately untouched. Those nodes describe how a pattern matches, not
; what it names, and no question reaches them; the glob is stated as authored
; and a guard says it is not expanded.

; --- a section header: [*.{js,py}] ---
;
; The span is the whole section, so every pair written under the header lies
; inside this declaration. `header` carries the brackets; the name is the
; `glob` between them. A section holds at most one header -- a second header
; starts a new section -- so this costs one match per section.

(section
  (header (glob) @section.glob)) @section

; --- a setting with a value: indent_style = space ---
;
; The one place a question about editor configuration lands. The value is a
; short authored token, so it is carried on the key rather than stated as a
; fact of its own. This pattern is rooted at `pair`, which is the same node in
; the preamble and in a section.

(pair
  key: (property) @setting.key
  value: (string) @setting.value) @setting

; --- a setting written with no value: indent_size = ---
;
; The grammar makes `value:` optional. The trailing anchor is what separates
; this from the shape above: it holds only when `property` is the last named
; child, so the key is still declared and nothing is invented for its value.

(pair
  key: (property) @empty.key
  .) @empty

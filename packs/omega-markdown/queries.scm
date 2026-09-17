; omega-markdown
;
; Markdown is the file format of a project's documentation: READMEs, design
; notes, ADRs, changelogs, guides. The questions asked of it are: where is this
; documented, what does this document point at, what language is this example
; written in, and what encloses the text an answer came from.
;
; This parser is the BLOCK grammar of tree-sitter-markdown. `inline` is a leaf:
; emphasis, code spans, inline links and autolinks are not in this tree at all.
; Every pattern below therefore states a block fact, and the coverage guards in
; rules.json say what the inline level hides.
;
; Containment is not stated as a pattern. The grammar already nests `section`
; inside `section`, and a section's extent is emitted once as a region.

; --- a section, named by its heading ---
;
; A `section` holds exactly one heading of its own; the headings below it live
; in its nested `section` children, so no anchor is needed and no pattern per
; depth. Two templates run over this one match: the heading is the declaration,
; the section is the region it covers.

(section
  [(atx_heading heading_content: (inline) @heading.name)
   (setext_heading heading_content: (paragraph (inline) @heading.name))] @heading) @section

; --- a link reference definition ---
;
; `[label]: ./guide.md "title"` is the one thing Markdown declares under a name
; that something else in the file refers to. The label is folded to lower case
; because a Markdown reference label is matched case-insensitively.
;
; The title is not captured: it is optional, and an attribute whose capture is
; unbound skips the whole template, which would drop every untitled definition.

(link_reference_definition
  (link_label) @linkdef.label
  (link_destination) @linkdef.destination) @linkdef

; --- a fenced code block that declares its language ---
;
; The block's own content is handed to that language's grammar by the injection
; below, so what is left to state here is the extent and which language it is.

(fenced_code_block
  (info_string (language) @code.language)) @code

; --- the term a table row documents ---
;
; Documentation tables are `name | meaning`: config keys, CLI flags, error
; codes, environment variables. The first cell of a body row is the term the row
; is about; the rest is prose. Anchored, so only the first cell is taken, and
; the header row is left alone because its first cell names the column, not a
; term.

(pipe_table_row . (pipe_table_cell) @table.term)

; --- what the document embeds ---
;
; No `#offset!` here: tree-sitter parses that directive into a bucket this
; runtime does not read, so a front-matter injection cannot have its fences
; trimmed. `---\n...\n---` is a valid YAML document with an explicit start
; marker, so the YAML injection is correct without trimming. `+++` is not valid
; TOML, so TOML front matter is not injected at all.

(fenced_code_block
  (info_string (language) @injection.language)
  (code_fence_content) @injection.content)

((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#set! injection.include-children))

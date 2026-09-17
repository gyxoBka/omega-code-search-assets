; omega-json5
;
; JSON5 is JSON written for people to edit: `.babelrc`, a bundler config, a
; game's data table, a tsconfig kept in the dialect that allows a comment. It
; declares nothing of its own -- no function, no type, no import, no name it
; defines for its own use. What it has is the key, and the key is what a
; question reaches: *where is this setting defined and to what*, *which
; package declares this dependency*, *which names does this list*.
;
; This Pack is a port of omega-json and states the same one construct: the
; object member, named by its key and carrying its value when the value is a
; scalar. A whole object is not an answer; it is the place the answers live.
; The keys inside it already lie inside its span, so the host derives
; `compilerOptions.strict` from the nesting and no pattern needs to say it.
;
; There is no pattern for the file, for the object, for the array, for
; containment, or for comments: none of them names anything a question could
; resolve to. There is no pattern keyed on a particular key spelling either --
; what `name`, `type` or `extends` means is the knowledge of the tool that
; reads the file, and that belongs in an overlay.
;
; Three differences from omega-json, all of them the grammar's:
;
;   * the member node is `member`, and its key field is `name:`, not `key:`;
;   * a key may be a bare `identifier` as well as a `string`, so the key field
;     is an alternation and both spellings feed one capture;
;   * `string` is a leaf here -- no `string_content`, no `escape_sequence` --
;     so a string carries its own quotes and there is nothing to anchor
;     between. The quotes are removed in the template instead, which handles
;     both `"k"` and `'k'` and leaves a bare identifier untouched.
;
; Trailing commas are anonymous punctuation and state nothing. Hex numbers,
; leading `+`/`-`, `Infinity` and `NaN` are all spellings of `number`, and
; reach the scalar pattern unchanged.

; --- a key set to a string: name: "my-package" ---
;
; The commonest shape in a config file. Both the key and the value are
; unquoted by the template.

(member
  name: [(string) (identifier)] @string_pair.name
  value: (string) @string_pair.value) @string_pair

; --- a key set to a number, a boolean or null: strict: true ---
;
; The same declaration; the value is the token's own text and needs no
; unquoting.

(member
  name: [(string) (identifier)] @scalar_pair.name
  value: [(number) (true) (false) (null)] @scalar_pair.value) @scalar_pair

; --- a key set to an object or an array: dependencies: { ... } ---
;
; The same declaration, stated without a value. What such a key is set to is
; the keys and the strings inside it, and each of those is its own emission;
; storing the compound's text here would store the same bytes again at every
; level of nesting.

(member
  name: [(string) (identifier)] @compound_pair.name
  value: [(object) (array)]) @compound_pair

; --- a string listed in an array: required: ["name", "age"] ---
;
; An array of strings is how JSON5 names things that live elsewhere: a
; required property, a workspace, a file to include, a plugin, an enum
; member. Stated under its unquoted text, it resolves by name against a
; declaration in the repository if there is one.

(array
  (string) @array.element)

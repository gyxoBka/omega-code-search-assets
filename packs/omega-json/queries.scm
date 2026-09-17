; omega-json
;
; JSON is where a project states what it is and what it needs: package.json,
; package-lock.json, tsconfig.json, .eslintrc.json, composer.json, a JSON
; Schema, an OpenAPI document, a test fixture. The language declares nothing
; of its own -- no function, no type, no import, no name it defines for its
; own use. What it has is the key, and the key is what a question reaches:
; *which package declares this dependency*, *where is this setting defined
; and to what*, *what does this schema require*, *which files does this list
; name*.
;
; So the Pack states one construct, the object pair, named by its key and
; carrying its value when the value is a scalar. A whole object is not an
; answer; it is the place the answers live. The keys inside it already lie
; inside its span, so the host derives `dependencies.react` from the nesting
; and no pattern needs to say it.
;
; There is no pattern for the document, for the object, for the array, for
; containment, for comments or for escape sequences: none of them names
; anything a question could resolve to. There is no pattern keyed on a
; particular key spelling either -- `$ref`, `paths`, `name`, `type` mean what
; the consuming tool says they mean, and that knowledge belongs in an
; overlay, not in the language Pack.
;
; Every string is matched with an anchor on both sides, so it is the whole
; string or nothing: a key spelled "a\nb" is three children, and matching
; `(string_content)` loosely would emit that pair twice under two half-names.

; --- a key set to a string: "name": "my-package" ---
;
; The commonest shape in every manifest and lock file. The name and the value
; are the string's content, so both are already unquoted.

(pair
  key: (string . (string_content) @string_pair.name .)
  value: (string . (string_content) @string_pair.value .)) @string_pair

; --- a key set to a number, a boolean or null: "strict": true ---
;
; The same declaration; the value is the token's own text.

(pair
  key: (string . (string_content) @scalar_pair.name .)
  value: [(number) (true) (false) (null)] @scalar_pair.value) @scalar_pair

; --- a key set to an object or an array: "dependencies": { ... } ---
;
; The same declaration, stated without a value. What such a key is set to is
; the keys and the strings inside it, and each of those is its own emission;
; storing the compound's text here would store the same bytes again at every
; level of nesting.

(pair
  key: (string . (string_content) @compound_pair.name .)
  value: [(object) (array)]) @compound_pair

; --- a string listed in an array: "required": ["name", "age"] ---
;
; An array of strings is how JSON names things that live elsewhere: a
; required property, a workspace, a file to include, a plugin, an enum
; member. Stated under its own text, it resolves by name against a
; declaration in the repository if there is one.

(array
  (string . (string_content) @array.element .))

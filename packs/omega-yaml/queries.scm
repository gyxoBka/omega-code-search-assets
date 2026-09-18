; omega-yaml
;
; YAML is where a project is configured and where its infrastructure is
; described: a Kubernetes manifest, a GitHub Actions workflow, a GitLab CI
; pipeline, docker-compose.yml, an Ansible playbook, an OpenAPI document,
; a Helm values file. The language declares nothing of its own -- no
; function, no type, no import -- and it has exactly two names that mean
; something inside the file itself: the anchor and the alias. Everything
; else a question can reach is the key.
;
; So the Pack states four things: the mapping key, named by itself and
; carrying its value when that value is a scalar; the scalar listed in a
; sequence; the anchor and the alias that refers to it; and the tag, which
; is the only place a YAML file names a construct outside itself.
;
; There is no pattern for the document, the mapping, the sequence, the
; sequence item, the comment or containment. A key nested under another key
; already lies inside that key's span, so `spec.template.metadata` is
; derived by the host from the nesting and no pattern needs to state it.
; The Pack it replaces stated that nesting with thirty-five patterns, one
; per shape of ancestry, each costing a match per tuple of pairs at that
; depth.
;
; There is no pattern keyed on a particular key spelling either. `kind`,
; `metadata`, `apiVersion`, `steps`, `image` mean what the tool reading the
; file says they mean; that knowledge is a framework overlay, not a fact
; about YAML.

; --- a key set to a scalar: image: nginx:1.25 ---
;
; The commonest shape in every manifest, workflow and playbook, and the one
; place the value is short enough and authored enough to be worth carrying
; with the key. Block and flow mappings are the same construct written two
; ways, so they are one pattern.

[(block_mapping_pair
   key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @scalar_pair.name)
   value: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @scalar_pair.value))
 (flow_pair
   key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @scalar_pair.name)
   value: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @scalar_pair.value))] @scalar_pair

; --- a key set to a mapping, a sequence, a block scalar or an alias ---
;
; The same declaration, stated without a value. What such a key is set to is
; the keys and the scalars inside it, and each of those is its own emission;
; storing the compound's text here would store the same bytes again at every
; level of nesting. A block scalar is excluded for the same reason with more
; force: `run: |` in a workflow and the body of a ConfigMap entry are whole
; scripts and files, and a name is not a place to put one.

[(block_mapping_pair
   key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @compound_pair.name)
   value: [(block_node) (flow_node [(flow_mapping) (flow_sequence) (alias)])])
 (flow_pair
   key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @compound_pair.name)
   value: (flow_node [(flow_mapping) (flow_sequence) (alias)]))] @compound_pair

; --- a scalar listed in a sequence ---
;
; A sequence of scalars is how YAML names things that live elsewhere: an
; image, a job that must run first, a file to include, a required property,
; a host. Stated under its own text, it resolves by name against a
; declaration in the repository if there is one. A sequence item that is
; itself a mapping is not stated here: its keys are.

[(block_sequence_item
   (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @sequence.element))
 (flow_sequence
   (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @sequence.element))]

; --- an anchor: &defaults ---
;
; The one name a YAML file declares for its own use.

(anchor (anchor_name) @anchor.name) @anchor

; --- an alias: *defaults, and the merge key <<: *defaults ---
;
; The `&` and `*` sigils are anonymous tokens in this grammar, so the name
; is already stripped and an alias resolves onto its anchor by name.

(alias (alias_name) @alias.name) @alias

; --- a tag: !Ref, !include, !ruby/object:Foo ---
;
; A tag is the only syntax in which a YAML file names a construct outside
; itself, and in CloudFormation, Home Assistant and Rails fixtures it is the
; construct that matters. The core schema tags -- !!str, !!int, !!map -- name
; nothing a repository declares, so they are excluded.

((tag) @tag.name
 (#not-match? @tag.name "^!!"))

; --- a %TAG shorthand directive ---
;
; The declaration side of a handle-prefixed tag.

(tag_directive
  (tag_handle) @tag_directive.handle
  (tag_prefix) @tag_directive.prefix) @tag_directive

; --- which document a key belongs to ---
;
; A YAML stream is several documents separated by `---`, and their top-level
; keys are siblings in the tree: nothing spans a document, so the `kind` of one
; manifest and the `metadata.name` of the next look like keys of one file. An
; overlay joining them on the file path therefore binds every combination --
; `fact_join_by_field` pushes a binding per matching candidate, not the first --
; and a file of n manifests states n-squared objects, n of them real.
;
; `scope.config_document` spans one document, so a rule reaches the
; document a key is in with `fact_join_by_span` `within`, and two keys are in
; the same document when they join to the same one.

(document) @config.document

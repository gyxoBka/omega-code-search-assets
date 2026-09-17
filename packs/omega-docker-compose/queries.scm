; omega-docker-compose
;
; A Compose file is YAML, and this Pack shares the YAML grammar. The host
; runs every language Pack whose `parser_id` matches the parser it detected
; for a file, so this Pack runs over *every* YAML file in a repository,
; beside omega-yaml, and it has no filename to test. The only thing that
; tells it a file is a Compose file is the file's own top level: a mapping
; whose key is `services`, `volumes`, `networks`, `secrets` or `configs`.
; Every pattern here is anchored at `(document (block_node (block_mapping`
; for that reason. The anchor is not containment stated as a pattern -- it
; is the discriminator that makes the fact true. A `depends_on:` three
; levels down inside a Helm values file is not a Compose dependency, and a
; pattern that did not carry the anchor would say it was.
;
; What is stated is what Compose adds to YAML and nothing else:
;
;   * the five top-level sections declare names -- a service, a volume, a
;     network, a secret, a config -- and those names are what the rest of
;     the file refers to;
;   * a service refers to them, by name, in a handful of keys whose values
;     are names rather than settings.
;
; Everything else in a Compose file -- `ports`, `environment`, `command`,
; `healthcheck`, `deploy`, `labels`, `restart` -- is an ordinary YAML key
; carrying an ordinary YAML value, and omega-yaml already states it, with
; its value, over the same bytes. Restating it here would declare every
; Compose key twice. The Pack this replaces did exactly that: seventeen
; `data.*` templates for service fields, plus `value.document`,
; `value.object`, `value.array` and three `structured.entry` templates
; whose whole content was the ancestry of a key.
;
; The service, volume, network, secret and config declarations span the
; whole of their entry, so every reference written inside a service lies
; inside that service's declaration and the host gives it that service as
; its owner. No pattern states that ownership and no template carries the
; service name.

; --- a service: the entry under a top-level `services:` ---

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_section
         value: (block_node
           (block_mapping
             (block_mapping_pair
               key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @service.name)) @service))))))
 (#eq? @_section "services"))

; --- a named volume: the entry under a top-level `volumes:` ---

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_section
         value: (block_node
           (block_mapping
             (block_mapping_pair
               key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @volume.name)) @volume))))))
 (#eq? @_section "volumes"))

; --- a network: the entry under a top-level `networks:` ---

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_section
         value: (block_node
           (block_mapping
             (block_mapping_pair
               key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @network.name)) @network))))))
 (#eq? @_section "networks"))

; --- a secret: the entry under a top-level `secrets:` ---

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_section
         value: (block_node
           (block_mapping
             (block_mapping_pair
               key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @secret.name)) @secret))))))
 (#eq? @_section "secrets"))

; --- a config: the entry under a top-level `configs:` ---

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_section
         value: (block_node
           (block_mapping
             (block_mapping_pair
               key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @config.name)) @config))))))
 (#eq? @_section "configs"))

; --- what a service attaches itself to, by name ---
;
; `depends_on`, `networks`, `volumes`, `secrets`, `configs`, `links`,
; `volumes_from` and `env_file` are the keys whose values are names of
; things declared elsewhere rather than settings. Each is written either as
; a sequence of scalars or as a mapping keyed by the name, in block or in
; flow style; all four spellings mean the same thing, so they are one
; pattern and one template.
;
; The name is taken up to the first `:`, which is what turns
; `pgdata:/var/lib/postgresql/data` into the volume `pgdata`, `db:database`
; into the service `db`, and leaves a bare name and a file path untouched.
;
; The key itself is carried as the mention's `qualifier`, because the host
; reduces every `relation.depends` kind to one occurrence and the kind
; string does not survive: without it, a network attachment and a
; `depends_on` edge would be one indistinguishable fact.

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_services
         value: (block_node
           (block_mapping
             (block_mapping_pair
               value: (block_node
                 (block_mapping
                   (block_mapping_pair
                     key: (flow_node) @attach.key
                     value: [(block_node
                               [(block_sequence
                                  (block_sequence_item
                                    (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @attach.name)))
                                (block_mapping
                                  (block_mapping_pair
                                    key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @attach.name)))])
                             (flow_node
                               [(flow_sequence
                                  (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @attach.name))
                                (flow_mapping
                                  (flow_pair
                                    key: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @attach.name)))])]))))))))))
 (#eq? @_services "services")
 (#any-of? @attach.key
   "depends_on" "networks" "volumes" "secrets" "configs" "links" "volumes_from" "env_file"))

; --- the long form of the same attachment ---
;
; `volumes`, `secrets` and `configs` may also be written as a sequence of
; mappings, where the name lives under `source:`. The short form above
; cannot see it: its sequence items are mappings, not scalars.

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_services
         value: (block_node
           (block_mapping
             (block_mapping_pair
               value: (block_node
                 (block_mapping
                   (block_mapping_pair
                     key: (flow_node) @source.key
                     value: (block_node
                       (block_sequence
                         (block_sequence_item
                           (block_node
                             (block_mapping
                               (block_mapping_pair
                                 key: (flow_node) @_source
                                 value: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @source.name)))))))))))))))))
 (#eq? @_services "services")
 (#eq? @_source "source")
 (#any-of? @source.key "volumes" "secrets" "configs"))

; --- what a service is built from, and what it extends ---
;
; `build.context` and `build.dockerfile` name files in this repository, so
; they are the link from a Compose file to the Dockerfile that produces the
; image. `extends.service` and `extends.file` name a service and a Compose
; file the service inherits from. Both parents and both sets of keys are
; named, so neither `context` under `healthcheck` nor `file` under `logging`
; can reach this pattern.

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_services
         value: (block_node
           (block_mapping
             (block_mapping_pair
               value: (block_node
                 (block_mapping
                   (block_mapping_pair
                     key: (flow_node) @_parent
                     value: (block_node
                       (block_mapping
                         (block_mapping_pair
                           key: (flow_node) @nested.key
                           value: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @nested.name))))))))))))))
 (#eq? @_services "services")
 (#any-of? @_parent "build" "extends")
 (#any-of? @nested.key "context" "dockerfile" "service" "file"))

; --- the image a service runs ---
;
; Stated whole, tag and registry included, because that is the string a
; person searches for and the tag is part of what the service depends on.
; `build:` in its short scalar form is the same question answered with a
; path, so the two share one template.

((document
   (block_node
     (block_mapping
       (block_mapping_pair
         key: (flow_node) @_services
         value: (block_node
           (block_mapping
             (block_mapping_pair
               value: (block_node
                 (block_mapping
                   (block_mapping_pair
                     key: (flow_node) @scalar.key
                     value: (flow_node [(plain_scalar) (double_quote_scalar) (single_quote_scalar)] @scalar.name)))))))))))
 (#eq? @_services "services")
 (#any-of? @scalar.key "image" "build" "env_file"))

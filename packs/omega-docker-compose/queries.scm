; --- document ---

(document) @compose.document

; --- mapping_pair ---

(block_mapping_pair key: (_) @compose.key value: (_) @compose.value) @compose.pair

; --- mapping ---

(block_mapping) @compose.object

; --- owned_context ---

(block_mapping_pair
  key: (_) @compose.parent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @compose.child.key
        value: (_) @compose.child.value) @compose.child.pair))) @compose.parent.pair

(block_mapping_pair
  key: (_) @compose.grandparent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @compose.owner.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @compose.owned.key
              value: (_) @compose.owned.value) @compose.owned.pair))) @compose.owner.pair))) @compose.grandparent.pair

(block_mapping_pair
  key: (_) @compose.seq.grandparent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @compose.seq.owner.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @compose.seq.key
              value: (block_node
                (block_sequence
                  (block_sequence_item
                    (_) @compose.seq.item.value) @compose.seq.item))) @compose.seq.pair))) @compose.seq.owner.pair))) @compose.seq.grandparent.pair

; Mapping field inside a sequence item owned by services.<service>.<sequence>.
; Used for structured long-form service options such as volumes[].source.
(block_mapping_pair
  key: (_) @compose.mapseq.grandparent.key
  value: (block_node
    (block_mapping
      (block_mapping_pair
        key: (_) @compose.mapseq.owner.key
        value: (block_node
          (block_mapping
            (block_mapping_pair
              key: (_) @compose.mapseq.key
              value: (block_node
                (block_sequence
                  (block_sequence_item
                    (block_node
                      (block_mapping
                        (block_mapping_pair
                          key: (_) @compose.mapseq.item.key
                          value: (_) @compose.mapseq.item.value) @compose.mapseq.item.pair))))))))) @compose.mapseq.pair))) @compose.mapseq.grandparent.pair

; --- sequence ---

(block_sequence) @compose.array

; --- shared_grammar_structural ---

; OMEGA-INDEPENDENTLY-AUTHORED SHARED-GRAMMAR DIALECT STRUCTURAL QUERY
; language=docker-compose; shared_grammar=yaml

; --- semantic_closure_v3_146 ---

((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.service.name value: (_) @compose.service.value) @compose.service))) (#eq? @_services "services"))
((block_mapping_pair key: (_) @_volumes value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.volume.name value: (_) @compose.volume.value) @compose.volume))) (#eq? @_volumes "volumes"))
((block_mapping_pair key: (_) @_networks value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.network.name value: (_) @compose.network.value) @compose.network))) (#eq? @_networks "networks"))
((block_mapping_pair key: (_) @_secrets value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.secret.name value: (_) @compose.secret.value) @compose.secret))) (#eq? @_secrets "secrets"))
((block_mapping_pair key: (_) @_configs value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.config.name value: (_) @compose.config.value) @compose.config))) (#eq? @_configs "configs"))

((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.dep.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_depends value: (block_node (block_sequence (block_sequence_item (_) @compose.dep.target) @compose.dep.item))) @compose.dep.field)))))) (#eq? @_services "services") (#eq? @_depends "depends_on"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.depmap.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_depends value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.depmap.target value: (_) @compose.depmap.value) @compose.depmap.item))) @compose.depmap.field)))))) (#eq? @_services "services") (#eq? @_depends "depends_on"))

((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.field.service value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.field.key value: (_) @compose.field.value) @compose.field)))))) (#eq? @_services "services"))

((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.seqfield.key value: (block_node (block_sequence (block_sequence_item (_) @compose.seqfield.value) @compose.seqfield.item))) @compose.seqfield)))))) (#eq? @_services "services"))

; --- semantic_closure_v3_147_compose_surface ---

; Typed service scalar/object fields. Values remain authored source text; no interpolation or merge evaluation.
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_image value: (_) @compose.image.value) @compose.image.field)))))) (#eq? @_services "services") (#eq? @_image "image"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_build value: (_) @compose.build.value) @compose.build.field)))))) (#eq? @_services "services") (#eq? @_build "build"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_environment value: (_) @compose.environment.value) @compose.environment.field)))))) (#eq? @_services "services") (#eq? @_environment "environment"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_env_file value: (_) @compose.env_file.value) @compose.env_file.field)))))) (#eq? @_services "services") (#eq? @_env_file "env_file"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_healthcheck value: (_) @compose.healthcheck.value) @compose.healthcheck.field)))))) (#eq? @_services "services") (#eq? @_healthcheck "healthcheck"))

; Typed short-form service sequences.
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_ports value: (block_node (block_sequence (block_sequence_item (_) @compose.port.value) @compose.port.item))) @compose.port.field)))))) (#eq? @_services "services") (#eq? @_ports "ports"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_volumes value: (block_node (block_sequence (block_sequence_item (_) @compose.volume_mount.value) @compose.volume_mount.item))) @compose.volume_mount.field)))))) (#eq? @_services "services") (#eq? @_volumes "volumes"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_networks value: (block_node (block_sequence (block_sequence_item (_) @compose.network_ref.target) @compose.network_ref.item))) @compose.network_ref.field)))))) (#eq? @_services "services") (#eq? @_networks "networks"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_secrets value: (block_node (block_sequence (block_sequence_item (_) @compose.secret_ref.target) @compose.secret_ref.item))) @compose.secret_ref.field)))))) (#eq? @_services "services") (#eq? @_secrets "secrets"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_configs value: (block_node (block_sequence (block_sequence_item (_) @compose.config_ref.target) @compose.config_ref.item))) @compose.config_ref.field)))))) (#eq? @_services "services") (#eq? @_configs "configs"))
((block_mapping_pair key: (_) @_services value: (block_node (block_mapping (block_mapping_pair key: (_) @compose.typed.seq.service value: (block_node (block_mapping (block_mapping_pair key: (_) @_profiles value: (block_node (block_sequence (block_sequence_item (_) @compose.profile.value) @compose.profile.item))) @compose.profile.field)))))) (#eq? @_services "services") (#eq? @_profiles "profiles"))

; --- distributed_highlights ---

; OMEGA EXACT-PARSER EXTERNAL STRUCTURAL EVIDENCE — RUNTIME-COMPILE-GATED
; source=https://github.com/neovim-treesitter/nvim-treesitter-queries-ini
; parser_revision=e4018b5176132b4f3c5d6e61cea383f42288d0f5
; source_sha256=29a9cc5c000a944b3f04a9b8c3903598023f9b57f52ed4960b870f3eccc7811c

(section_name
  (text) @markup.heading)

(comment) @comment @spell

[
  "["
  "]"
] @punctuation.bracket

"=" @operator

(setting
  (setting_name) @property)

(setting_value) @string

; --- distributed_injections ---

; OMEGA EXACT-PARSER EXTERNAL STRUCTURAL EVIDENCE — RUNTIME-COMPILE-GATED
; source=https://github.com/neovim-treesitter/nvim-treesitter-queries-ini
; parser_revision=e4018b5176132b4f3c5d6e61cea383f42288d0f5
; source_sha256=977ec24890da3b3fee8cb2aa16ea1c5d8fc48720836a4923457d85f7af08e3b6

; --- terminal_structured_ini_v1 ---
(section (section_name) @ini.section.name) @ini.section
(setting (setting_name) @ini.setting.name (setting_value) @ini.setting.value) @ini.setting

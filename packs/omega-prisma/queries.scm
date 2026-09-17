; omega-prisma
;
; A Prisma schema is the one file in a project that says what the data is:
; which entities exist, what each one holds, what type each field has, which
; entities point at which, and which database and client the project is
; generated against. Everything an agent asks of `schema.prisma` is one of
; those: *where is the User model declared*, *what fields does it have and of
; what type*, *what does Post relate to*, *which table is this stored in*,
; *which provider and which environment variables does this project need*.
;
; So every construct the language names is stated as a declaration under the
; name a question would spell, and the two things that point elsewhere -- a
; field's type and a field named inside a key, index or relation -- are stated
; as references so they resolve onto those declarations.
;
; Containment is not stated anywhere. A field lies inside its model's span and
; a setting inside its block's, so the host derives `User.email` from the
; nesting and no pattern has to say it. There is no scope pattern either: a
; model's declaration already spans the block, which is what a region would
; have been for.

; --- the four things a schema declares by name ---
;
; A model, a view and a composite `type` are all types: the generated client
; exposes each as a named type, and code elsewhere in the repository spells it
; exactly this way. An enum is one too. Each is anchored to its first named
; child, which is the name.

(model_declaration . (identifier) @model.name) @model

(view_declaration . (identifier) @view.name) @view

(enum_declaration . (identifier) @enum.name) @enum

(type_declaration . (identifier) @composite.name) @composite

; --- an enum member ---
;
; `enumeral` is a leaf and occurs only inside an enum block, so it is named
; from its own text and already lies inside its enum's declaration.

(enumeral) @enumeral

; --- a field ---
;
; `id Int @id @default(autoincrement())`. One pattern, two templates: the
; field is declared under its own name, and the whole of its declared type --
; `String`, `String?`, `Post[]`, `Unsupported("circle")` -- is carried onto it
; so the card reads `email -> String`. Every `column_declaration` has exactly
; one `column_type`, so nothing here is optional.

(column_declaration
  . (identifier) @field.name
  . (column_type) @field.type) @field

; --- what a field is annotated with ---
;
; `@id`, `@unique`, `@default(now())`, `@db.VarChar(255)`, `@relation(...)`.
; These are the language's own vocabulary, not names a question resolves to,
; so each is carried onto the field it annotates as a modifier rather than
; emitted as a mention of nothing. Several fold into one set, which is what a
; field's annotations are.

(column_declaration (attribute) @field.modifier) @field.modifier.owner

; --- the type a field points at ---
;
; A field's type is either one of Prisma's nine built-in scalars, which are
; declared nowhere and so can be referenced nowhere, or the name of a model,
; a view, an enum or a composite type declared above. Only the second is a
; reference, and it is what makes `Post.author: User` resolve onto `model
; User`.

((column_type . (identifier) @field_type.ref)
 (#not-any-of? @field_type.ref
   "String" "Boolean" "Int" "BigInt" "Float" "Decimal" "DateTime" "Json" "Bytes"))

; --- a field named inside a key, an index or a relation ---
;
; `@@id([a, b])`, `@@unique([email])`, `@@index([email, name])` and
; `@relation(fields: [authorId], references: [id])` all spell their operands
; as an array of bare field names. An array of identifiers occurs nowhere else
; in this grammar -- a scalar list default and `previewFeatures` hold strings,
; and the `[]` of a list type is empty -- so this one pattern covers all of
; them.

(array (identifier) @constraint.field)

; --- the database name something is mapped to ---
;
; `@@map("users")` on a model and `@map("created_at")` on a field are the
; bridge between the schema and the SQL a migration or a raw query spells, so
; the physical name is declared under itself. The same `map(...)` shape serves
; both levels.

((call_expression . (identifier) @map.fn . (arguments . (string) @map.name))
 (#eq? @map.fn "map"))

; --- an environment variable the schema needs ---
;
; `url = env("DATABASE_URL")`. The value is not read here; what is stated is
; that this schema depends on that name.

((call_expression . (identifier) @env.fn . (arguments . (string) @env.name))
 (#eq? @env.fn "env"))

; --- the two configuration blocks ---

(datasource_declaration . (identifier) @datasource.name) @datasource

(generator_declaration . (identifier) @generator.name) @generator

; --- a setting inside one ---
;
; `provider = "postgresql"` is where a setting is declared and the one place
; the value is short and authored enough to be worth carrying with it,
; unquoted. A setting whose value is a call, an array or a number is the same
; declaration stated without one: what `env(...)` and `["views"]` hold is
; emitted by the patterns above, and repeating the compound's text here would
; store the same bytes twice.

(assignment_expression
  . (variable) @setting.name
  . (string) @setting.value) @setting

(assignment_expression
  . (variable) @setting_other.name
  . [(array)
     (assignment_expression)
     (binary_expression)
     (call_expression)
     (false)
     (identifier)
     (member_expression)
     (null)
     (number)
     (true)
     (type_expression)]) @setting_other

; omega-elixir
;
; Elixir has almost no syntax of its own: `defmodule`, `def`, `defstruct`,
; `@spec`, `alias` and `use` are all ordinary calls to a macro, so every
; declaration in the language is spelled `(call target: (identifier) ...)` and
; the only thing that tells one from another is the target's text. Every
; pattern below therefore names the macro it is about with `#eq?` or
; `#any-of?`, the two predicates the runtime actually applies.
;
; The questions these answer: where is this module, function, type, callback,
; struct field or module attribute declared; what does this module bring in
; with alias/import/require/use; which behaviour or protocol does it
; implement; who calls this function; which module does this call go to; and
; which test covers this module.
;
; Containment is not stated. The tree already holds it; a module body and a
; function body are emitted once each as a region and nothing else restates
; nesting.

; --- a module ---
;
; `defmodule MyApp.Accounts do ... end`. The alias node's text is the full
; dotted name, which is the name a remote call resolves against.

((call
   target: (identifier) @module.form
   (arguments . (alias) @module.name)
   (do_block)? @module.body) @module
 (#eq? @module.form "defmodule"))

; --- a protocol ---
;
; A protocol is a named type that other modules implement, so it is declared
; under a Type word rather than a Namespace one.

((call
   target: (identifier) @protocol.form
   (arguments . (alias) @protocol.name)
   (do_block)? @protocol.body) @protocol
 (#eq? @protocol.form "defprotocol"))

; --- what a test module covers ---
;
; `MyApp.AccountsTest` is the ExUnit convention for the tests of
; `MyApp.Accounts`. The edge is read off the name, so it is a convention
; candidate; the module itself is declared by the pattern above.

((call
   target: (identifier) @test.module.form
   (arguments . (alias) @test.module.name))
 (#eq? @test.module.form "defmodule")
 (#match? @test.module.name "Test$"))

; --- a function, macro or guard ---
;
; Four headers are legal and all four appear in real code:
;
;   def foo                      zero arity, no parentheses
;   def foo(a, b)                the ordinary clause
;   def foo(a) when is_x(a)      a clause with a guard
;   def foo when is_x()          zero arity with a guard
;
; One pattern, one match per clause. The argument list is carried on the
; declaration as its parameter shape and the macro that declared it as its
; visibility, so a card reads `defp foo(a, b)`.

((call
   target: (identifier) @function.form
   (arguments
     [(identifier) @function.name
      (call
        target: (identifier) @function.name
        (arguments) @function.parameters)
      (binary_operator
        left: (call
          target: (identifier) @function.name
          (arguments) @function.parameters)
        operator: "when")
      (binary_operator
        left: (identifier) @function.name
        operator: "when")])
   (do_block)? @function.body) @function
 (#any-of? @function.form
   "def" "defp" "defmacro" "defmacrop" "defguard" "defguardp" "defn" "defnp"
   "defdelegate"))

; --- what a defdelegate forwards to ---

((call
   target: (identifier) @delegate.form
   (arguments
     (keywords (pair key: (keyword) @delegate.key value: (alias) @delegate.target))))
 (#eq? @delegate.form "defdelegate")
 (#match? @delegate.key "^to:?\\s*$"))

; --- a test ---
;
; `test "rejects a blank name" do ... end`. The description is the test's
; identity; ExUnit has no other name for it.

((call
   target: (identifier) @test.form
   (arguments . (string (quoted_content) @test.name))
   (do_block)? @test.body) @test
 (#eq? @test.form "test"))

; --- the fields of a struct or an exception ---
;
; `defstruct [:name, :age]`, `defstruct name: nil` and `defstruct [name: nil]`
; are the three spellings. The atom carries a leading colon and the keyword a
; trailing one; both are stripped so the field is named as it is written in
; `%Mod{name: x}`.

((call
   target: (identifier) @struct.form
   (arguments
     [(list
        [(atom) @struct.field.atom
         (keywords (pair key: (keyword) @struct.field.key))])
      (keywords (pair key: (keyword) @struct.field.key))
      (atom) @struct.field.atom]))
 (#any-of? @struct.form "defstruct" "defexception"))

; --- a declared type ---
;
; `@type t :: %__MODULE__{}` and `@opaque handle(a) :: {:handle, a}`. The name
; is an identifier when the type takes no arguments and a call when it does.

((unary_operator
   operator: "@"
   operand: (call
     target: (identifier) @type.form
     (arguments
       (binary_operator
         left: [(identifier) @type.name
                (call target: (identifier) @type.name)]
         operator: "::")))) @type.declaration
 (#any-of? @type.form "type" "typep" "opaque"))

; --- a callback a behaviour requires ---

((unary_operator
   operator: "@"
   operand: (call
     target: (identifier) @callback.form
     (arguments
       (binary_operator
         left: [(identifier) @callback.name
                (call target: (identifier) @callback.name)]
         operator: "::")))) @callback.declaration
 (#any-of? @callback.form "callback" "macrocallback"))

; --- a specification attached to a function ---
;
; A `@spec` sits beside the `def` it describes rather than inside it, so it is
; stated as a mention of that function, not as a second declaration of it.

((unary_operator
   operator: "@"
   operand: (call
     target: (identifier) @spec.form
     (arguments
       (binary_operator
         left: (call target: (identifier) @spec.name)
         operator: "::")))) @spec
 (#eq? @spec.form "spec"))

; --- a behaviour this module implements ---

((unary_operator
   operator: "@"
   operand: (call
     target: (identifier) @behaviour.form
     (arguments (alias) @behaviour.name)))
 (#any-of? @behaviour.form "behaviour" "behavior"))

; --- a module attribute, and its value ---
;
; `@timeout 5_000` declares `timeout` for the rest of the module. The
; attributes that are really declarations of something else -- types,
; callbacks, specs, behaviours -- are stated above, and the documentation
; attributes name nothing, so all of them are excluded here.

((unary_operator
   operator: "@"
   operand: (call
     target: (identifier) @attribute.name
     (arguments) @attribute.value)) @attribute
 (#not-any-of? @attribute.name
   "type" "typep" "opaque" "callback" "macrocallback" "spec" "behaviour"
   "behavior" "moduledoc" "doc" "typedoc" "shortdoc"))

; --- a use of a module attribute ---
;
; `@timeout` with no argument is a read of the attribute declared above.

(unary_operator
  operator: "@"
  operand: (identifier) @attribute.reference)

; --- what a module brings in ---
;
; `alias`, `import`, `require` and `use` are one fact with four spellings, so
; they are one pattern and the spelling is carried as an attribute rather than
; as four kinds.

((call
   target: (identifier) @import.form
   (arguments . (alias) @import.module)) @import
 (#any-of? @import.form "alias" "import" "require" "use"))

; `alias MyApp.{Accounts, Billing}` -- the tuple member alone is not a module
; name, so it is joined back onto the prefix.

((call
   target: (identifier) @import.multi.form
   (arguments .
     (dot
       left: (alias) @import.multi.prefix
       right: (tuple (alias) @import.multi.member))))
 (#any-of? @import.multi.form "alias" "import" "require" "use"))

; `alias MyApp.Accounts, as: Acct` -- `Acct` is a local name bound to another
; module, and every later mention of it in the file is spelled `Acct`.

((call
   target: (identifier) @import.as.form
   (arguments
     (alias) @import.as.target
     (keywords (pair key: (keyword) @import.as.key value: (alias) @import.as.name))))
 (#eq? @import.as.form "alias")
 (#match? @import.as.key "^as:?\\s*$"))

; --- a protocol implementation ---
;
; `defimpl Size, for: MyList do ... end`. Two patterns: the protocol is the
; thing implemented, the `for:` target is a module this implementation is
; about. Writing them as one would need an optional capture, and `defimpl`
; inside a `defprotocol` has no `for:`.

((call
   target: (identifier) @impl.form
   (arguments . (alias) @impl.protocol)
   (do_block)? @impl.body)
 (#eq? @impl.form "defimpl"))

((call
   target: (identifier) @impl.for.form
   (arguments
     (keywords (pair key: (keyword) @impl.for.key value: (alias) @impl.for.target))))
 (#eq? @impl.for.form "defimpl")
 (#match? @impl.for.key "^for:?\\s*$"))

; --- a remote call, and the module it goes to ---
;
; `Enum.map(list, fun)` and `&String.trim/1` are both a call whose target is a
; dot. The function and the module are two answers, so two patterns over the
; same node shape, each binding one of them: the left of a dot is often a
; variable or `__MODULE__`, and only an alias names a module.

; A remote call has an argument list. Without this, `u.id`, `conn.assigns` and
; `changeset.valid?` -- a field read on a struct or map, which this grammar also
; spells as a `call` with a `dot` target -- were emitted as calls and resolved by
; bare name onto any `def id` in the corpus.
(call target: (dot right: (identifier) @call.remote) (arguments))

(call target: (dot left: (alias) @call.module right: (identifier)))

; --- a local call ---
;
; Everything that is not one of the macros stated above. `x |> foo` puts the
; callee on the right of the pipe as a bare identifier with no call node of
; its own, so it is a second pattern.

; A bare local call is not stated. This grammar spells a module attribute --
; `@moduledoc "x"`, `@impl true`, `@timeout 5_000` -- as
; `unary_operator("@", call(identifier, arguments))`, which is the same node
; this pattern matched, and a query cannot see the parent. Measured on a
; 35-line module: 19 captures, of which 10 were attribute macros and 2 were
; genuine calls. An exclusion list cannot help, because a module attribute may
; be named anything. The piped form below is unambiguous and stays.

(binary_operator operator: "|>" right: (identifier) @call.local)

; --- a struct literal ---
;
; `%MyApp.User{name: n}` is a use of the module that declared the struct.

(map (struct (alias) @struct.use))

; --- a module named as an argument ---
;
; `GenServer.start_link(MyApp.Server, [])`, `raise MyApp.Error`,
; `use Supervisor` -- passing a module by name is how Elixir wires things
; together. The macros that already declare or bind the alias are excluded so
; the same span is not stated twice.

((call
   target: (identifier) @module.argument.form
   (arguments (alias) @module.argument))
 (#not-any-of? @module.argument.form
   "defmodule" "defprotocol" "defimpl" "alias" "import" "require" "use"
   "behaviour" "behavior"))

(call target: (dot) (arguments (alias) @module.argument))

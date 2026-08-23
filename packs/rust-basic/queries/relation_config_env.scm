(call_expression
  function: (scoped_identifier) @function
  arguments: (arguments
    (string_literal) @target)) @relation
(#match? @function "^(std::)?env::var$")

((attribute_item (attribute) @attribute)
 .
 (function_item
  name: (identifier) @source
  body: (block
    (expression_statement
      (call_expression
        function: (identifier) @target) @relation)))
 (#match? @attribute "test"))

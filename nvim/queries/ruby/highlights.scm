;; extends
;;
;; Appended to nvim-treesitter's own queries/ruby/highlights.scm rather than replacing it,
;; so the plugin's query keeps updating underneath. Only the additions live here.

; A method call with an explicit receiver: highlight the method name as a method call
; rather than the plugin's generic @function.call (later patterns win, so this overrides).
(call
  receiver: [(call) (identifier) (constant) (integer) (self) (instance_variable)]
  method: (identifier) @function.method.call)

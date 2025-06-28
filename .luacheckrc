
-- See https://github.com/luacheck/luacheck

-- Don't warn about unused arguments in functions that are likely to be callbacks.
options.allow_defined = true

-- Don't warn about unused arguments in functions that are likely to be callbacks.
options.allow_defined_in_loops = true

-- A list of globals that should be ignored. Useful for defining globals provided by the environment.
globals = {
  "vim",
}

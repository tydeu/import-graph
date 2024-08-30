import ImportGraph.Cli

/-!
# `lake exe graph`

This is a replacement for Lean 3's `leanproject import-graph` tool.
-/

open Cli

/-- Setting up command line options and help text for `lake exe graph`. -/
def graph : Cmd := `[Cli|
  graph VIA importGraphCLI; ["0.0.2"]
  "Generate representations of a Lean import graph. \
   By default generates the import graph up to `Mathlib`. \
   If you are working in a downstream project, use `lake exe graph --to MyProject`."

  FLAGS:
    "show-transitive";    "Show transitively redundant edges."
    to : ModuleName;      "Only show the upstream imports of the specified module."
    "from" : ModuleName;  "Only show the downstream dependencies of the specified module."
    "exclude-meta";       "Exclude any files starting with `Mathlib.[Tactic|Lean|Util|Mathport]`."
    "include-deps";       "Include used files from other libraries (not including Lean itself and `std`)"
    "include-std";        "Include used files from the Lean standard library (implies 'include-deps')"
    "include-lean";       "Include used files from Lean itself (implies 'include-deps' and 'include-std')"

  ARGS:
    ...outputs : String;  "Filename(s) for the output. \
      If none are specified, generates `import_graph.dot`. \
      Automatically chooses the format based on the file extension. \
      Currently `.dot` is supported, \
      and if you have `graphviz` installed then any supported output format is allowed."
]


/-- `lake exe graph` -/
def main (args : List String) : IO UInt32 :=
  graph.validate args

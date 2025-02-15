# importGraph

A simple tool to create import graphs of lake packages.


## Requirements

For creating different output formats than `.dot` (for example to create a `.pdf` file), you should have [`graphviz`](https://graphviz.org/) installed.

## Usage

If you are using mathlib, the tool will already be available. If not, see installation notes below.

Once available in your project, you can create import graphs with

```bash
lake exe graph
```

A typical command is

```bash
lake exe graph --to MyModule my_graph.pdf
```
where `MyModule` follows the same module naming you would use to `import` it in lean. See `lake exe graph --help` for more options.

### Troubleshoot

* make sure to `lake build` your project (or the specified `--to` module) before using `lake exe graph`!

### Json

To create a Json file, you can use `.xdot_json` as output type:

```bash
lake exe graph my_graph.xdot_json
```

### HTML

```
lake exe graph my_graph.html
```

creates a stand-alone HTML file visualising the import structure.

## Commands

There are a few commands implemented, which help you analysing the imports of a file. These are accessible by adding `import ImportGraph.Imports` to your lean file.

* `#redundant_imports`: lists any transitively redundant imports in the current module.
* `#min_imports`: attempts to construct a minimal set of imports for the declarations
  in the current file.
  (Must be run at the end of the file. Tactics and macros may result in incorrect output.)
* `#find_home decl`: suggests files higher up the import hierarchy to which `decl` could be moved.

## Installation

The installation works exactly like for any [Lake package](https://reservoir.lean-lang.org/).

*This only relevant if your project does not already require `importGraph` through another lake package (e.g. mathlib). If it does, do not follow these instructions; instead just use the tool with `lake exe graph`!*

You can import this in any lean projects by the following line to your `lakefile.lean`:

```lean
require importGraph from git "https://github.com/leanprover-community/import-graph" @ "main"
```

or, if you have a `lakefile.toml`, it would be

```toml
[[require]]
name = "importGraph"
git = "[https://github.com/leanprover-community/batteries](https://github.com/leanprover-community/import-graph)"
rev = "main"
```

Then, you might need to call `lake update -R importGraph` in your project.

## Contribution

Please open PRs/Issues if you have troubles or would like to contribute new features!

## Credits

The main tool has been extracted from [mathlib](https://github.com/leanprover-community/mathlib4),
originally written by Kim Morrison and other mathlib contributors.

The HTML visualisation has been incorporated from
[a project by Eric Wieser](https://github.com/eric-wieser/mathlib-import-graph).

### Maintainers

Primarily maintained by [Jon Eugster](https://leanprover.zulipchat.com/#narrow/dm/385895-Jon-Eugster), Kim Morrison, and the wider leanprover community.

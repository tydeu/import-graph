/-
Copyright (c) 2024 Jon Eugster. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Jon Eugster
-/

import Lean
import Batteries.Lean.NameMap
import Batteries.Tactic.OpenPrivate

open Lean

namespace ImportGraph

open Elab Meta in
/-- Filter Lean internal declarations -/
def isBlackListed {m} [Monad m] [MonadEnv m] (declName : Name) : m Bool := do
  if declName == ``sorryAx then return true
  if declName matches .str _ "inj" then return true
  if declName matches .str _ "noConfusionType" then return true
  let env ← getEnv
  pure <| declName.isInternalDetail
   || isAuxRecursor env declName
   || isNoConfusion env declName
  <||> isRec declName <||> isMatcher declName

/-- Get all declarations in the specified file. -/
def getDeclsInFile (module : Name) : CoreM NameSet := do
  let env ← getEnv
  match env.moduleIdxForModule? module with
    | none => return {}
    | some modIdx =>
      let decls := env.const2ModIdx
      let declsIn ← decls.foldM (fun acc n idx => do
        if idx == modIdx && (! (← isBlackListed n)) then return acc.insert n else return acc) ({} : NameSet)
      return declsIn

/-- Gexf template for a node in th graph. -/
def Gexf.nodeTemplate (n module : Name) (size : Nat) := s!"<node id=\"{n}\" label=\"{n}\"><attvalues><attvalue for=\"0\" value=\"{size}\" /><attvalue for=\"1\" value=\"{module.isPrefixOf n}\" /></attvalues></node>\n          "

/-- Gexf template for an edge in the graph -/
def Gexf.edgeTemplate (source target : Name) := s!"<edge source=\"{source}\" target=\"{target}\" id=\"{source}--{target}\" />\n          "

open Gexf in
/-- Creates a `.gexf` file of the graph, see https://gexf.net/

Metadata can be stored in forms of attributes, currently we record the following:
* `decl_count` (Nat): number of declarations in the file
* `in_module` (Bool): whether the file belongs to the main module
  (used to strip the first part of the name when displaying).
-/
def Graph.toGexf (graph : NameMap (Array Name)) (module : Name) : CoreM String := do
  let sizes : NameMap Nat ← graph.foldM (fun acc n _ => do
    pure <| acc.insert n (← getDeclsInFile n).size ) {}
    -- graph.fold (fun acc _ i => i.foldl (fun acc₂ j => acc₂.insert j ((acc₂.findD j 0) + 1)) acc) {}

  let nodes : String := graph.fold (fun acc n _ => acc ++ nodeTemplate n module (sizes.findD n 0)) ""
  let edges : String := graph.fold (fun acc n i => acc ++ (i.foldl (fun b j => b ++ edgeTemplate j n) "")) ""
  return s!"<?xml version='1.0' encoding='utf-8'?>
    <gexf xmlns=\"http://www.gexf.net/1.2draft\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd\" version=\"1.2\">
      <meta>
        <creator>Lean ImportGraph</creator>
      </meta>
      <graph defaultedgetype=\"directed\" mode=\"static\" name=\"\">
        <attributes mode=\"static\" class=\"node\">
          <attribute id=\"0\" title=\"decl_count\" type=\"long\" />
          <attribute id=\"1\" title=\"in_module\" type=\"boolean\" />
        </attributes>
        <nodes>
          {nodes.trim}
        </nodes>
        <edges>
          {edges.trim}
        </edges>
      </graph>
    </gexf>
    "

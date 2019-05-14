open Syntax
open Types

let checkExhaustivity (g : gamma) (t : texpr) (pieces : (expr*expr) list) : bool =
  false

let rec check (g : gamma) (e : expr) (t : texpr) : bool =
  match e with
  | Lambda [Symbol arg, body] ->
    (match t with
    | Func (t1, t2) ->
      let g' = registerExprType (Symbol arg) t1 g
      in check g' body t2
    | _ -> false (* We have no type aliasing mechanism *))
  | _ -> synthesize g e = Some t

and synthesize (g : gamma) : expr -> texpr option =
  function
  | Appl (f, x) -> synthAppl g f x
  | Atom _ -> Some Prelude.tAtom (* The Atom type is an infinite disjunction. *)
  | DataCtr x -> isDataCtr g x
  | Lambda ((Symbol _, _) :: _) -> None
  | Lambda ((a, b) :: pieces) ->
    let aType = synthesize g a in
    let bType = synthesize g b in
    (match (aType, bType) with
    | (Some at, Some bt) ->
      if checkPieces g at bt pieces
      then Some (Func (at, bt))
      else None
    | _ -> None)
  | Lambda [] -> None
  | List _ -> Some Prelude.tList
  | Quote _ -> Some Prelude.tExpr
  | Symbol v -> inGamma g v
  | TExpr _ -> Some Prelude.tTypeExpr

and synthAppl (g : gamma) (f : expr) (x : expr) : texpr option =
  match synthesize g f with
  | Some (Func (t1, t2)) -> if check g x t1 then Some t2 else None
  | _ -> None

and checkPieces
    (g : gamma) (argT : texpr) (bodyT : texpr) (pieces : (expr*expr) list)
    : bool =
  match pieces with
  | [] -> true
  | [Symbol a, b] ->
    let g' = registerExprType (Symbol a) argT g
    in check g' b bodyT
  | (a, b) :: pieces' ->
    check g a argT && check g b bodyT && checkPieces g argT bodyT pieces'
    (*&& checkExhaustivity g argT ((a, b) :: pieces*)
  (* TODO: check for exhaustivity *)
  (* TODO: check for dead branches *)

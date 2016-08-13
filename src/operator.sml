structure OperatorData =
struct
  datatype 'i t =
      ARR_TY
    | CMD_TY
    | CMD
    | LAM
    | NAT
    | NUM of int
    | RET
    | BND
    | DCL
    | GET of 'i
    | SET of 'i

  fun eq f (ARR_TY, ARR_TY) = true
    | eq f (CMD_TY, CMD_TY) = true
    | eq f (LAM, LAM) = true
    | eq f (NAT, NAT) = true
    | eq f (NUM x, NUM y) = x = y
    | eq f (CMD, CMD) = true
    | eq f (RET, RET) = true
    | eq f (BND, BND) = true
    | eq f (DCL, DCL) = true
    | eq f (GET i, GET j) = f (i, j)
    | eq f (SET i, SET j) = f (i, j)
    | eq f _ = false

  fun toString f theta =
    case theta of
         ARR_TY => "arr"
       | CMD_TY => "cmd"
       | LAM => "lam"
       | NAT => "nat"
       | NUM i => Int.toString i
       | CMD => "cmd"
       | RET => "ret"
       | BND => "bnd"
       | DCL => "dcl"
       | GET u => "get[" ^ f u ^ "]"
       | SET u => "set[" ^ f u ^ "]"
end

structure Operator : OPERATOR =
struct
  structure S = SortData
  open OperatorData

  structure Valence = Valence (structure Sort = Sort and Spine = ListSpine)
  structure Arity = Arity (Valence)

  local
    fun K tau = (([], []), tau)
  in
    fun arity ARR_TY = ([K S.TYP, K S.TYP], S.TYP)
      | arity CMD_TY = ([K S.TYP], S.TYP)
      | arity LAM = ([K S.TYP, (([], [S.EXP]), S.EXP)], S.EXP)
      | arity NAT = ([], S.TYP)
      | arity (NUM _) = ([], S.EXP)
      | arity CMD = ([K S.CMD], S.EXP)
      | arity RET = ([K S.EXP], S.CMD)
      | arity BND = ([K S.EXP, (([], [S.EXP]), S.CMD)], S.CMD)
      | arity DCL = ([K S.EXP, (([S.EXP], []), S.CMD)], S.CMD)
      | arity (GET _) = ([], S.CMD)
      | arity (SET _) = ([K S.EXP], S.CMD)
  end

  fun support (GET i) = [(i, S.EXP)]
    | support (SET i) = [(i, S.EXP)]
    | support _ = []

  fun map f ARR_TY = ARR_TY
    | map f CMD_TY = CMD_TY
    | map f LAM = LAM
    | map f NAT = NAT
    | map f (NUM x) = NUM x
    | map f CMD = CMD
    | map f RET = RET
    | map f BND = BND
    | map f DCL = DCL
    | map f (GET u) = GET (f u)
    | map f (SET u) = SET (f u)
end

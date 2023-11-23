import time
from python import Python


@register_passable("trivial")
struct Move:
    var i: Int
    var j: Int
    var prom: Int
    fn __init__(i: Int, j: Int, prom: Int) -> Move:
        return Move(i, j, prom)


fn isupper(c: String) -> Bool:
    for i in range(len(c)):
        if ord(c[i]) < ord("A") or ord(c[i]) > ord("Z"):
            return False
    return True

fn lower(c: String) -> String:
    var result = String()
    for i in range(len(c)):
        if ord(c[i]) >= ord("A") and ord(c[i]) <= ord("Z"):
            result += chr(ord(c[i]) + ord("a") - ord("A"))
        else:
            result += c[i]
    return result

fn upper(c: String) -> String:
    var result = String()
    for i in range(len(c)):
        if ord(c[i]) >= ord("a") and ord(c[i]) <= ord("z"):
            result += chr(ord(c[i]) + ord("A") - ord("a"))
        else:
            result += c[i]
    return result

fn islower(c: String) -> Bool:
    for i in range(len(c)):
        if ord(c[i]) < ord("a") or ord(c[i]) > ord("z"):
            return False
    return True

fn swapcase(c: String) -> String:
    var result = String()
    for i in range(len(c)):
        if ord(c[i]) >= ord("a") and ord(c[i]) <= ord("z"):
            result += chr(ord(c[i]) + ord("A") - ord("a"))
        elif ord(c[i]) >= ord("A") and ord(c[i]) <= ord("Z"):
            result += chr(ord(c[i]) + ord("a") - ord("A"))
        else:
            result += c[i]
    return result

fn isspace(c: String) -> Bool:
    for i in range(len(c)):
        if ord(c[i]) != ord(" "):
            return False
    return True

fn abs(x: Int) -> Int:
    if x < 0:
        return -x
    return x

fn max(x: Int, y: Int) -> Int:
    if x > y:
        return x
    return y


def calc_value(self:Position, i: Int, j: Int, prom: Int) -> Int:
    let A1 = 91
    let H1 = 98
    let A8 = 21
    let H8 = 28
    let S = 10
    let pst = Python.dict()
    pst["P"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 178, 183, 186, 173, 202, 182, 185, 190, 0, 0, 107, 129, 121, 144, 140, 131, 144, 107, 0, 0, 83, 116, 98, 115, 114, 100, 115, 87, 0, 0, 74, 103, 110, 109, 106, 101, 100, 77, 0, 0, 78, 109, 105, 89, 90, 98, 103, 81, 0, 0, 69, 108, 93, 63, 64, 86, 103, 69, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    pst["N"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 214, 227, 205, 205, 270, 225, 222, 210, 0, 0, 277, 274, 380, 244, 284, 342, 276, 266, 0, 0, 290, 347, 281, 354, 353, 307, 342, 278, 0, 0, 304, 304, 325, 317, 313, 321, 305, 297, 0, 0, 279, 285, 311, 301, 302, 315, 282, 280, 0, 0, 262, 290, 293, 302, 298, 295, 291, 266, 0, 0, 257, 265, 282, 280, 282, 280, 257, 260, 0, 0, 206, 257, 254, 256, 261, 245, 258, 211, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    pst["B"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 261, 242, 238, 244, 297, 213, 283, 270, 0, 0, 309, 340, 355, 278, 281, 351, 322, 298, 0, 0, 311, 359, 288, 361, 372, 310, 348, 306, 0, 0, 345, 337, 340, 354, 346, 345, 335, 330, 0, 0, 333, 330, 337, 343, 337, 336, 320, 327, 0, 0, 334, 345, 344, 335, 328, 345, 340, 335, 0, 0, 339, 340, 331, 326, 327, 326, 340, 336, 0, 0, 313, 322, 305, 308, 306, 305, 310, 310, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    pst["R"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 514, 508, 512, 483, 516, 512, 535, 529, 0, 0, 534, 508, 535, 546, 534, 541, 513, 539, 0, 0, 498, 514, 507, 512, 524, 506, 504, 494, 0, 0, 479, 484, 495, 492, 497, 475, 470, 473, 0, 0, 451, 444, 463, 458, 466, 450, 433, 449, 0, 0, 437, 451, 437, 454, 454, 444, 453, 433, 0, 0, 426, 441, 448, 453, 450, 436, 435, 426, 0, 0, 449, 455, 461, 484, 477, 461, 448, 447, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    pst["Q"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 935, 930, 921, 825, 998, 953, 1017, 955, 0, 0, 943, 961, 989, 919, 949, 1005, 986, 953, 0, 0, 927, 972, 961, 989, 1001, 992, 972, 931, 0, 0, 930, 913, 951, 946, 954, 949, 916, 923, 0, 0, 915, 914, 927, 924, 928, 919, 909, 907, 0, 0, 899, 923, 916, 918, 913, 918, 913, 902, 0, 0, 893, 911, 929, 910, 914, 914, 908, 891, 0, 0, 890, 899, 898, 916, 898, 893, 895, 887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    pst["K"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60004, 60054, 60047, 59901, 59901, 60060, 60083, 59938, 0, 0, 59968, 60010, 60055, 60056, 60056, 60055, 60010, 60003, 0, 0, 59938, 60012, 59943, 60044, 59933, 60028, 60037, 59969, 0, 0, 59945, 60050, 60011, 59996, 59981, 60013, 60000, 59951, 0, 0, 59945, 59957, 59948, 59972, 59949, 59953, 59992, 59950, 0, 0, 59953, 59958, 59957, 59921, 59936, 59968, 59971, 59968, 0, 0, 59996, 60003, 59986, 59950, 59943, 59982, 60013, 60004, 0, 0, 60017, 60030, 59997, 59986, 60006, 59999, 60040, 60018, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
    var p: String = self.board[i]
    var q: String = self.board[j]
    # Actual move
    var score: Int = pst[p][j].to_float64().to_int() - pst[p][i].to_float64().to_int()
    # Capture
    if islower(q):
        score += pst[upper(q)][119 - j].to_float64().to_int()
    # Castling check detection
    if abs(j - self.kp) < 2:
        score += pst["K"][119 - j].to_float64().to_int()
    # Castling
    if p == "K" and abs(i - j) == 2:
        score += pst["R"][(i + j) // 2].to_float64().to_int()
        score -= pst["R"][A1 if j < i else H1].to_float64().to_int()
    # Special pawn stuff
    if p == "P":
        if A8 <= j <= H8:
            score += pst[chr(prom)][j].to_float64().to_int() - pst["P"][j].to_float64().to_int()
        if j == self.ep:
            score += pst["P"][119 - (j + S)].to_float64().to_int()
    return score

def rotate_pos(self: Position, nullmove=False) -> Position:
    """Rotates the board, preserving enpassant, unless nullmove"""
    var rotated_board = String()
    for i in range(119, -1, -1):
        rotated_board += self.board[i]
    rotated_board = swapcase(rotated_board)

    return Position(
        rotated_board, -self.score, self.bc, self.wc,
        119 - self.ep if self.ep and not nullmove else 0,
        119 - self.kp if self.kp and not nullmove else 0,
    )

struct Position:
    """A state of a chess game.
    board -- a 120 char representation of the board
    score -- the board evaluation
    wc -- the castling rights, [west/queen side, east/king side]
    bc -- the opponent castling rights, [west/king side, east/queen side]
    ep - the en passant square
    kp - the king passant square
    """
    var board: String
    var score: Int
    var wc: (Bool, Bool)
    var bc: (Bool, Bool)
    var ep: Int
    var kp: Int

    fn __init__(inout self, board: String, score: Int, wc: (Bool, Bool), bc: (Bool, Bool), ep: Int, kp: Int) -> None:
        self.board = board
        self.score = score
        self.wc = wc
        self.bc = bc
        self.ep = ep
        self.kp = kp

    fn __copyinit__(inout self, other: Self) -> None:
        self.board = other.board
        self.score = other.score
        self.wc = other.wc
        self.bc = other.bc
        self.ep = other.ep
        self.kp = other.kp

    def gen_moves(self) -> DynamicVector[Move]:
        let A1 = 91
        let H1 = 98
        let A8 = 21
        let H8 = 28
        let N = -10
        let E = 1
        let S = 10
        let W = -1
        let directions = Python.dict()
        directions["P"] = (N, N+N, N+W, N+E)
        directions["N"] = (N+N+E, E+N+E, E+S+E, S+S+E, S+S+W, W+S+W, W+N+W, N+N+W)
        directions["B"] = (N+E, S+E, S+W, N+W)
        directions["R"] = (N, E, S, W)
        directions["Q"] = (N, E, S, W, N+E, S+E, S+W, N+W)
        directions["K"] = (N, E, S, W, N+E, S+E, S+W, N+W)

        var generated_moves = DynamicVector[Move]()

        # For each of our pieces, iterate through each possible 'ray' of moves,
        # as defined in the 'directions' map. The rays are broken e.g. by
        # captures or immediately in case of pieces such as knights.
        for i in range(120):
            p = self.board[i]
            if not isupper(p):
                continue
            for d in directions[p]:
                var j = i
                while True:
                    j = j + d.to_float64().to_int() # TODO: fix this
                    q = self.board[j]
                    # Stay inside the board, and off friendly pieces
                    if isspace(q) or isupper(q):
                        break
                    # Pawn move, double move and capture
                    if p == "P":
                        if (d == N or d == N + N) and q != ".": break
                        if d == N + N and (i < A1 + N or self.board[i + N] != "."): break
                        if (
                            (d == N + W or d == N + E)
                            and q == "."
                            # and j not in (self.ep, self.kp, self.kp - 1, self.kp + 1)
                            and (j != self.ep and j != self.kp and j != self.kp - 1 and j != self.kp + 1)
                            #and j != self.ep and abs(j - self.kp) >= 2
                        ):
                            break
                        # If we move to the last row, we can be anything
                        if A8 <= j <= H8:
                            generated_moves.push_back(Move(i, j, ord("N")))
                            generated_moves.push_back(Move(i, j, ord("B")))
                            generated_moves.push_back(Move(i, j, ord("R")))
                            generated_moves.push_back(Move(i, j, ord("Q")))

                            break
                    # Move it
                    generated_moves.push_back(Move(i, j, ord(" ")))
                    # Stop crawlers from sliding, and sliding after captures
                    if (p == "P" or p == "N" or p == "K") or islower(q):
                        break
                    # Castling, by sliding the rook next to the king
                    if i == A1 and self.board[j + E] == "K" and self.wc.get[0, Bool]():
                        generated_moves.push_back(Move(j + E, j + W, ord(" ")))
                    if i == H1 and self.board[j + W] == "K" and self.wc.get[1, Bool]():
                        generated_moves.push_back(Move(j + W, j + E, ord(" ")))
        return generated_moves

    def move(self, move: Move) -> Position:
        let N = -10
        let A1 = 91
        let H1 = 98
        let A8 = 21
        let H8 = 28
        var i: Int = move.i
        var j: Int = move.j
        var prom = move.prom
        var p: String = self.board[i]
        var q: String = self.board[j]
        # put = lambda board, i, p: board[:i] + p + board[i + 1 :]
        def put(board: String, i: Int, p: String) -> String:
            return board[:i] + p + board[i + 1 :]
        # Copy variables and reset ep and kp
        board = self.board
        var wc = self.wc
        var bc = self.bc
        var ep = 0
        var kp = 0
        var score: Int = self.score + (calc_value(self, move.i, move.j, move.prom))
        # Actual move
        board = put(board, j, board[i])
        board = put(board, i, ".")
        # Castling rights, we move the rook or capture the opponent's
        if i == A1: wc = (False, wc.get[1, Bool]())
        if i == H1: wc = (wc.get[0, Bool](), False)
        if j == A8: bc = (bc.get[0, Bool](), False)
        if j == H8: bc = (False, bc.get[1, Bool]())
        # Castling
        if p == "K":
            wc = (False, False)
            if abs(j - i) == 2:
                kp = (i + j) // 2
                board = put(board, A1 if j < i else H1, ".")
                board = put(board, kp, "R")
        # Pawn promotion, double move and en passant capture
        let S = 10
        if p == "P":
            if A8 <= j <= H8:
                board = put(board, j, prom)
            if j - i == 2 * N:
                ep = i + N
            if j == self.ep:
                board = put(board, j + S, ".")
        # We rotate the returned position, so it's ready for the next player
        var new_p = Position(board, score, wc, bc, ep, kp)
        new_p = rotate_pos(new_p)
        return new_p


@register_passable("trivial")
struct MoveWithScore:
    var move: Move
    var score: Int
    fn __init__(move: Move, score: Int) -> MoveWithScore:
        return MoveWithScore(move, score)

struct Searcher:
    """A class that implements search and move ordering logic"""
    var tp_score: PythonObject
    var tp_move: PythonObject
    var history: PythonObject
    var nodes: PythonObject
    var Entry: PythonObject

    fn __init__(inout self) -> None:
        try:
            var py = Python.import_module("builtins")
            self.tp_score = py.dict()
            self.tp_move = py.dict()
            self.history = py.set()
            self.nodes = 0
            self.Entry = py.namedtuple("Entry", ["lower", "upper"])
        except:
            pass

    fn __copyinit__(inout self, other: Self) -> None:
        self.tp_score = other.tp_score
        self.tp_move = other.tp_move
        self.history = other.history
        self.nodes = other.nodes

    def bound(self, pos: Position, gamma: Int, depth: Int, can_null=True) -> Int:
        """ Let s* be the "true" score of the sub-tree we are searching.
            The method returns r, where
            if gamma >  s* then s* <= r < gamma  (A better upper bound)
            if gamma <= s* then gamma <= r <= s* (A better lower bound) """
        let piece = Python.dict()
        piece["P"] = 100
        piece["N"] = 280
        piece["B"] = 320
        piece["R"] = 479
        piece["Q"] = 929
        piece["K"] = 60000
        let MATE_LOWER:Int = piece["K"].to_float64().to_int() - 10 * piece["Q"].to_float64().to_int()
        let MATE_UPPER:Int = piece["K"].to_float64().to_int() + 10 * piece["Q"].to_float64().to_int()

        self.nodes += 1

        # Depth <= 0 is QSearch. Here any position is searched as deeply as is needed for
        # calmness, and from this point on there is no difference in behaviour depending on
        # depth, so so there is no reason to keep different depths in the transposition table.
        depth = max(depth, 0)

        # Sunfish is a king-capture engine, so we should always check if we
        # still have a king. Notice since this is the only termination check,
        # the remaining code has to be comfortable with being mated, stalemated
        # or able to capture the opponent king.
        if pos.score <= -MATE_LOWER:
            return -MATE_UPPER

        # Look in the table if we have already searched this position before.
        # We also need to be sure, that the stored search was over the same
        # nodes as the current search.
        entry = self.tp_score.get((pos, depth, can_null), self.Entry(-MATE_UPPER, MATE_UPPER))
        if entry.lower >= gamma:
            return entry.lower.to_float64().to_int()
        if entry.upper < gamma:
            return entry.upper.to_float64().to_int()

        # Let's not repeat positions. We don't chat
        # - at the root (can_null=False) since it is in history, but not a draw.
        # - at depth=0, since it would be expensive and break "futulity pruning".
        # if can_null and depth > 0 and not Python.is_type(self.history.get(pos), Python.none()):
        #     return 0

        # Generator of moves to search in order.
        # This allows us to define the moves, but only calculate them if needed.
        def moves() -> DynamicVector[MoveWithScore]:
            let py = Python.import_module("builtins")
            let namedtuple = Python.import_module("collections").namedtuple
            var ret_moves = DynamicVector[MoveWithScore]()
            # First try not moving at all. We only do this if there is at least one major
            # piece left on the board, since otherwise zugzwangs are too dangerous.
            # FIXME: We also can't null move if we can capture the opponent king.
            # Since if we do, we won't spot illegal moves that could lead to stalemate.
            # For now we just solve this by not using null-move in very unbalanced positions.
            # TODO: We could actually use null-move in QS as well. Not sure it would be very useful.
            # But still.... We just have to move stand-pat to be before null-move.
            #if depth > 2 and can_null and any(c in pos.board for c in "RBNQ"):
            #if depth > 2 and can_null and any(c in pos.board for c in "RBNQ") and abs(pos.score) < 500:
            var tmp_score: Int = 0
            if depth > 2 and can_null and abs(pos.score) < 500:
                ret_moves.push_back(MoveWithScore(Move(0, 0, 0), -self.bound(rotate_pos(pos, nullmove=True), 1 - gamma, depth - 3)))

            # For QSearch we have a different kind of null-move, namely we can just stop
            # and not capture anything else.
            if depth == 0:
                ret_moves.push_back(MoveWithScore(Move(0, 0, 0), pos.score))

            # Look for the strongest ove from last time, the hash-move.
            var killer = self.tp_move.get(namedtuple("pos", ["board", "wc", "bc", "ep", "kp"])(
                pos.board, pos.wc, pos.bc, pos.ep, pos.kp
            ))

            # If there isn't one, try to find one with a more shallow search.
            # This is known as Internal Iterative Deepening (IID). We set
            # can_null=True, since we want to make sure we actually find a move.
            if not killer and depth > 2:
                self.bound(pos, gamma, depth - 3, can_null=False)
                killer = self.tp_move.get(namedtuple("pos", ["board", "wc", "bc", "ep", "kp"])(
                    pos.board, pos.wc, pos.bc, pos.ep, pos.kp
                ))

            # If depth == 0 we only try moves with high intrinsic score (captures and
            # promotions). Otherwise we do all moves. This is called quiescent search.
            let QS = 40
            let QS_A = 140
            let EVAL_ROUGHNESS = 15
            var val_lower = QS - depth * QS_A

            # Only play the move if it would be included at the current val-limit,
            # since otherwise we'd get search instability.
            # We will search it again in the main loop below, but the tp will fix
            # things for us.
            if killer and calc_value(pos, killer.i.to_float64().to_int(), killer.j.to_float64().to_int(), killer.to_float64().to_int()) >= val_lower:
                var move: Move = Move(
                    killer.i.to_float64().to_int(),
                    killer.j.to_float64().to_int(),
                    killer.prom.to_float64().to_int()
                )
                var new_pos = Position(pos.board, pos.score, pos.wc, pos.bc, pos.ep, pos.kp)
                var killer_move: Move = Move(
                    killer.i.to_float64().to_int(),
                    killer.j.to_float64().to_int(),
                    killer.prom.to_float64().to_int()
                )
                new_pos = new_pos.move(killer_move)
                ret_moves.push_back(MoveWithScore(killer_move, -self.bound(new_pos, 1 - gamma, depth - 1)))

            # Then all the other moves
            var generated_moves = pos.gen_moves()
            var values = DynamicVector[Int]()
            for i in range(len(generated_moves)):
                var move = generated_moves[i]
                values.push_back(calc_value(pos, move.i, move.j, move.prom))
            # Sort the moves by their static score (reverse)
            for i in range(len(generated_moves)):
                for j in range(i + 1, len(generated_moves)):
                    if values[i] < values[j]:
                        values[i], values[j] = values[j], values[i]
                        generated_moves[i], generated_moves[j] = generated_moves[j], generated_moves[i]

            for i in range(len(generated_moves)):
                var move = generated_moves[i]
                var val = values[i]
                # Quiescent search
                if val < val_lower:
                    break

                # If the new score is less than gamma, the opponent will for sure just
                # stand pat, since ""pos.score + val < gamma === -(pos.score + val) >= 1-gamma""
                # This is known as futility pruning.
                if depth <= 1 and pos.score + val < gamma:
                    # Need special case for MATE, since it would normally be caught
                    # before standing pat.
                    ret_moves.push_back(MoveWithScore(move, pos.score + val if val < MATE_LOWER else MATE_UPPER))
                    # We can also break, since we have ordered the moves by value,
                    # so it can't get any better than this.
                    break

                ret_moves.push_back(MoveWithScore(move, -self.bound(pos.move(move), 1 - gamma, depth - 1)))

        # Run through the moves, shortcutting when possible
        best = -MATE_UPPER
        var ret_moves: DynamicVector[MoveWithScore] = moves()
        for i in range(len(ret_moves)):
            var move = ret_moves[i].move
            var score = ret_moves[i].score
            best = max(best, score)
            if best >= gamma:
                # Save the move for pv construction and killer heuristic
                if move.i != 0 or move.j != 0 or move.prom != 0:
                    self.tp_move[pos] = move
                break

        # Stalemate checking is a bit tricky: Say we failed low, because
        # we can't (legally) move and so the (real) score is -infty.
        # At the next depth we are allowed to just return r, -infty <= r < gamma,
        # which is normally fine.
        # However, what if gamma = -10 and we don't have any legal moves?
        # Then the score is actaully a draw and we should fail high!
        # Thus, if best < gamma and best < 0 we need to double check what we are doing.

        # We will fix this problem another way: We add the requirement to bound, that
        # it always returns MATE_UPPER if the king is capturable. Even if another move
        # was also sufficient to go above gamma. If we see this value we know we are either
        # mate, or stalemate. It then suffices to check whether we're in check.

        # Note that at low depths, this may not actually be true, since maybe we just pruned
        # all the legal moves. So sunfish may report "mate", but then after more search
        # realize it's not a mate after all. That's fair.

        # This is too expensive to test at depth == 0
        if depth > 2 and best == -MATE_UPPER:
            flipped = pos.rotate(nullmove=True)
            # Hopefully this is already in the TT because of null-move
            in_check = self.bound(flipped, MATE_UPPER, 0) == MATE_UPPER
            best = -MATE_LOWER if in_check else 0

        # Table part 2
        if best >= gamma:
            self.tp_score[pos, depth, can_null] = self.Entry(best, entry.upper)
        if best < gamma:
            self.tp_score[pos, depth, can_null] = self.Entry(entry.lower, best)

        return best

    def search(self, history: PythonObject):
        """Iterative deepening MTD-bi search"""
        let py = Python.import_module("builtins")
        let piece = Python.dict()
        piece["P"] = 100
        piece["N"] = 280
        piece["B"] = 320
        piece["R"] = 479
        piece["Q"] = 929
        piece["K"] = 60000
        let MATE_LOWER:Int = piece["K"].to_float64().to_int() - 10 * piece["Q"].to_float64().to_int()
        let MATE_UPPER:Int = piece["K"].to_float64().to_int() + 10 * piece["Q"].to_float64().to_int()
        self.nodes = 0
        self.history = py.set(history)
        self.tp_score.clear()

        gamma = 0
        # In finished games, we could potentially go far enough to cause a recursion
        # limit exception. Hence we bound the ply. We also can't start at 0, since
        # that's quiscent search, and we don't always play legal moves there.
        for depth in range(1, 1000):
            # The inner loop is a binary search on the score of the position.
            # Inv: lower <= score <= upper
            # 'while lower != upper' would work, but it's too much effort to spend
            # on what's probably not going to change the move played.
            var lower: Int = -MATE_LOWER
            var upper: Int = MATE_LOWER
            let EVAL_ROUGHNESS = 15
            while lower < upper - EVAL_ROUGHNESS:
                var score = self.bound(history[-1], gamma, depth, can_null=False)
                if score >= gamma:
                    lower = score.to_float64().to_int()
                if score < gamma:
                    upper = score.to_float64().to_int()
                yield depth, gamma, score, self.tp_move.get(history[-1])
                gamma = (lower + upper + 1) // 2



def parse(c: String):
    let A1 = 91
    fil = ord(c[0]) - ord("a")
    rank = ord(c[1]) - ord('0') - 1
    return A1 + fil - 10 * rank


def render(i: Int) -> String:
    let A1 = 91
    # rank, fil = divmod(i - A1, 10)
    let rank = (i - A1) // 10
    let fil = (i - A1) % 10
    var ret = chr(fil + ord("a"))
    ret += (-rank + 1)
    return ret

###############################################################################
# Piece-Square tables.
###############################################################################
fn use_dict() raises:
    let py = Python.import_module("builtins")

    ###############################################################################
    # Global constants
    ###############################################################################

    # Our board is represented as a 120 character string. The padding allows for
    # fast detection of moves that don't stay within the board.
    let A1 = 91
    let H1 = 98
    let A8 = 21
    let H8 = 28
    let initial = (
        "         \n"  #   0 -  9
        "         \n"  #  10 - 19
        " rnbqkbnr\n"  #  20 - 29
        " pppppppp\n"  #  30 - 39
        " ........\n"  #  40 - 49
        " ........\n"  #  50 - 59
        " ........\n"  #  60 - 69
        " ........\n"  #  70 - 79
        " PPPPPPPP\n"  #  80 - 89
        " RNBQKBNR\n"  #  90 - 99
        "         \n"  # 100 -109
        "         \n"  # 110 -119
    )

    # Lists of possible moves for each piece type.
    let N = -10
    let E = 1
    let S = 10
    let W = -1
    let directions = Python.dict()
    directions["P"] = (N, N+N, N+W, N+E)
    directions["N"] = (N+N+E, E+N+E, E+S+E, S+S+E, S+S+W, W+S+W, W+N+W, N+N+W)
    directions["B"] = (N+E, S+E, S+W, N+W)
    directions["R"] = (N, E, S, W)
    directions["Q"] = (N, E, S, W, N+E, S+E, S+W, N+W)
    directions["K"] = (N, E, S, W, N+E, S+E, S+W, N+W)

    # Mate value must be greater than 8*queen + 2*(rook+knight+bishop)
    # King value is set to twice this value such that if the opponent is
    # 8 queens up, but we got the king, we still exceed MATE_VALUE.
    # When a MATE is detected, we'll set the score to MATE_UPPER - plies to get there
    # E.g. Mate in 3 will be MATE_UPPER - 6
    let piece = Python.dict()
    piece["P"] = 100
    piece["N"] = 280
    piece["B"] = 320
    piece["R"] = 479
    piece["Q"] = 929
    piece["K"] = 60000
    let MATE_LOWER:Int = piece["K"].to_float64().to_int() - 10 * piece["Q"].to_float64().to_int()
    let MATE_UPPER:Int = piece["K"].to_float64().to_int() + 10 * piece["Q"].to_float64().to_int()

    # Constants for tuning search
    let QS = 40
    let QS_A = 140
    let EVAL_ROUGHNESS = 15

    let opt_ranges = Python.dict()
    opt_ranges["QS"] = (0, 300)
    opt_ranges["QS_A"] = (0, 300)
    opt_ranges["EVAL_ROUGHNESS"] = (0, 50)

    var hist = py.list([Position(initial, 0, (True, True), (True, True), 0, 0)])
    var searcher = Searcher()
    while True:
        # args = input().split()
        var args = PythonObject()
        args = py.input().split()

        if args[0] == "uci":
            print("id name mojochess")
            print("uciok")

        elif args[0] == "isready":
            print("readyok")

        elif args[0] == "quit":
            break

        elif args[0] == "start" and args[1] == "pos":
            hist = hist[0]
            for ply, move in enumerate(args[3:]):
                i, j, prom = parse(move[:2]), parse(move[2:4]), move[4:].upper()
                if ply % 2 == 1:
                    i, j = 119 - i, 119 - j
                hist.append(hist[-1].move(Move(i, j, prom)))

        elif args[0] == "go":
            wtime, btime, winc, binc = [int(a) / 1000 for a in args[2::2]]
            if len(hist) % 2 == 0:
                wtime, winc = btime, binc
            think = min(wtime / 40 + winc, wtime / 2 - 1)

            start = time.time()
            move_str = None
            for depth, gamma, score, move in Searcher().search(hist):
                # The only way we can be sure to have the real move in tp_move,
                # is if we have just failed high.
                if score >= gamma:
                    i, j = move.i, move.j
                    if len(hist) % 2 == 0:
                        i, j = 119 - i, 119 - j
                    move_str = render(i) + render(j) + move.prom.lower()
                    print("info depth", depth, "score cp", score, "pv", move_str)
                if move_str and time.time() - start > think * 0.8:
                    break

            print("bestmove", move_str or '(none)')


fn main() -> None:
    try:
        use_dict()
    except:
        pass


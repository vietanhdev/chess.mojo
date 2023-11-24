#!/usr/bin/env mojo

import time
from python import Python


def isupper(c: String):
    return ord("A") <= ord(c) <= ord("Z")

def islower(c: String):
    return ord("a") <= ord(c) <= ord("z")

def isspace(c: String):
    return c == " " or c == "\n"

def upper(c: String) -> String:
    if islower(c):
        return chr(ord(c) - ord("a") + ord("A"))
    return c

def lower(c: String) -> String:
    if isupper(c):
        return chr(ord(c) - ord("A") + ord("a"))
    return c

def switchcase(c: String) -> String:
    if isupper(c):
        return lower(c)
    return upper(c)

def switchcase(c: Int) -> Int:
    if isupper(chr(c)):
        return ord(lower(chr(c)))
    return ord(upper(chr(c)))

def swapboard(board: String) -> String:
    """Reverse and swap the case of a board."""
    if board == "": return ""
    var ret: String = ""
    for i in range(len(board) - 1, -1, -1):
        c = board[i]
        if isupper(c):
            ret += lower(c)
        else:
            ret += upper(c)
    return ret

def abs(x: Int) -> Int:
    if x < 0:
        return -x
    return x

def max(x: Int, y: Int) -> Int:
    if x > y:
        return x
    return y

def min(x: Int, y: Int) -> Int:
    if x < y:
        return x
    return y

struct Position:
    """
    A state of a game.
    board -- a 120 char representation of the board
    score -- the board evaluation
    wc -- the castling rights, [west/queen side, east/king side]
    bc -- the opponent castling rights, [west/king side, east/queen side]
    ep - the en passant square
    kp - the king passant square.
    """
    var board: String
    var score: Int
    var wc: (Int, Int)
    var bc: (Int, Int)
    var ep: Int
    var kp: Int

    var direction_N: Int
    var direction_E: Int
    var direction_S: Int
    var direction_W: Int

    var A1: Int
    var H1: Int
    var A8: Int
    var H8: Int

    fn __init__(inout self, board: String, score: Int, wc: (Int, Int), bc: (Int, Int), ep: Int, kp: Int):
        self.board = board
        self.score = score
        self.wc = wc
        self.bc = bc
        self.ep = ep
        self.kp = kp

        # Constants
        self.direction_N = -10
        self.direction_E = 1
        self.direction_S = 10
        self.direction_W = -1

        # Our board is represented as a 120 character string. The padding allows for
        # fast detection of moves that don't stay within the board.
        self.A1, self.H1, self.A8, self.H8 = 91, 98, 21, 28

    fn __copyinit__(inout self, other: Position):
        self.board = other.board
        self.score = other.score
        self.wc = other.wc
        self.bc = other.bc
        self.ep = other.ep
        self.kp = other.kp

        # Constants
        self.direction_N = -10
        self.direction_E = 1
        self.direction_S = 10
        self.direction_W = -1

        # Our board is represented as a 120 character string. The padding allows for
        # fast detection of moves that don't stay within the board.
        self.A1, self.H1, self.A8, self.H8 = 91, 98, 21, 28

    def gen_moves(inout self) -> DynamicVector[(Int, Int, Int)]:
        # Lists of possible moves for each piece type.
        # N, E, S, W = -10, 1, 10, -1
        let N: Int = -10
        let E: Int = 1
        let S: Int = 10
        let W: Int = -1
        let p_directions = Python.dict()
        p_directions["P"] = (N, N+N, N+W, N+E)
        p_directions["N"] = (N+N+E, E+N+E, E+S+E, S+S+E, S+S+W, W+S+W, W+N+W, N+N+W)
        p_directions["B"] = (N+E, S+E, S+W, N+W)
        p_directions["R"] = (N, E, S, W)
        p_directions["Q"] = (N, E, S, W, N+E, S+E, S+W, N+W)
        p_directions["K"] = (N, E, S, W, N+E, S+E, S+W, N+W)
        generated_moves = DynamicVector[(Int, Int, Int)]()
        # For each of our pieces, iterate through each possible 'ray' of moves,
        # as defined in the 'directions' map. The rays are broken e.g. by
        # captures or immediately in case of pieces such as knights.
        for i in range(len(self.board)):
            let p: String = self.board[i]
            if not isupper(p):
                continue
            for d_py in p_directions[p]:
                let d = d_py.to_float64().to_int() # TODO: Fix it
                var j: Int = i
                while True:
                    j = j + d
                    q = self.board[j]
                    # Stay inside the board, and off friendly pieces
                    if isspace(q) or isupper(q):
                        break
                    # Pawn move, double move and capture
                    if p == "P":
                        if (d == N or d == N + N) and q != ".": break
                        if d == N + N and (i < self.A1 + N or self.board[i + N] != "."): break
                        if (
                            (d == N + W or d == N + E)
                            and q == "."
                            and (j != self.ep and j != self.kp and j != self.kp - 1 and j != self.kp + 1)
                        ):
                            break
                        # If we move to the last row, we can be anything
                        if self.A8 <= j <= self.H8:
                            generated_moves.push_back((i, j, ord("N")))
                            generated_moves.push_back((i, j, ord("B")))
                            generated_moves.push_back((i, j, ord("R")))
                            generated_moves.push_back((i, j, ord("Q")))
                            break
                    # Move it
                    generated_moves.push_back((i, j, 0))
                    # Stop crawlers from sliding, and sliding after captures
                    if (p == "P" or p == "N" or p == "K") or islower(q):
                        break
                    # Castling, by sliding the rook next to the king
                    if i == self.A1 and self.board[j + E] == "K" and self.wc.get[0, Int]():
                        generated_moves.push_back((j + E, j + W, 0))
                    if i == self.H1 and self.board[j + W] == "K" and self.wc.get[1, Int]():
                        generated_moves.push_back((j + W, j + E, 0))
        return generated_moves

    def rotate(self, nullmove=False) -> Position:
        """Rotates the board, preserving enpassant, unless nullmove."""
        return Position(
            swapboard(self.board), -self.score, self.bc, self.wc,
            119 - self.ep if self.ep and not nullmove else 0,
            119 - self.kp if self.kp and not nullmove else 0,
        )

    def move(self, move: (Int, Int, Int)) -> Position:
        var i: Int = move.get[0, Int]()
        var j: Int = move.get[1, Int]()
        var prom: String = chr(move.get[2, Int]())
        var p: String = self.board[i]
        var q: String = self.board[j]
        def put(board: String, i: Int, p: String) -> String:
            return board[:i] + p + board[i + 1 :]
        # Copy variables and reset ep and kp
        var board = self.board
        var wc: (Int, Int) = self.wc
        var bc: (Int, Int) = self.bc
        var ep: Int = 0
        var kp: Int = 0
        var score: Int = self.score + self.value(move)
        # Actual move
        board = put(board, j, board[i])
        board = put(board, i, ".")
        # Castling rights, we move the rook or capture the opponent's
        if i == self.A1: wc = (0, wc.get[1, Int]())
        if i == self.H1: wc = (wc.get[0, Int](), 0)
        if j == self.A8: bc = (bc.get[0, Int](), 0)
        if j == self.H8: bc = (0, bc.get[1, Int]())
        # Castling
        if p == "K":
            wc = (0, 0)
            if abs(j - i) == 2:
                kp = (i + j) // 2
                board = put(board, self.A1 if j < i else self.H1, ".")
                board = put(board, kp, "R")
        # Pawn promotion, double move and en passant capture
        if p == "P":
            if self.A8 <= j <= self.H8:
                board = put(board, j, prom)
            if j - i == 2 * self.direction_N:
                ep = i + self.direction_N
            if j == self.ep:
                board = put(board, j + self.direction_S, ".")
        # We rotate the returned position, so it's ready for the next player
        return Position(board, score, wc, bc, ep, kp).rotate()

    def value(inout self, move: (Int, Int, Int)) -> Int:
        let pst = Python.dict()
        pst["P"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 178, 183, 186, 173, 202, 182, 185, 190, 0, 0, 107, 129, 121, 144, 140, 131, 144, 107, 0, 0, 83, 116, 98, 115, 114, 100, 115, 87, 0, 0, 74, 103, 110, 109, 106, 101, 100, 77, 0, 0, 78, 109, 105, 89, 90, 98, 103, 81, 0, 0, 69, 108, 93, 63, 64, 86, 103, 69, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        pst["N"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 214, 227, 205, 205, 270, 225, 222, 210, 0, 0, 277, 274, 380, 244, 284, 342, 276, 266, 0, 0, 290, 347, 281, 354, 353, 307, 342, 278, 0, 0, 304, 304, 325, 317, 313, 321, 305, 297, 0, 0, 279, 285, 311, 301, 302, 315, 282, 280, 0, 0, 262, 290, 293, 302, 298, 295, 291, 266, 0, 0, 257, 265, 282, 280, 282, 280, 257, 260, 0, 0, 206, 257, 254, 256, 261, 245, 258, 211, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        pst["B"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 261, 242, 238, 244, 297, 213, 283, 270, 0, 0, 309, 340, 355, 278, 281, 351, 322, 298, 0, 0, 311, 359, 288, 361, 372, 310, 348, 306, 0, 0, 345, 337, 340, 354, 346, 345, 335, 330, 0, 0, 333, 330, 337, 343, 337, 336, 320, 327, 0, 0, 334, 345, 344, 335, 328, 345, 340, 335, 0, 0, 339, 340, 331, 326, 327, 326, 340, 336, 0, 0, 313, 322, 305, 308, 306, 305, 310, 310, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        pst["R"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 514, 508, 512, 483, 516, 512, 535, 529, 0, 0, 534, 508, 535, 546, 534, 541, 513, 539, 0, 0, 498, 514, 507, 512, 524, 506, 504, 494, 0, 0, 479, 484, 495, 492, 497, 475, 470, 473, 0, 0, 451, 444, 463, 458, 466, 450, 433, 449, 0, 0, 437, 451, 437, 454, 454, 444, 453, 433, 0, 0, 426, 441, 448, 453, 450, 436, 435, 426, 0, 0, 449, 455, 461, 484, 477, 461, 448, 447, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        pst["Q"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 935, 930, 921, 825, 998, 953, 1017, 955, 0, 0, 943, 961, 989, 919, 949, 1005, 986, 953, 0, 0, 927, 972, 961, 989, 1001, 992, 972, 931, 0, 0, 930, 913, 951, 946, 954, 949, 916, 923, 0, 0, 915, 914, 927, 924, 928, 919, 909, 907, 0, 0, 899, 923, 916, 918, 913, 918, 913, 902, 0, 0, 893, 911, 929, 910, 914, 914, 908, 891, 0, 0, 890, 899, 898, 916, 898, 893, 895, 887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
        pst["K"] = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60004, 60054, 60047, 59901, 59901, 60060, 60083, 59938, 0, 0, 59968, 60010, 60055, 60056, 60056, 60055, 60010, 60003, 0, 0, 59938, 60012, 59943, 60044, 59933, 60028, 60037, 59969, 0, 0, 59945, 60050, 60011, 59996, 59981, 60013, 60000, 59951, 0, 0, 59945, 59957, 59948, 59972, 59949, 59953, 59992, 59950, 0, 0, 59953, 59958, 59957, 59921, 59936, 59968, 59971, 59968, 0, 0, 59996, 60003, 59986, 59950, 59943, 59982, 60013, 60004, 0, 0, 60017, 60030, 59997, 59986, 60006, 59999, 60040, 60018, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)

        let i: Int = move.get[0, Int]()
        let j: Int = move.get[1, Int]()
        let prom: String = chr(move.get[2, Int]())

        let p: String = self.board[i]
        let q: String = self.board[j]

        # Actual move
        var score: Int = (pst[p][j] - pst[p][i]).to_float64().to_int() # TODO: Fix it
        # Capture
        if islower(q):
            score += pst[upper(q)][119 - j].to_float64().to_int() # TODO: Fix it
        # Castling check detection
        if abs(j - self.kp) < 2:
            score += pst["K"][119 - j].to_float64().to_int() # TODO: Fix it
        # Castling
        if p == "K" and abs(i - j) == 2:
            score += pst["R"][(i + j) // 2].to_float64().to_int() # TODO: Fix it
            score -= pst["R"][self.A1 if j < i else self.H1].to_float64().to_int() # TODO: Fix it
        # Special pawn stuff
        if p == "P":
            if self.A8 <= j <= self.H8:
                score += pst[prom][j].to_float64().to_int() - pst["P"][j].to_float64().to_int() # TODO: Fix it
            if j == self.ep:
                score += pst["P"][119 - (j + self.direction_S)].to_float64().to_int() # TODO: Fix it
        return score

def board_str_to_numbers(board: String) -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int):
    """Encode 120 char board to 30 Ints with 32 bits each."""
    # TODO: Encode the chessboard more efficiently
    var ret: DynamicVector[Int] = DynamicVector[Int]()
    for i in range(len(board)//4):
        let c1: String = board[i*4]
        let c2: String = board[i*4 + 1]
        let c3: String = board[i*4 + 2]
        let c4: String = board[i*4 + 3]
        let n: Int = ord(c1) + ord(c2) * 256 + ord(c3) * 65536 + ord(c4) * 16777216
        ret.push_back(n)
    return (ret[0], ret[1], ret[2], ret[3], ret[4], ret[5], ret[6], ret[7], ret[8], ret[9], ret[10], ret[11], ret[12], ret[13], ret[14], ret[15], ret[16], ret[17], ret[18], ret[19], ret[20], ret[21], ret[22], ret[23], ret[24], ret[25], ret[26], ret[27], ret[28], ret[29])

def numbers_to_board_str(board: DynamicVector[Int]) -> String:
    """Decode 30 Ints with 32 bits each to 120 char board."""
    var ret: String = ""
    for i in range(len(board)):
        let n: Int = board[i]
        let c1: String = chr(n % 256)
        let c2: String = chr((n // 256) % 256)
        let c3: String = chr((n // 65536) % 256)
        let c4: String = chr((n // 16777216) % 256)
        ret += c1 + c2 + c3 + c4
    return ret

def get_tp_score_key(pos: Position, depth: Int, can_null: Int) -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int):
    let e = board_str_to_numbers(pos.board)
    return (
        e.get[0, Int](), e.get[1, Int](), e.get[2, Int](), e.get[3, Int](), e.get[4, Int](), e.get[5, Int](), e.get[6, Int](), e.get[7, Int](), e.get[8, Int](), e.get[9, Int](), e.get[10, Int](), e.get[11, Int](), e.get[12, Int](), e.get[13, Int](), e.get[14, Int](), e.get[15, Int](), e.get[16, Int](), e.get[17, Int](), e.get[18, Int](), e.get[19, Int](), e.get[20, Int](), e.get[21, Int](), e.get[22, Int](), e.get[23, Int](), e.get[24, Int](), e.get[25, Int](), e.get[26, Int](), e.get[27, Int](), e.get[28, Int](), e.get[29, Int](), pos.score, pos.wc.get[0, Int](), pos.wc.get[1, Int](), pos.bc.get[0, Int](), pos.bc.get[1, Int](), pos.ep, pos.kp, depth, can_null
    )

def get_tp_move_key(pos: Position) -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int):
    let e = board_str_to_numbers(pos.board)
    return (
        e.get[0, Int](), e.get[1, Int](), e.get[2, Int](), e.get[3, Int](), e.get[4, Int](), e.get[5, Int](), e.get[6, Int](), e.get[7, Int](), e.get[8, Int](), e.get[9, Int](), e.get[10, Int](), e.get[11, Int](), e.get[12, Int](), e.get[13, Int](), e.get[14, Int](), e.get[15, Int](), e.get[16, Int](), e.get[17, Int](), e.get[18, Int](), e.get[19, Int](), e.get[20, Int](), e.get[21, Int](), e.get[22, Int](), e.get[23, Int](), e.get[24, Int](), e.get[25, Int](), e.get[26, Int](), e.get[27, Int](), e.get[28, Int](), e.get[29, Int](), pos.score, pos.wc.get[0, Int](), pos.wc.get[1, Int](), pos.bc.get[0, Int](), pos.bc.get[1, Int](), pos.ep, pos.kp
    )

def get_history_key(pos: Position) -> (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int, Int):
    let e = board_str_to_numbers(pos.board)
    return (
        e.get[0, Int](), e.get[1, Int](), e.get[2, Int](), e.get[3, Int](), e.get[4, Int](), e.get[5, Int](), e.get[6, Int](), e.get[7, Int](), e.get[8, Int](), e.get[9, Int](), e.get[10, Int](), e.get[11, Int](), e.get[12, Int](), e.get[13, Int](), e.get[14, Int](), e.get[15, Int](), e.get[16, Int](), e.get[17, Int](), e.get[18, Int](), e.get[19, Int](), e.get[20, Int](), e.get[21, Int](), e.get[22, Int](), e.get[23, Int](), e.get[24, Int](), e.get[25, Int](), e.get[26, Int](), e.get[27, Int](), e.get[28, Int](), e.get[29, Int](), pos.score, pos.wc.get[0, Int](), pos.wc.get[1, Int](), pos.bc.get[0, Int](), pos.bc.get[1, Int](), pos.ep, pos.kp
    )

def py_position_to_position(pos: PythonObject) -> Position:
    var board_numbers = DynamicVector[Int]()
    for i in range(30):
        board_numbers.push_back(pos[i].to_float64().to_int()) # TODO: Fix it
    let board = numbers_to_board_str(board_numbers)
    # score: Int, wc: (Int, Int), bc: (Int, Int), ep: Int, kp: Int
    return Position(
        board,
        pos[30].to_float64().to_int(), # TODO: Fix it
        (pos[31].to_float64().to_int(), pos[32].to_float64().to_int()), # TODO: Fix it
        (pos[33].to_float64().to_int(), pos[34].to_float64().to_int()), # TODO: Fix it
        pos[35].to_float64().to_int(), # TODO: Fix it
        pos[36].to_float64().to_int(), # TODO: Fix it
    )

def py_move_to_move(move: PythonObject) -> (Int, Int, Int):
    return move[0].to_float64().to_int(), move[1].to_float64().to_int(), move[2].to_float64().to_int() # TODO: Fix it

def print_move(move: (Int, Int, Int)):
    let a: String =  render(move.get[0, Int]()) + render(move.get[1, Int]()) + lower(chr(move.get[2, Int]()))
    print(a)

# lower <= s(pos) <= upper
struct Searcher:
    """A class that can search a position to a given depth."""
    var tp_score: PythonObject
    var tp_move: PythonObject
    var history: PythonObject
    var nodes: Int
    var MATE_LOWER: Int
    var MATE_UPPER: Int

    def __init__(inout self):
        let py = Python.import_module("builtins")
        self.tp_score = py.dict()
        self.tp_move = py.dict()
        self.history = py.set()
        self.nodes = 0

        # Mate value must be greater than 8*queen + 2*(rook+knight+bishop)
        # King value is set to twice this value such that if the opponent is
        # 8 queens up, but we got the king, we still exceed MATE_VALUE.
        # When a MATE is detected, we'll set the score to MATE_UPPER - plies to get there
        # E.g. Mate in 3 will be MATE_UPPER - 6
        # piece = {"P": 100, "N": 280, "B": 320, "R": 479, "Q": 929, "K": 60000}
        # self.MATE_LOWER = piece["K"] - 10 * piece["Q"]
        # self.MATE_UPPER = piece["K"] + 10 * piece["Q"]
        self.MATE_LOWER = 60000 - 10 * 929
        self.MATE_UPPER = 60000 + 10 * 929

    def bound(inout self, pos: Position, gamma: Int, depth: Int, can_null: Int=1) -> Int:
        """ Let s* be the "true" score of the sub-tree we are searching.
            The method returns r, where
            if gamma >  s* then s* <= r < gamma  (A better upper bound)
            if gamma <= s* then gamma <= r <= s* (A better lower bound)."""
        self.nodes += 1

        # Depth <= 0 is QSearch. Here any position is searched as deeply as is needed for
        # calmness, and from this point on there is no difference in behaviour depending on
        # depth, so so there is no reason to keep different depths in the transposition table.
        depth = max(depth, 0)

        # Sunfish is a king-capture engine, so we should always check if we
        # still have a king. Notice since this is the only termination check,
        # the remaining code has to be comfortable with being mated, stalemated
        # or able to capture the opponent king.
        if pos.score <= -self.MATE_LOWER:
            return -self.MATE_UPPER

        # Look in the table if we have already searched this position before.
        # We also need to be sure, that the stored search was over the same
        # nodes as the current search.
        var entry_py: PythonObject = self.tp_score.get(get_tp_score_key(pos, depth, can_null), (-self.MATE_UPPER, self.MATE_UPPER))
        var entry: (Int, Int) = (entry_py[0].to_float64().to_int(), entry_py[1].to_float64().to_int()) # TODO: Fix it
        if entry.get[0, Int]() >= gamma: return entry.get[0, Int]()
        if entry.get[1, Int]() < gamma: return entry.get[1, Int]()

        # Let's not repeat positions. We don't chat
        # - at the root (can_null=False) since it is in history, but not a draw.
        # - at depth=0, since it would be expensive and break "futulity pruning".
        if can_null and depth > 0 and self.history.__contains__(get_history_key(pos)):
            return 0

        # Generator of moves to search in order.
        # This allows us to define the moves, but only calculate them if needed.
        # Run through the moves, shortcutting when possible
        var best: Int = -self.MATE_UPPER
        def check(inout pos: Position, tp_move: PythonObject, inout best: Int, move: (Int, Int, Int), score: Int) -> Bool:
            best = max(best, score)
            if best >= gamma:
                # Save the move for pv construction and killer heuristic
                if move.get[2, Int]() != -1:
                    let key = get_tp_move_key(pos)
                    tp_move.__setitem__(key, (
                        move.get[0, Int](),
                        move.get[1, Int](),
                        move.get[2, Int](),
                    ))
                return True
            return False

        # First try not moving at all. We only do this if there is at least one major
        # piece left on the board, since otherwise zugzwangs are too dangerous.
        # FIXME: We also can't null move if we can capture the opponent king.
        # Since if we do, we won't spot illegal moves that could lead to stalemate.
        # For now we just solve this by not using null-move in very unbalanced positions.
        # TODO: We could actually use null-move in QS as well. Not sure it would be very useful.
        # But still.... We just have to move stand-pat to be before null-move.
        #if depth > 2 and can_null and any(c in pos.board for c in "RBNQ"):
        #if depth > 2 and can_null and any(c in pos.board for c in "RBNQ") and abs(pos.score) < 500:
        var should_stop: Bool = False
        if depth > 2 and can_null and abs(pos.score) < 500:
            var score_1: Int = -self.bound(pos.rotate(nullmove=True), 1 - gamma, depth - 3)
            should_stop = check(pos, self.tp_move, best, (-1, -1, -1), score_1)

        if not should_stop:
            # For QSearch we have a different kind of null-move, namely we can just stop
            # and not capture anything else.
            if depth == 0:
                should_stop = check(pos, self.tp_move, best, (-1, -1, -1), pos.score)

        var val_lower: Int = 0

        if not should_stop:
            # Look for the strongest ove from last time, the hash-move.
            var killer_py: PythonObject = self.tp_move.get(get_tp_move_key(pos))
            var killer: (Int, Int, Int) = (-1, -1, -1)
            if not Python.is_type(killer_py, Python.none()):
                killer = (killer_py[0].to_float64().to_int(), killer_py[1].to_float64().to_int(), killer_py[2].to_float64().to_int()) # TODO: Fix it

            # If there isn't one, try to find one with a more shallow search.
            # This is known as Internal Iterative Deepening (IID). We set
            # can_null=True, since we want to make sure we actually find a move.
            if Python.is_type(killer_py, Python.none()) and depth > 2:
                self.bound(pos, gamma, depth - 3, can_null=0)
                killer_py = self.tp_move.get(get_tp_move_key(pos))
                if not Python.is_type(killer_py, Python.none()):
                    killer = (killer_py[0].to_float64().to_int(), killer_py[1].to_float64().to_int(), killer_py.to_float64().to_int()) # TODO: Fix it

            # If depth == 0 we only try moves with high intrinsic score (captures and
            # promotions). Otherwise we do all moves. This is called quiescent search.
            QS = 40
            QS_A = 140
            val_lower = QS - depth * QS_A

            # Only play the move if it would be included at the current val-limit,
            # since otherwise we'd get search instability.
            # We will search it again in the main loop below, but the tp will fix
            # things for us.
            if not Python.is_type(killer_py, Python.none()) and pos.value(killer) >= val_lower:
                should_stop = check(pos, self.tp_move, best, killer, -self.bound(pos.move(killer), 1 - gamma, depth - 1))

        # Then all the other moves
        if not should_stop:
            var pos_moves: DynamicVector[(Int, Int, Int)] = pos.gen_moves()
            var values: DynamicVector[Int] = DynamicVector[Int]()
            for i in range(len(pos_moves)):
                var move: (Int, Int, Int) = pos_moves[i]
                values.push_back(pos.value(move))

            # Sort the moves by their static score reversed, so the best moves are first
            for i in range(len(pos_moves)):
                for j in range(i + 1, len(pos_moves)):
                    if values[i] < values[j]:
                        values[i], values[j] = values[j], values[i]
                        pos_moves[i], pos_moves[j] = pos_moves[j], pos_moves[i]

            for i in range(len(pos_moves)):
                var move: (Int, Int, Int) = pos_moves[i]
                var val: Int = values[i]
                # Quiescent search
                if val < val_lower:
                    break

                # If the new score is less than gamma, the opponent will for sure just
                # stand pat, since ""pos.score + val < gamma === -(pos.score + val) >= 1-gamma""
                # This is known as futility pruning.
                if depth <= 1 and pos.score + val < gamma:
                    # Need special case for MATE, since it would normally be caught
                    # before standing pat.
                    should_stop = check(pos, self.tp_move, best, move, pos.score + val if val < self.MATE_LOWER else self.MATE_UPPER)
                    # We can also break, since we have ordered the moves by value,
                    # so it can't get any better than this.
                    break

                should_stop = check(pos, self.tp_move, best, move, -self.bound(pos.move(move), 1 - gamma, depth - 1))
                if should_stop:
                    break

        # Stalemate checking is a bit tricky: Say we failed low, because
        # we can't (legally) move and so the (real) score is -infty.
        # At the next depth we are allowed to just return r, -infty <= r < gamma,
        # which is normally fine.
        # However, what if gamma = -10 and we don't have any legal moves?
        # Then the score is actually a draw and we should fail high!
        # Thus, if best < gamma and best < 0 we need to double check what we are doing.

        # We will fix this problem another way: We add the requirement to bound, that
        # it always returns MATE_UPPER if the king is capturable. Even if another move
        # was also sufficient to go above gamma. If we see this value we know we are either
        # mate, or stalemate. It then suffices to check whether we're in check.

        # Note that at low depths, this may not actually be true, since maybe we just pruned
        # all the legal moves. So sunfish may report "mate", but then after more search
        # realize it's not a mate after all. That's fair.

        # This is too expensive to test at depth == 0
        if depth > 2 and best == -self.MATE_UPPER:
            flipped = pos.rotate(nullmove=True)
            # Hopefully this is already in the TT because of null-move
            in_check = self.bound(flipped, self.MATE_UPPER, 0) == self.MATE_UPPER
            best = -self.MATE_LOWER if in_check else 0

        # Table part 2
        if best >= gamma:
            var key = get_tp_score_key(pos, depth, can_null)
            self.tp_score.__setitem__(key, (best, entry.get[1, Int]()))
        if best < gamma:
            var key = get_tp_score_key(pos, depth, can_null)
            self.tp_score.__setitem__(key, (entry.get[0, Int](), best))

        return best

    def search(inout self, history: PythonObject, depth: Int) -> DynamicVector[(Int, Int, (Int, Int, Int))]:
        """Iterative deepening MTD-bi search."""
        let py = Python.import_module("builtins")
        self.nodes = 0
        self.history = py.set(history)
        self.tp_score.clear()

        var gamma: Int = 0
        # In finished games, we could potentially go far enough to cause a recursion
        # limit exception. Hence we bound the ply. We also can't start at 0, since
        # that's quiscent search, and we don't always play legal moves there.

        var moves = DynamicVector[(Int, Int, (Int, Int, Int))]()
        # The inner loop is a binary search on the score of the position.
        # Inv: lower <= score <= upper
        # 'while lower != upper' would work, but it's too much effort to spend
        # on what's probably not going to change the move played.
        # lower, upper = -self.MATE_LOWER, self.MATE_LOWER
        var lower: Int = -self.MATE_LOWER
        var upper: Int = self.MATE_LOWER
        let EVAL_ROUGHNESS: Int = 15
        var i: Int = 0
        while lower < upper - EVAL_ROUGHNESS:
            i += 1
            score = self.bound(py_position_to_position(history[py.len(history) - 1]), gamma, depth, can_null=0)
            if score >= gamma:
                lower = score
            if score < gamma:
                upper = score
            let new_pos: Position = py_position_to_position(history[py.len(history) - 1])
            let key = get_tp_move_key(new_pos)
            let move_py: PythonObject = self.tp_move.get(key)
            var move: (Int, Int, Int) = (0, 0, 0)
            if not Python.is_type(move_py, Python.none()):
                move = py_move_to_move(move_py)
                moves.push_back((gamma, score, move))
            gamma = (lower + upper + 1) // 2
        return moves


def parse(c: String) -> Int:
    let A1 = 91
    fil = ord(c[0]) - ord("a")
    rank = ord(c[1]) - ord('0') - 1
    return A1 + fil - 10 * rank

def render(i: Int) -> String:
    let A1 = 91
    let rank = (i - A1) // 10
    let fil = (i - A1) % 10
    var ret = chr(fil + ord("a"))
    ret += (-rank + 1)
    return ret


def main():
    import time
    let py = Python.import_module("builtins")
    initial = (
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
    let e = board_str_to_numbers(initial)
    let init_pos: PythonObject = py.tuple([e.get[0, Int](), e.get[1, Int](), e.get[2, Int](), e.get[3, Int](), e.get[4, Int](), e.get[5, Int](), e.get[6, Int](), e.get[7, Int](), e.get[8, Int](), e.get[9, Int](), e.get[10, Int](), e.get[11, Int](), e.get[12, Int](), e.get[13, Int](), e.get[14, Int](), e.get[15, Int](), e.get[16, Int](), e.get[17, Int](), e.get[18, Int](), e.get[19, Int](), e.get[20, Int](), e.get[21, Int](), e.get[22, Int](), e.get[23, Int](), e.get[24, Int](), e.get[25, Int](), e.get[26, Int](), e.get[27, Int](), e.get[28, Int](), e.get[29, Int](), 0, True, True, True, True, 0, 0])
    var hist: PythonObject = py.list()
    hist.append(init_pos)
    while True:
        try:
            var args = PythonObject()
            args = py.input().split()
            if args[0] == "uci":
                print("id name chess.mojo")
                print("uciok")
            elif args[0] == "isready":
                print("readyok")
            elif args[0] == "quit":
                break
            elif args[0] == "position" and args[1] == "startpos":
                hist = py.list()
                hist.append(init_pos)
                let argc: Int = py.len(args).to_float64().to_int() # TODO: Fix it
                var ply: Int = 0
                for ii in range(3, argc):
                    move = args[ii]
                    let move_0: String = parse(chr(py.ord(move[0]).to_float64().to_int()) + chr(py.ord(move[1]).to_float64().to_int()))
                    let move_1: String = parse(chr(py.ord(move[2]).to_float64().to_int()) + chr(py.ord(move[3]).to_float64().to_int()))
                    var i: Int = parse(move_0)
                    var j: Int = parse(move_1)
                    var prom: Int = 0
                    if py.len(move) > 4:
                        prom = ord(upper(chr(py.ord(move[4]).to_float64().to_int())))
                    if ply % 2 == 1:
                        i = 119 - i
                        j = 119 - j
                        let last_pos: PythonObject = hist[py.len(hist) - 1]
                        hist.append(get_history_key(py_position_to_position(last_pos).move((i, j, prom))))
                    ply += 1
            elif args[0] == "go":
                # var wtime: Int = 2000,btime, winc, binc = [int(a) / 1000 for a in args[2::2]]
                let wtime: Int = 2000
                let btime: Int = 2000
                let winc: Int = 2000
                let binc: Int = 2000
                # TODO: Stop when thinking too long

                # start = time.time()
                var move_str: String = ""
                for depth in range(1, 2):
                    var searcher: Searcher = Searcher()
                    # TODO: Stop when in the middle of the depth
                    let moves: DynamicVector[(Int, Int, (Int, Int, Int))] = searcher.search(hist, depth)
                    for i in range(len(moves)):
                        let gamma: Int = moves[i].get[0, Int]()
                        let score: Int = moves[i].get[1, Int]()
                        let move: (Int, Int, Int) = moves[i].get[2, (Int, Int, Int)]()
                        # The only way we can be sure to have the real move in tp_move,
                        # is if we have just failed high.
                        if score >= gamma:
                            var i = move.get[0, Int]()
                            var j = move.get[1, Int]()
                            if py.len(hist) % 2 == 0:
                                i, j = 119 - i, 119 - j
                            move_str = render(i) + render(j) + lower(chr(move.get[2, Int]()))
                            print("info depth", depth, "score cp", score, "pv", move_str)
                print("bestmove", move_str or '(none)')
        except e:
            print(e)

import time

class Position:
    """A state of a game
    board -- a 120 char representation of the board
    score -- the board evaluation
    wc -- the castling rights, [west/queen side, east/king side]
    bc -- the opponent castling rights, [west/king side, east/queen side]
    ep - the en passant square
    kp - the king passant square
    """

    def __init__(self, board, score, wc, bc, ep, kp):
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

    def gen_moves(self):
        # Lists of possible moves for each piece type.
        N, E, S, W = -10, 1, 10, -1
        p_directions = [0] * 256
        p_directions[ord("P")] = (N, N+N, N+W, N+E)
        p_directions[ord("N")] = (N+N+E, E+N+E, E+S+E, S+S+E, S+S+W, W+S+W, W+N+W, N+N+W)
        p_directions[ord("B")] = (N+E, S+E, S+W, N+W)
        p_directions[ord("R")] = (N, E, S, W)
        p_directions[ord("Q")] = (N, E, S, W, N+E, S+E, S+W, N+W)
        p_directions[ord("K")] = (N, E, S, W, N+E, S+E, S+W, N+W)
        generated_moves = []
        # For each of our pieces, iterate through each possible 'ray' of moves,
        # as defined in the 'directions' map. The rays are broken e.g. by
        # captures or immediately in case of pieces such as knights.
        for i, p in enumerate(self.board):
            if not p.isupper():
                continue
            for d in p_directions[ord(p)]:
                j = i
                while True:
                    j = j + d
                    q = self.board[j]
                    # Stay inside the board, and off friendly pieces
                    if q.isspace() or q.isupper():
                        break
                    # Pawn move, double move and capture
                    if p == "P":
                        if d in (N, N + N) and q != ".": break
                        if d == N + N and (i < self.A1 + N or self.board[i + N] != "."): break
                        if (
                            d in (N + W, N + E)
                            and q == "."
                            and (j != self.ep and j != self.kp and j != self.kp - 1 and j != self.kp + 1)
                        ):
                            break
                        # If we move to the last row, we can be anything
                        if self.A8 <= j <= self.H8:
                            generated_moves.append((i, j, "N"))
                            generated_moves.append((i, j, "B"))
                            generated_moves.append((i, j, "R"))
                            generated_moves.append((i, j, "Q"))
                            break
                    # Move it
                    generated_moves.append((i, j, ""))
                    # Stop crawlers from sliding, and sliding after captures
                    if (p == "P" or p == "N" or p == "K") or q.islower():
                        break
                    # Castling, by sliding the rook next to the king
                    if i == self.A1 and self.board[j + E] == "K" and self.wc[0]:
                        generated_moves.append((j + E, j + W, ""))
                    if i == self.H1 and self.board[j + W] == "K" and self.wc[1]:
                        generated_moves.append((j + W, j + E, ""))
        return generated_moves

    def rotate(self, nullmove=False):
        """Rotates the board, preserving enpassant, unless nullmove"""
        return Position(
            self.board[::-1].swapcase(), -self.score, self.bc, self.wc,
            119 - self.ep if self.ep and not nullmove else 0,
            119 - self.kp if self.kp and not nullmove else 0,
        )

    def move(self, move):
        i, j, prom = move
        p, q = self.board[i], self.board[j]
        put = lambda board, i, p: board[:i] + p + board[i + 1 :]
        # Copy variables and reset ep and kp
        board = self.board
        wc, bc, ep, kp = self.wc, self.bc, 0, 0
        score = self.score + self.value(move)
        # Actual move
        board = put(board, j, board[i])
        board = put(board, i, ".")
        # Castling rights, we move the rook or capture the opponent's
        if i == self.A1: wc = (False, wc[1])
        if i == self.H1: wc = (wc[0], False)
        if j == self.A8: bc = (bc[0], False)
        if j == self.H8: bc = (False, bc[1])
        # Castling
        if p == "K":
            wc = (False, False)
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

    def value(self, move):
        pst = {'P': (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 178, 183, 186, 173, 202, 182, 185, 190, 0, 0, 107, 129, 121, 144, 140, 131, 144, 107, 0, 0, 83, 116, 98, 115, 114, 100, 115, 87, 0, 0, 74, 103, 110, 109, 106, 101, 100, 77, 0, 0, 78, 109, 105, 89, 90, 98, 103, 81, 0, 0, 69, 108, 93, 63, 64, 86, 103, 69, 0, 0, 100, 100, 100, 100, 100, 100, 100, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 'N': (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 214, 227, 205, 205, 270, 225, 222, 210, 0, 0, 277, 274, 380, 244, 284, 342, 276, 266, 0, 0, 290, 347, 281, 354, 353, 307, 342, 278, 0, 0, 304, 304, 325, 317, 313, 321, 305, 297, 0, 0, 279, 285, 311, 301, 302, 315, 282, 280, 0, 0, 262, 290, 293, 302, 298, 295, 291, 266, 0, 0, 257, 265, 282, 280, 282, 280, 257, 260, 0, 0, 206, 257, 254, 256, 261, 245, 258, 211, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 'B': (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 261, 242, 238, 244, 297, 213, 283, 270, 0, 0, 309, 340, 355, 278, 281, 351, 322, 298, 0, 0, 311, 359, 288, 361, 372, 310, 348, 306, 0, 0, 345, 337, 340, 354, 346, 345, 335, 330, 0, 0, 333, 330, 337, 343, 337, 336, 320, 327, 0, 0, 334, 345, 344, 335, 328, 345, 340, 335, 0, 0, 339, 340, 331, 326, 327, 326, 340, 336, 0, 0, 313, 322, 305, 308, 306, 305, 310, 310, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 'R': (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 514, 508, 512, 483, 516, 512, 535, 529, 0, 0, 534, 508, 535, 546, 534, 541, 513, 539, 0, 0, 498, 514, 507, 512, 524, 506, 504, 494, 0, 0, 479, 484, 495, 492, 497, 475, 470, 473, 0, 0, 451, 444, 463, 458, 466, 450, 433, 449, 0, 0, 437, 451, 437, 454, 454, 444, 453, 433, 0, 0, 426, 441, 448, 453, 450, 436, 435, 426, 0, 0, 449, 455, 461, 484, 477, 461, 448, 447, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 'Q': (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 935, 930, 921, 825, 998, 953, 1017, 955, 0, 0, 943, 961, 989, 919, 949, 1005, 986, 953, 0, 0, 927, 972, 961, 989, 1001, 992, 972, 931, 0, 0, 930, 913, 951, 946, 954, 949, 916, 923, 0, 0, 915, 914, 927, 924, 928, 919, 909, 907, 0, 0, 899, 923, 916, 918, 913, 918, 913, 902, 0, 0, 893, 911, 929, 910, 914, 914, 908, 891, 0, 0, 890, 899, 898, 916, 898, 893, 895, 887, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), 'K': (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 60004, 60054, 60047, 59901, 59901, 60060, 60083, 59938, 0, 0, 59968, 60010, 60055, 60056, 60056, 60055, 60010, 60003, 0, 0, 59938, 60012, 59943, 60044, 59933, 60028, 60037, 59969, 0, 0, 59945, 60050, 60011, 59996, 59981, 60013, 60000, 59951, 0, 0, 59945, 59957, 59948, 59972, 59949, 59953, 59992, 59950, 0, 0, 59953, 59958, 59957, 59921, 59936, 59968, 59971, 59968, 0, 0, 59996, 60003, 59986, 59950, 59943, 59982, 60013, 60004, 0, 0, 60017, 60030, 59997, 59986, 60006, 59999, 60040, 60018, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)}
        i, j, prom = move
        p, q = self.board[i], self.board[j]
        # Actual move
        score = pst[p][j] - pst[p][i]
        # Capture
        if q.islower():
            score += pst[q.upper()][119 - j]
        # Castling check detection
        if abs(j - self.kp) < 2:
            score += pst["K"][119 - j]
        # Castling
        if p == "K" and abs(i - j) == 2:
            score += pst["R"][(i + j) // 2]
            score -= pst["R"][self.A1 if j < i else self.H1]
        # Special pawn stuff
        if p == "P":
            if self.A8 <= j <= self.H8:
                score += pst[prom][j] - pst["P"][j]
            if j == self.ep:
                score += pst["P"][119 - (j + self.direction_S)]
        return score


def get_tp_score_key(pos, depth, can_null):
    return (pos.board, pos.score, pos.wc, pos.bc, pos.ep, pos.kp, depth, 1 if can_null else 0)

def get_tp_move_key(pos):
    return (pos.board, pos.score, pos.wc, pos.bc, pos.ep, pos.kp)


# lower <= s(pos) <= upper
class Searcher:
    def __init__(self):
        self.tp_score = {}
        self.tp_move = {}
        self.history = set()
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

    def bound(self, pos, gamma, depth, can_null=True):
        """ Let s* be the "true" score of the sub-tree we are searching.
            The method returns r, where
            if gamma >  s* then s* <= r < gamma  (A better upper bound)
            if gamma <= s* then gamma <= r <= s* (A better lower bound) """
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
        entry = self.tp_score.get(get_tp_score_key(pos, depth, can_null), (-self.MATE_UPPER, self.MATE_UPPER))
        if entry[0] >= gamma: return entry[0]
        if entry[1] < gamma: return entry[1]

        # Let's not repeat positions. We don't chat
        # - at the root (can_null=False) since it is in history, but not a draw.
        # - at depth=0, since it would be expensive and break "futulity pruning".
        if can_null and depth > 0 and pos in self.history:
            return 0

        # Generator of moves to search in order.
        # This allows us to define the moves, but only calculate them if needed.
        # Run through the moves, shortcutting when possible
        best = -self.MATE_UPPER
        def check(move, score):
            nonlocal best
            best = max(best, score)
            if best >= gamma:
                # Save the move for pv construction and killer heuristic
                if move is not None:
                    self.tp_move[get_tp_move_key(pos)] = move
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
        should_stop = False
        if depth > 2 and can_null and abs(pos.score) < 500:
            should_stop = check(None, -self.bound(pos.rotate(nullmove=True), 1 - gamma, depth - 3))

        if not should_stop:
            # For QSearch we have a different kind of null-move, namely we can just stop
            # and not capture anything else.
            if depth == 0:
                should_stop = check(None, pos.score)

        if not should_stop:
            # Look for the strongest ove from last time, the hash-move.
            killer = self.tp_move.get(get_tp_move_key(pos))

            # If there isn't one, try to find one with a more shallow search.
            # This is known as Internal Iterative Deepening (IID). We set
            # can_null=True, since we want to make sure we actually find a move.
            if not killer and depth > 2:
                self.bound(pos, gamma, depth - 3, can_null=False)
                killer = self.tp_move.get(get_tp_move_key(pos))

            # If depth == 0 we only try moves with high intrinsic score (captures and
            # promotions). Otherwise we do all moves. This is called quiescent search.
            QS = 40
            QS_A = 140
            val_lower = QS - depth * QS_A

            # Only play the move if it would be included at the current val-limit,
            # since otherwise we'd get search instability.
            # We will search it again in the main loop below, but the tp will fix
            # things for us.
            if killer and pos.value(killer) >= val_lower:
                should_stop = check(killer, -self.bound(pos.move(killer), 1 - gamma, depth - 1))

        # Then all the other moves
        if not should_stop:
            for val, move in sorted(((pos.value(m), m) for m in pos.gen_moves()), reverse=True):
                # Quiescent search
                if val < val_lower:
                    break

                # If the new score is less than gamma, the opponent will for sure just
                # stand pat, since ""pos.score + val < gamma === -(pos.score + val) >= 1-gamma""
                # This is known as futility pruning.
                if depth <= 1 and pos.score + val < gamma:
                    # Need special case for MATE, since it would normally be caught
                    # before standing pat.
                    should_stop = check(move, pos.score + val if val < self.MATE_LOWER else self.MATE_UPPER)
                    # We can also break, since we have ordered the moves by value,
                    # so it can't get any better than this.
                    break

                should_stop = check(move, -self.bound(pos.move(move), 1 - gamma, depth - 1))
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
            self.tp_score[get_tp_score_key(pos, depth, can_null)] = (best, entry[1])
        if best < gamma:
            self.tp_score[get_tp_score_key(pos, depth, can_null)] = (entry[0], best)

        return best

    def search(self, history, depth):
        """Iterative deepening MTD-bi search"""
        self.nodes = 0
        self.history = set(history)
        self.tp_score.clear()

        gamma = 0
        # In finished games, we could potentially go far enough to cause a recursion
        # limit exception. Hence we bound the ply. We also can't start at 0, since
        # that's quiscent search, and we don't always play legal moves there.

        moves = []
        # The inner loop is a binary search on the score of the position.
        # Inv: lower <= score <= upper
        # 'while lower != upper' would work, but it's too much effort to spend
        # on what's probably not going to change the move played.
        lower, upper = -self.MATE_LOWER, self.MATE_LOWER
        EVAL_ROUGHNESS = 15
        i = 0
        while lower < upper - EVAL_ROUGHNESS:
            i += 1
            score = self.bound(history[-1], gamma, depth, can_null=False)
            if score >= gamma:
                lower = score
            if score < gamma:
                upper = score
            move = self.tp_move.get(get_tp_move_key(history[-1]))
            print(depth, gamma, score, move)
            moves.append((gamma, score, move))
            gamma = (lower + upper + 1) // 2
        return moves


def parse(c):
    A1 = 91
    fil, rank = ord(c[0]) - ord("a"), int(c[1]) - 1
    return A1 + fil - 10 * rank
def render(i):
    A1 = 91
    rank, fil = divmod(i - A1, 10)
    return chr(fil + ord("a")) + str(-rank + 1)
def uci():
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
    hist = [Position(initial, 0, (True, True), (True, True), 0, 0)]
    while True:
        try:
            args = input()
        except:
            print("Could not read input")
            exit(0)
        if not args:
            continue
        args = args.split()
        if args[0] == "uci":
            print("id name chess.mojo")
            print("uciok")
        elif args[0] == "isready":
            print("readyok")
        elif args[0] == "quit":
            break
        elif args[:2] == ["position", "startpos"]:
            hist = [Position(initial, 0, (True, True), (True, True), 0, 0)]
            for ply, move in enumerate(args[3:]):
                i, j, prom = parse(move[:2]), parse(move[2:4]), move[4:].upper()
                if ply % 2 == 1:
                    i, j = 119 - i, 119 - j
                hist.append(hist[-1].move((i, j, prom)))
        elif args[0] == "go":
            wtime, btime, winc, binc = [int(a) / 1000 for a in args[2::2]]
            if len(hist) % 2 == 0:
                wtime, winc = btime, binc
            think = min(wtime / 40 + winc, wtime / 2 - 1)

            start = time.time()
            move_str = None
            for depth in range(1, 1000):
                # TODO: Stop when in the middle of the depth
                moves = Searcher().search(hist, depth)
                for gamma, score, move in moves:
                    # The only way we can be sure to have the real move in tp_move,
                    # is if we have just failed high.
                    print(gamma, score)
                    if score >= gamma:
                        i, j = move[0], move[1]
                        if len(hist) % 2 == 0:
                            i, j = 119 - i, 119 - j
                        move_str = render(i) + render(j) + move[2].lower()
                        print("info depth", depth, "score cp", score, "pv", move_str)
                if move_str and time.time() - start > think * 0.8:
                    break
            print("bestmove", move_str or '(none)')


def main():
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        import subprocess
        from subprocess import PIPE
        engine_proc = subprocess.Popen(["python", "engine.py"], stdout=PIPE, stdin=PIPE, stderr=PIPE, shell=False, text=True)
        ret = engine_proc.communicate(input="uci\nposition startpos\ngo wtime 2000 btime 2000 winc 2000 binc 2000\n")
        if "bestmove" in ret[0]:
            print(">> PASSED ", end="")
            for line in ret[0].split("\n"):
                if "bestmove" in line:
                    print(line.split()[1])
        else:
            print(">> NOT_PASSED")
            print(ret[0])
            print(ret[1])
    else:
        uci()
main()

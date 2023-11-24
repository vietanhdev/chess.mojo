# Chess.Mojo 🔥

This is an effort to develop a new chess engine with Mojo Language. **WORK IN PROGRESS.**

![Chess.Mojo](./chess.mojo.png)

## Note

- The current engine is not optimized for speed. It is just a proof of concept.
- The source code was based on [sunfish](https://github.com/thomasahle/sunfish/).
- TODO: Optimize the engine for speed; Add NNUE support; Lichess support; etc.

## Usage

- Install Mojo.
- Run `mojo engine.mojo` to start the engine.


## Run with simple UI:

- Install Python >= 3.8.
- Install `python-chess` package.

```bash
pip install python-chess
```

- Run:

```bash
chmod +x ./engine.mojo
python play -cmd ./engine.mojo
```

## References

- [sunfish](https://github.com/thomasahle/sunfish/).

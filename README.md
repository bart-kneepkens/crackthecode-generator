<p align="center">
<img src="https://bart-kneepkens.github.io/gridlock-crack-the-code/assets/appicon.png" width="200" height="200" />
</p>

# Crack The Code - Generator
Crack The Code - Generator is a basic macOS commandline utility to generate puzzles for [Gridlock: Crack The Code](https://bart-kneepkens.github.io/gridlock-crack-the-code/).

If you're interested in the algorithm, check out [PuzzleSolver.swift](CrackTheCode-Generator/CrackTheCode-Generator/PuzzleSolver.swift) and [Generator.swift](CrackTheCode-Generator/CrackTheCode-Generator/Generator.swift)


# Usage
    ./CrackTheCode-Generator [difficulty] [amount]
Where `difficulty` is either `easy`, `medium`, `hard`, or `wizard`, and where `amount` is a positive number.


# Limitations
- `easy` puzzles are played with possible values 1, 2, and 3. This significantly reduces the amount of unique combinations to 26 (because 333 would be considered too easily solvable, see [Equation.swift](CrackTheCode-Generator/CrackTheCode-Generator/Equation.swift)).
- The current algorithm is rather naive; after generating a random sequence, it only tries one set of random equations. This can make the script slow when generating a lot of puzzles for higher difficulties. Still, generating about 700/800 puzzles (as done for Gridlock: Crack The Code) doesn't take unreasonably long.

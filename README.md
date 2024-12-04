### Introduction
This program simulates a turing machine. It consists of:
- A tape divided into cells, one next to the other. Each cell contains a symbol from some finite alphabet. The alphabet contains a special blank symbol and one or more other symbols.
- A head that can read and write symbols on the tape and move the tape left and right one (and only one) cell at a time.
- A state register that stores the state of the Turing machine, one of finitely many. Among these is the special start state with which the state register is initialised.
- A finite table of instructions that, given the state(qi) the machine is currently in and the symbol(aj) it is reading on the tape (the symbol currently under the head), tells the machine to do the following in sequence (for the 5-tuple models):
    Either erase or write a symbol (replacing aj with aj1).
    Move the head (which is described by dk and can have values: 'L' for one step left or 'R' for one step right or 'N' for staying in the same place).
    Assume the same or a new state as prescribed (go to state qi1).

### Install and run:
```sh
$ opam switch create . # create a new environment isolated from the global one and install all required dependencies
$ make # build the program
$ ./ft_turing machines/unary_sub.json "111-1=" # execute ft_turing with a json machine and the input it must process
```

### Usage:
```sh
# ft_turing [-verbose] <json> <input>
#  -verbose Output debug information
#  -help  Display this list of options
#  --help  Display this list of options
#  <json> is the program (in turing machine form). It must be a valid json file with correct format.
#  <input> is the tape. It must be an input accepted by the turing machine definition given by the json file.
# example:
$ ./ft_turing machines/unary_sub.json "111-1="
```

### Machine description (turing machine program):
I won't put the formal description of the json format but an example is worth a thousand words:
https://github.com/Jibus22/ft_turing/blob/c3fc24ba53559ef08bcf84bee81f6b56cd3bf23b/machines/ispair.json#L1-L18

This formating sticks with the formal description of a turing machine which can be formally defined as a 7-tuple M = ⟨ Q , Γ , b , Σ , δ , q 0 , F ⟩ where

- Γ is a finite, non-empty set of tape alphabet symbols;
- b ∈ Γ is the blank symbol (the only symbol allowed to occur on the tape infinitely often at any step during the computation);
- Σ ⊆ Γ ∖ { b } is the set of input symbols, that is, the set of symbols allowed to appear in the initial tape contents;
- Q is a finite, non-empty set of states;
- q 0 ∈ Q is the initial state;
- F ⊆ Q is the set of final states or accepting states. The initial tape contents is said to be accepted by M if it eventually halts in a state from F.
- δ : ( Q ∖ F ) × Γ ↛ Q × Γ × { L , R } is a partial function called the transition function, where L is left shift, R is right shift. If δ is not defined on the current state and the current tape symbol, then the machine halts;intuitively, the transition function specifies the next state transited from the current state, which symbol to overwrite the current symbol pointed by the head, and the next head movement.

### Implementation:

I'd say that the biggest part of this project were to tokenize and sanitize data (after learning a bit of TOC and designing the program). Because the run loop in itself isn't that complicated to implement as it just consists of reading the transition table then writing and moving the head.
The most important part was a good understanding and a good design. I started from the principle that it was necessary to take advantage of the Ocaml type system to clearly define the Turing machine. It gived this result:
https://github.com/Jibus22/ft_turing/blob/c3fc24ba53559ef08bcf84bee81f6b56cd3bf23b/src/parsing.mli#L1-L13
*One detail to note is the implementation of the tape. This could have been a simple list that changes depending on whether the head goes right or left, but I designed it like a zipper. So the left and right lists are only modified by their heads by pulling or pushing values, which is a kind of optimization.*

### UTM:

The project asked us to create some turing machine program, mostly basic for the first 4. And surprise, the 5th is basically creating kind of an UTM, for the add unary operation. The splits hurt. Anyway, after wondering if I was giving up (programming a turing machine can be fun, for 6 min max), I ended up doing it with the priority in mind to format the input at its simplest to facilitate the editing of the machine description.
We can run the machine by typing this:
```
./ft_turing machines/utmlike.json -verbose "|a@,1a 1>,+a 1>,=b .<,}b{,1c .<,.c .<,}c{,\!,}:1 + 1 ="
```

The definition is there:
https://github.com/Jibus22/ft_turing/blob/c3fc24ba53559ef08bcf84bee81f6b56cd3bf23b/machines/utmlike.json#L1-L8

**Input formating:**
| symbol | desc |
| --- | --- |
| {   | open a transition-by-state block |
| }   | close a transition-by-state block |
| @   | current state marker and separator (replace `{` char) |
| ,   | transitions separator inside a transition block |
| %   | current transition marker and separator (replace `,` char) |
| !   | halt state marker |
| :   | input marker: marks the input character being processed |
| &lt;space&gt; | separates transition description in 2 parts. separate each alphabet input |
| >   | `Right` symbol |
| <   | `Left` symbol |

### Order of operations:
```
1. read the input
2. find and mark the associated transition (current state + input read)
3. update the current state according to what is specified in the transition
4. write to the tape as specified in the transition
5. change the position of the input playback cursor as specified in the transition
6. go to 1
```

### Algorithm according to the logic of the Turing machine
```
// read the input  
1 - I go to `-` then go right  
2 - I read `1` so I trigger a series of transitions linked to `1`, there I go to state 3  
// read the transition  
3s - goes to `@` then ends right  
4s - should read `,` and go right  
5s - should read `1` and go left otherwise (`+`, `=`, `.`) it goes to state `4`  
// mark the transition  
6 - should read `,` and replace it with `%` and go left  
7 - should read `@` and replace with `{` and go right.  
8 - should read `%` and go right  
9 - should read `a|b|c` and go left  
// write the new future current state  
10s - is specific (a|b|c) and must go all the way to the left read the `.` and go to the right  
11s - should read `a` for example and go right  
12 - replaces `{` with `@` and goes right  
// read the char to write  
13 - will look for `%` to the right and go to the right  
14 - will read `1|=|.|+` and call a specific state  
// write the char  
15s - will grab `:` and go right  
16s - writes `1|=|.|+` instead of `1|=|.|+` and goes left XXXX  
// read playback cursor movement  
17 - will grab `%` to the left and replace it with `,` and go right  
18 - fetches `<|>` on the right and calls a specific state, goes right  
// clear current play marker  
20s - will grab `:` and write and depending on its specificity goes left or right  
// write the current reading marker  
21 - goes left or right to write `:` then goes right  
//loop
```

*Note: steps with a `s` postfix marks a transition which depends of a character, meaning that this transition must be duplicated as many times as there are characters involved*

---

<img width="354" alt="turing_unary_sub" src="https://github.com/user-attachments/assets/38376557-a721-49e6-a44d-13cecd7aa395">

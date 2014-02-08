# Brainjar.org - Battleships 

![alt text](./resources/brainjar_org_logo_200.png "Logo Brainjar.org")

This is the game engine for the Battleships coding challenge at [https://brainjar.org/battleships](https://brainjar.org/battleships)


## Rules of the game


**The goal is to destroy the enemy's fleet.**



The game is played by two players. 

Each player has a fleet of 4 ships of different sizes (2, 3, 4, 5) on a grid 8 x 8 (columns 0-7, rows 0-7).



Players play in turns: in each turn they choose a cell to atack.

Players can't see each other's fleet - they only know what is on the cells they have shot at.


### Initial setting

At the beginning, each player is choosing their setting - they have to place 4 ships on the grid.
Ships have to be at least one cell away from each other.

Player A:

        0   1   2   3   4   5   6   7
    0
    1           X   X   X   X
    2   X
    3   X                   X
    4                       X
    5       X   X   X       X
    6                       X
    7                       X

Player B:

        0   1   2   3   4   5   6   7
    0           X   X   X   X   X
    1
    2   X
    3   X
    4   X
    5       X   X   X   X
    6                       X
    7                       X


** Moves are stored as a couple (column, row), i.e. (3,1) is the beginning of size 4 ship of player A**

### Turns

In each turn player has to choose one location to shoot at. 
If the opponnent doesn't have a ship at this location, the field is marked as "missed", and the turn ends.
If the opponnent has a ship at this location, the field is marked as "hit", and the turn continues - player chooses another location.

#### Pseudocode

    game = new game()

    game.setup(0, new Player().config)
    game.setup(1, new Player().config)

    player = game.randomPlayer()

    while (!game.over()){

        turn = player.play(game.snapshot)
        if (game.isValid(turn)){
            game.apply(turn)
        } else{
            game.lost(player)
        }
        player = game.nextPlayer()
    }

    winner = game.winner()

#### Grid snapshots

Before each move, player get the current situation - the opponent's grid's snapshot with marked fields.

A snapshot is represented by a JSON:

    {
        "hit" : ["20", "30"],       // the cells shot at and hit
        "missed" : ["44", "01"],    // the cells shot at but missed
        "destroyed": [2]            // sizes (2, 3, 4, 5) of destroyed opponent's ships
    }

#### Move format

A move is represented by a JSON:

    {
        "row"    : 2,
        "column" : 1         
        // any invalid output or shooting twice at the same cell will be taken as a surrender
    }

#### Initial config format

Initial config has to follow this JSON format:

    {
        "2" :
            {
                "point": "00",
                "orientation" : "vertical"   // possible values "horizontal", "vertical"
            },
        "3" :
            {
                "point": "22",
                "orientation" : "vertical"
            },
        "4" :
            {
                "point": "42",
                "orientation" : "vertical"
            },
        "5" :
            {
                "point": "37",
                "orientation" : "horizontal"
            },

    }

This initial config will represent


        0   1   2   3   4   5   6   7
    0   X
    1   X
    2           X       X
    3           X       X
    4           X       X
    5                   X           
    6
    7               X   X   X   X   X



#### Valid turn

In a turn, player has to chose a valid location on the opponents side. Otherwise they lose.


## Ranking - Scores

When the game starts, each player has a score (initial score = 10, minimal score = 10).

**Winner gets 5% of points of the looser.**

**Looser loses 5% of their points.**


## Getting started

To come.


## Status

Draft. Nothing is done yet.


## LICENCE

The MIT License (MIT)

Copyright (c) 2014 Mikolaj Pawlikowski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

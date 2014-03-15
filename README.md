# Brainjar.org - Battleships 

![alt text](https://raw.github.com/BrainJar/battleships/master/resources/brainjar_org_logo_200.png "Logo Brainjar.org")

This is the game engine for the Battleships coding challenge at [https://brainjar.org/battleships](https://brainjar.org/battleships)

## Bots

This repos provides basic info about the game. If you want to see an example of a working bot to get you started, check this out: https://github.com/BrainJar/battleships-bot


You will need a working local environment - check out https://github.com/BrainJar/battleships-bot#4-test-it-locally-before-the-fight

Remember that you lose each fight your bot crashes in !


## Rules of the game


**The goal is to destroy the enemy's fleet.**



The game is played by two players. 

Each player has a fleet of 4 ships of different sizes (2, 3, 4, 5) on a grid 8 x 8 (columns 0-7, rows 0-7).



Players play in turns: in each turn they choose a cell to atack.

Players can't see each other's fleet - they only know what is on the cells they have shot at.


### Initial setting

At the beginning, each player is choosing their setting - they have to place 4 ships on the grid.

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


** Moves are stored as a couple (column, row), i.e. (2,1) is the beginning of size 4 ship of player A**

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
            if (game.missed){
                player = game.nextPlayer()
            }
        } else{
            game.lost(player)
        }
    }

    return game.winner


## Playing the game


### Stateless, baby

All bots have to be stateless. That's why for each move, you'll get complete game information.


### Standard input and output

All communication is via command line argument and stdout, via JSON. 

We'll provide you with a valid json string as an argument, and we'll expect a valid JSON string as the only thing printed to the screen.

As a consequence, any errors will be considered a suicide.



### Beginning of the game

#### Request for the init config

The bot will receive a following JSON object.

    {
        "cmd": "init"
    }

#### Initial config format

Initial config response has to follow this JSON format:

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
            }
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


### Moves

#### Grid snapshots

Before each move, player get the current situation - the opponent's grid's snapshot with marked fields.

A snapshot is represented by a JSON:

    {
        "cmd": "move",              // for less user-friendly languages

        // an array representing the sequence of moves and results (see below)
        "moves": ["0001", "1003", "1113", ...],

        // for your convenience, we also suply the following data
        "hit"       : ["20", "30"],  // the cells shot at and hit
        "missed"    : ["44", "01"],  // the cells shot at but missed
        "destroyed" : [2],           // sizes (2, 3, 4, 5) of destroyed opponent's ships
        "you"       : 0              // player 0 or 1
    }

In the array representing the sequence, (player, move, results) are encoded.

    player = 0|1 // player number 0 or 1
    move   = XY  // see below
    result = 1|3 // 1 means missed, 3 means hit

For example an array:

    ["0001", "1003", "1113", "1331", "0123", "0133"]

Represents:
 - player 0 shoots 00 and misses
 - player 1 shoots 00 and hits
 - player 1 shoots 11 and hits
 - player 1 shoots 33 and misses
 - player 0 shoots 12 and hits
 - player 0 shoots 13 and hits


#### Move format

A move (as returned by the bot) is represented by a string (column, row).

A following JSON has to be returned for a bot to play a move.

    {
        "move" : "00"
        // any invalid output or shooting twice at the same cell will be taken as a surrender
    }



#### Valid turn

In a turn, player has to chose a valid location on the opponents side. Otherwise they lose.


## Ranking - Scores

When the game starts, each player has a score (initial score = 10, minimal score = 10).

**Winner gets 5% of points of the looser.**

**Looser loses 5% of their points.**


## Getting started - tester.coffee

There is a little tester program, which lets you verify that the things is going ok.

    git clone git@github.com:BrainJar/battleships.git
    cd battleships
    npm install
    # if you don't have coffeescript installed
    npm install -g coffee-script
    coffee tester.coffee

What you get is a loop, asking for a valid move and showing all useful data.

    =====================
     Player 1 moves

    prompt: move:  02
    Snapshot: "{\"hit\":[\"00\",\"01\"],\"missed\":[\"02\"],\"destroyed\":[\"2\"],\"moves\":[\"1003\",\"1013\",\"1021\"]}"
    (8,8), destroyed: 2
    #                 
    #                 
    *   H   H         
        H   H         
        H   H         
            H         
                      
          H H H H H   
                      
    {"hit":["00","01"],"missed":["02"],"destroyed":["2"]}
    (8,8), destroyed: 
    H                 
    H                 
        H   H         
        H   H         
        H   H         
            H         
                      
          H H H H H   
                      
    {"hit":[],"missed":[],"destroyed":[]}


## Status

Beta. Most of the things are hacked together in few evening. Contributions welcome !


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

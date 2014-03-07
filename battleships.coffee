###
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
###



###
    Class Grid

    Holds internal information about the matrix in use by a user.
    Provides utility methods to standard actions.

###

class Grid

    # store the actual matrix
    # 0 - empty
    # 1 - missed
    # 2 - ship
    # 3 - hit
    storage: null

    # the list of numbers of destroyed ships
    destroyed: null

    # the list of ships left
    ships: null

    # initialize with the size of the grid
    # width, height in <1,9>
    constructor: (@width, @height) ->
        @_reset()
        @destroyed = []
        @ships = []

    # initialize the storage
    _reset: ->
        @storage = []
        for i in [0..@height]
            @storage[i] = []
            for j in [0..@width]
                @storage[i][j] = 0

    _parseMove: (move) ->
            col: parseInt(move.charAt(0)) or 0
            row: parseInt(move.charAt(1)) or 0

    # check if the move is legal
    #   - if it hasn't been done already
    isLegal: (move) ->
        mv = @_parseMove move

        # the field is either empty or a ship
        if (@storage[mv.col][mv.row] is 2) or (@storage[mv.col][mv.row] is 0)
            return true

        return false

    # returns:
    #   - true if hit
    #   - false if missed
    shoot: (move) ->
        mv = @_parseMove move

        toRemove = []

        if @storage[mv.col][mv.row] is 2 # ship
            @storage[mv.col][mv.row] = 3

            # check if we should store that the ship was destroyed
            for ship in @ships

                # check the points remaining in this ship
                for point in ship.points

                    if point is move    

                        #console.log "Removing position #{move} from ship #{ship.type}"

                        # remove from the array of points
                        ship.points.splice(ship.points.indexOf(point),1)

                # if we're going to destroy it
                if ship.points.length is 0

                    console.log "Destroyed ship: #{ship.type}"

                    toRemove.push ship
                    @destroyed.push ship.type

            for ship in toRemove
                @ships.splice(@ships.indexOf(ship),1)

            #console.log "Shoot - ships: #{JSON.stringify(@ships)}" 

            return true

        if @storage[mv.col][mv.row] is 0 # empty
            @storage[mv.col][mv.row] = 1

        return false

    cell: (move) ->
        mv = @_parseMove move
        @storage[mv.col][mv.row]

    lost: ->
        for i in [0..@height]
            for j in [0..@width]
                if @storage[i][j] is 2
                    return false

        # no ships left
        return true

    # initializes the storage 
    # with the provided configuration
    #   returns:
    #       - true if the configuration is valid
    #       - false otherwise
    setup: (config) ->

        ships = @ships

        # store a single ship on the grid
        storeShip = (num) =>

            ship       = config[""+num]
            
            col        = parseInt(ship.point.charAt(0)) or 0
            row        = parseInt(ship.point.charAt(1)) or 0
            horizontal = if ship.orientation is "horizontal" then 1 else 0
            vertical   = if ship.orientation is "vertical" then 1 else 0

            points = []

            for i in [1..num]
                if (@storage[col][row] isnt 0) or col >= @width or row >= @height
                    return false
                else
                    points.push "" + col + row

                    @storage[col][row] = 2
                    row += vertical
                    col += horizontal

            ships.push
                type: ""+num
                points: points

            return true

        # apply for all ships
        for num in [2, 3, 4, 5]
            if not storeShip(num)
                return false

        #console.log "Setup - ships: #{JSON.stringify(@ships)}" 

        return true

    # return an overview of the grid
    summary: ->

        hit = []
        missed = []

        for i in [0..@height]
            for j in [0..@width]
                if @storage[i][j] is 1 # missed
                    missed.push "" + i + j

                else if @storage[i][j] is 3 # hit
                    hit.push "" + i + j

        data = 
            "hit"       : hit
            "missed"    : missed
            "destroyed" : @destroyed

    _print: ->
        # 0 - empty
        # 1 - missed
        # 2 - ship
        # 3 - hit
        console.log "(#{@height},#{@width}), destroyed: #{@destroyed}"
        for i in [0..@height]
            line = ""
            for j in [0..@width]
                switch @storage[j][i]
                    when 0 then car = " "
                    when 1 then car = "*"
                    when 2 then car = "H"
                    when 3 then car = "#"
                line += car + " "
            console.log line
        console.log "#{JSON.stringify(@summary())}"

###
    Class Battleships

    Representation of the game.
    Holds the state of the game, users, lets find out when the game is finished etc.
    Also, generates the representation used to visualise the games.

###

class Battleships

    # game finished due to illegal move
    illegalMove: false

    # current player
    currentPlayer : Math.round(Math.random())
    won : 0

    _changePlayer: ->
        @currentPlayer = (@currentPlayer + 1) % 2

    # returns the next player to make a move
    player: ->
        @currentPlayer

    opponent: ->
        (@currentPlayer + 1) % 2

    # grids storing the config of users grids
    grids : [
        new Grid(8, 8)
        new Grid(8, 8)
    ]

    # moves:
    #   <player><move><effect><destroyed>,
    #       - player    (1)     = 0|1
    #       - move      (2)     = xy, where x,y in <0,9>
    #       - effect    (1)     = 1|3 (missed|hit)
    #   ex. 1773
    moves : []

    # initialize the grid with provided config
    setup: (configA, configB) ->
        if not @grids[0].setup configA
            @won = 1
            return false
        if not @grids[1].setup configB
            @won = 0
            return false
        #console.log JSON.stringify @grids
        return true


    # get JSON representation of the current player's situation
    snapshot: ->
        data = @grids[@player()].summary()
        data.moves = @moves
        data.cmd = "move"
        JSON.stringify data

    # get the string to send to the bot
    getBotCommand: ->
        init = JSON.stringify
            cmd: init
        player = "#{@player()}"
        for move in @moves
            if player is move.charAt(0)
                return @snapshot()
        return init


    # check if the game is over
    over: ->
        if @illegalMove
            return true

        for i in [0..1]
            if @grids[i].lost()
                @won = (i + 1) % 2
                return true

        return false

    # make a move for the current player
    # returns:
    #   - true if a valid move
    #   - false otherwise
    play: (mv) ->

        move = mv.move

        # check if the move is valid
        if not @grids[@opponent()].isLegal move

            console.log "illegal move: #{move}"

            @illegalMove = true     # set illegal move flag for "over" method
            @won = @opponent()  # set the winner to the other user
            return false

        # apply the move on the thing
        didHitTarget = @grids[@opponent()].shoot(move)

        # correct move, let's store it in the right format
        store = "" + @player() + move + @grids[@opponent()].cell(move)

        @moves.push store

        # change player if necessary
        if not didHitTarget
            @_changePlayer()

        return true

    # returns the winner, if over returned true
    winner: ->
        @won

    # string representation for the frontend to interpret
    toString: ->
        out = ""
        for move in @moves
            out += ":" + move
        out



    ### 
        DEBUG
    ###
    debugPrint: ->
        console.log "Snapshot: #{JSON.stringify(@snapshot())}"
        for i in [0..1]
            @grids[i]._print()


###
    EXPORT
    
    In this module we only expose Battleships class
###

module.exports = Battleships

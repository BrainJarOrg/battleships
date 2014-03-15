###
    The MIT License (MIT)

    Copyright (c) 2014 Mikolaj Pawlikowski
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
    storage: []

    # the list of numbers of destroyed ships
    destroyed: []

    # the list of ships left
    ships: []

    # initialize with the size of the grid
    constructor: (@width, @height) ->
        # initialize the storage
        @storage = []
        for i in [0..@height]
            @storage[i] = []
            for j in [0..@width]
                @storage[i][j] = 0

        @destroyed = []
        @ships = []

    # initializes the storage with the provided configuration
    #   returns:
    #       - null, if the configuration is valid
    #       - error otherwise
    setup: (config) ->

        for num in [2, 3, 4, 5]
            try
                ship       = config["#{num}"]
                
                col        = parseInt(ship.point.charAt(0)) or 0
                row        = parseInt(ship.point.charAt(1)) or 0
                horizontal = if ship.orientation is "horizontal" then 1 else 0
                vertical   = if ship.orientation is "vertical" then 1 else 0

                points = []
                for i in [1..num]
                    if (@storage[col][row] isnt 0)  or  (col >= @width or col <0)  or  (row >= @height or row < 0)
                        return error: "The following configuration is violating game rules: #{JSON.stringify(config)}"
                    else
                        points.push "#{col}#{row}"

                        @storage[col][row] = 2

                        row += vertical
                        col += horizontal

                @ships.push
                    type: "#{num}"
                    points: points

            catch error
                
                return error: "The following configuration is not a valid json string: #{JSON.stringify(config)} (#{error.toString()})"

        return

    # parse the move object to string
    _parseMove: (move) ->
            col: parseInt(move.charAt(0))
            row: parseInt(move.charAt(1))

    # check if the move is legal
    isLegal: (move) ->

        try
            mv = @_parseMove move

            if (mv.col < 0) or (mv.col >= @width)
                return error: "The following configuration is not a valid move: #{JSON.stringify(mv)}"
            if (mv.row < 0) or (mv.row >= @height)
                return error: "The following configuration is not a valid move: #{JSON.stringify(mv)}"

            # the field is either empty or a ship
            if (@storage[mv.col][mv.row] is 2) or (@storage[mv.col][mv.row] is 0)
                return
            else
                return error: "Illegal movement - cell already occupied: #{JSON.stringify(mv)}"

        catch error
            return error: "Could not parse the following move: #{JSON.stringify(move)}"

    # returns:
    #   - 4 - hit and sunk
    #   - 3 - hit
    #   - 1 - missed
    #   
    #   /!\ first verify if the string is a valid move
    #   
    shoot: (move) ->

        mv = @_parseMove move
        code = 1

        if @storage[mv.col][mv.row] is 2 # ship

            # mark as hit
            @storage[mv.col][mv.row] = 3
            code = 3

            # check if we should store that the ship was 
            for ship in @ships

                # check the points remaining in this ship
                for point in ship.points

                    if point is move
                        ship.points.splice(ship.points.indexOf(point),1)
                        break

                # the ship is destroyed now
                if ship.points.length is 0

                    console.log "Destroyed ship: #{ship.type}"

                    @ships.splice(@ships.indexOf(ship),1)
                    @destroyed.push ship.type
                    break

                    code = 4

        else if @storage[mv.col][mv.row] is 0 # empty
            @storage[mv.col][mv.row] = 1

        return code

    lost: ->
        for i in [0..@height]
            for j in [0..@width]
                if @storage[i][j] is 2
                    return false

        # no ships left
        return true

    # return an overview of the grid
    summary: ->

        hit = []
        missed = []

        for i in [0..@height]
            for j in [0..@width]
                if @storage[i][j] is 1 # missed
                    missed.push "#{i}#{j}"

                else if @storage[i][j] is 3 # hit
                    hit.push "#{i}#{j}"

        data = 
            "hit"       : hit
            "missed"    : missed
            "destroyed" : @destroyed

    _print: ->
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
        #console.log "size (#{@height},#{@width}), #{JSON.stringify(@summary())}"




###
    Class Battleships

    Representation of the game.
    Holds the state of the game, users, lets find out when the game is finished etc.

###
class Battleships

    # current player
    currentPlayer : Math.round(Math.random())

    # grids storing the config of users grids
    grids : []
    configs :[]

    #   <player><move><effect>,
    #       - player    (1)     = 0|1
    #       - move      (2)     = xy, where x,y in <0,9>
    #       - effect    (1)     = 1|3|4 (missed|hit|hit&destroyed)
    moves : []

    _changePlayer: ->
        @currentPlayer = (@currentPlayer + 1) % 2

    # returns the next player to make a move
    player: ->
        @currentPlayer

    opponent: ->
        (@currentPlayer + 1) % 2


    # initialize the grid with provided config
    setup: (configA, configB) ->

        # reset
        @grids         = [new Grid(8, 8), new Grid(8, 8)]
        @configs       = []
        @currentPlayer = Math.round(Math.random())
        @moves         = []

        # setup
        err = @grids[0].setup configA
        if err
            return {
                error: "The following configuration of the player was rejected"
                data : err.error
            }

        err = @grids[1].setup configB
        if err
            @_changePlayer()
            return {
                error: "The following configuration of the opponent was rejected"
                data : err.error
            }

        @configs.push configA
        @configs.push configB
        
        return

    # make a move for the current player
    # returns:
    #   - true if a valid move
    #   - false otherwise
    play: (mv) ->

        move = mv.move

        # check if the move is valid
        err = @grids[@opponent()].isLegal move
        if err
            return {
                error: "The following move of the opponent was rejected"
                data : err.error
            }

        # apply the move on the thing
        code = @grids[@opponent()].shoot(move)

        # correct move, let's store it in the right format
        @moves.push "#{@player()}#{move}#{code}"


        # if game finished or missed
        if @grids[@opponent()].destroyed.length is 4 or code is 1
            @_changePlayer()

        return

    # get JSON representation of the current player's situation
    snapshot: ->
        data = @grids[@opponent()].summary()
        data.moves = @moves
        data.cmd = "move"
        data.you = @player()
        data

    # get the string to send to the bot
    getBotCommand: ->
        if @configs.length isnt 2
            JSON.stringify
                cmd: 'init'
        else
            JSON.stringify @snapshot()

    # check if the game is over
    over: ->
        return @grids[@player()].lost() or @grids[@opponent()].lost()

    # returns the winner, if over returned true
    winner: ->
        @opponent()

    # exports all necessary data
    export: (elapsed) ->
        data =
            'winner'  : @winner()
            'moves'   : @moves
            'elapsed' : elapsed
            'config'  : @configs
    ### 
        DEBUG
    ###
    _print: ->
        for i in [0..1]
            @grids[i]._print()

module.exports = Battleships

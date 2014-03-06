prompt      = require "prompt"
Battleships = require "./battleships"

game = new Battleships()

config = 
    "2" :
            "point": "00"
            "orientation" : "vertical"
    "3" :
            "point": "22"
            "orientation" : "vertical"
    "4" :
            "point": "42"
            "orientation" : "vertical"
    "5" :
            "point": "37"
            "orientation" : "horizontal"

if not game.setup(config, config)
    console.log "Invalid config"
    console.log "player", game.winner(), "wins"
    process.exit 1

prompt.start()

loopy = ->

    game.debugPrint()

    console.log "\n=====================\n Player", game.player(), "moves\n"

    prompt.get ['move'], (err, result) ->
        if err
            console.log err
            return

        game.play 
            move: result.move

        if not game.over()
            loopy()
        else
            console.log "player", game.winner(), "wins"

loopy()



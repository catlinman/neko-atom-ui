
module.exports =

    config:
        color:
            description: "Set the main color used throughout the theme"
            type: "color"
            default: "#f3aa15"

        hexColor:
            description: "Set the main color color by hex value (Use #rrggbb)"
            type: "string"
            default: "#f3aa15"

        overlayColor:
            description: "Set the contrasting color to your custom color"
            type: "string"
            default: "Black"
            enum: [
                "Black"
                "White"
            ]

        fontSize:
            description: "Set the global font size for this theme."
            type: "integer"
            default: 12
            minimum: 8
            maximum: 24

        useSyntax:
            description: "Override the gutter, background, and selection colours"
            type: "boolean"
            default: "true"

    activate: (state) ->
        # more reliable rgb to hex conversion
        # .toHexString function sometimes returns shorthand
        rgbToHex = (r, g, b) ->
            "#" + ((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)

        # converts hex to rgb
        hexToRgb = (hex) ->
            result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex)
            if result
                r: parseInt(result[1], 16),
                g: parseInt(result[2], 16),
                b: parseInt(result[3], 16),
            else
                null

        # returns true if matches hex pattern
        checkHex = (hex) ->
            reg = /^#([\da-fA-F]{2})([\da-fA-F]{2})([\da-fA-F]{2})$/
            str = hex
            true if str.match reg

        # string color, writes hex colour to file
        setColor = () ->
            fs = require "fs"
            path = require "path"

            writePath = path.join __dirname, "..", "styles/include-color.less"

            color = atom.config.get("neko-atom-ui.color")
            overlay = if atom.config.get("neko-atom-ui.overlayColor") == "Black" then "#000000" else "#ffffff"

            fs.writeFileSync writePath, "@theme-color: #{rgbToHex(color.red, color.green, color.blue)};\n@theme-overlay: #{overlay};\n"

        # int size, writes global fontsize to file
        setFontsize = () ->
            fs = require "fs"
            path = require "path"

            writePath = path.join __dirname, "..", "styles/include-fontsize.less"

            size = atom.config.get("neko-atom-ui.fontSize")

            fs.writeFileSync writePath, "@font-size: #{size}px;\n"

        # bool trigger, specifies whether or not to override syntax
        setSyntax = () ->
            fs = require "fs"
            path = require "path"

            writePath = path.join __dirname, "..", "styles/include-syntax.less"

            trigger = atom.config.get("neko-atom-ui.useSyntax")

            content = if trigger then "@import 'ui-syntax';\n" else "\n"
            fs.writeFileSync writePath, content

        # runs functions to generate files with LESS variables
        setColor()
        setFontsize()
        setSyntax()

        # basic atom configuration handling
        atom.config.onDidChange "neko-atom-ui.color", ->
            color = atom.config.get("neko-atom-ui.color")
            setColor()

            atom.config.set("neko-atom-ui.hexColor", rgbToHex(color.red, color.green, color.blue))

        atom.config.onDidChange "neko-atom-ui.hexColor", ->
            hex = atom.config.get("neko-atom-ui.hexColor")
            isHex = checkHex(hex)
            rgb = hexToRgb(hex)
            color = atom.config.get("neko-atom-ui.color")

            if isHex
                color.red = rgb.r
                color.green = rgb.g
                color.blue = rgb.b
                atom.config.set("neko-atom-ui.color", color)

        atom.config.onDidChange "neko-atom-ui.fontSize", ->
            setFontsize()

        atom.config.onDidChange "neko-atom-ui.useSyntax", ->
            setSyntax()

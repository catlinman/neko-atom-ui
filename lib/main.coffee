
module.exports =
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

        # Update a config color value with its hex equivalent.
        updateHex = (hexConfig, colorConfig) ->
            color = atom.config.get(colorConfig)
            atom.config.set(hexConfig, rgbToHex(color.red, color.green, color.blue))

        # Update a config color value with its hex equivalent.
        updateColor = (colorConfig, hexConfig) ->
            hex = atom.config.get(hexConfig)
            isHex = checkHex(hex)
            rgb = hexToRgb(hex)
            color = atom.config.get(colorConfig)

            if isHex
                color.red = rgb.r
                color.green = rgb.g
                color.blue = rgb.b
                atom.config.set(colorConfig, color)

                # Update the file's colors if validated.
                setColors()

        # Save requirements to variables.
        fs = require "fs"
        path = require "path"

        # Variable storing our base include file path.
        includePath = path.join __dirname, ".."

        # Write all our colors to a single include file.
        setColors = () ->
            colorTheme = atom.config.get("neko-atom-ui.colorTheme")
            colorBackground = atom.config.get("neko-atom-ui.colorBackground")

            overlay = if atom.config.get("neko-atom-ui.overlayColor") == "Black" then "#000000" else "#ffffff"

            # Main content string to write to the file.
            content = "
                @theme-color: #{rgbToHex(colorTheme.red, colorTheme.green, colorTheme.blue)};\n
                @theme-background: #{rgbToHex(colorBackground.red, colorBackground.green, colorBackground.blue)};\n
                @theme-overlay: #{overlay};\n
            "

            fs.writeFileSync path.join(includePath, "styles/include-color.less"), content

        # Writes our font size to the corresponding include file.
        setFontsize = () ->
            # Get the font size integer value from the input field.
            size = atom.config.get("neko-atom-ui.fontSize")

            # Content to write to our include file.
            content = "@font-size: #{size}px;\n"

            fs.writeFileSync path.join(includePath, "styles/include-fontsize.less"), content

        # Writes our syntax settings to the include file.
        setSyntax = () ->
            # Get the checkbox state from the config variable.
            trigger = atom.config.get("neko-atom-ui.useSyntax")

            # Content to write to our include file.
            content = if trigger then "@import 'ui-syntax';\n" else "\n"

            fs.writeFileSync path.join(includePath, "styles/include-syntax.less"), content

        # Run our basic functions to make sure files exist and are validated.
        setColors()
        setFontsize()
        setSyntax()

        # Start handling colors and their hex counterparts. Begin with the theme color.
        atom.config.onDidChange "neko-atom-ui.colorTheme", ->
            updateHex("neko-atom-ui.colorThemeHex", "neko-atom-ui.colorTheme")

        atom.config.onDidChange "neko-atom-ui.colorThemeHex", ->
            updateColor("neko-atom-ui.colorTheme", "neko-atom-ui.colorThemeHex")

        # Background color.
        atom.config.onDidChange "neko-atom-ui.colorBackground", ->
            updateHex("neko-atom-ui.colorBackgroundHex", "neko-atom-ui.colorBackground")

        atom.config.onDidChange "neko-atom-ui.colorBackgroundHex", ->
            updateColor("neko-atom-ui.colorBackground", "neko-atom-ui.colorBackgroundHex")

        # Update the font size.
        atom.config.onDidChange "neko-atom-ui.fontSize", ->
            setFontsize()

        # Update the syntax styling options.
        atom.config.onDidChange "neko-atom-ui.useSyntax", ->
            setSyntax()

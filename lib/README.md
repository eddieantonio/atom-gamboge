# Atom Gamboge Design

**Note**: Tools must be diligent in calling `::dispose()` when
subscribing to events!

# `./prediction-list`

Model. Manages the list of predictions for the current tokens.

# `./ghost-text-view`

View. Manipulates the TextEdtitorView DOM to display predictions inline
in the editor.

# `./prediction-view`

View. Optionally overlays prediction information.

# `./editor-spy`

Controller. Listens and reacts to `TextEditor` events.

# `./token-tools`

Tokenization utilities.

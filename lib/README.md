# Atom Gamboge Design

[![Class Diagram][uml-svg]][uml-edit]

**Note**: Tools must be diligent in calling `::dispose()` when
subscribing to events!

# `./gamboge`

Sets up any global state, and watches when `TextEditor`
instances are created and destroyed. Binds an `EditorSpy` and its
associated components when a `TextEditor` is created, and cleans up when
an editor is destroyed.

# `./editor-spy`

*Controller*. Listens and reacts to `TextEditor` events. Changes
`PredictionList`.

# `./prediction-provider`

An asynchronous provider of predictions. Predictions can be requested
with new context. They are received by subscribing with
`onPredictionsReady`. These predictions can then be sent to
`PredictionList::setPredictions`.

# `./prediction-list`

*Model*. Manages the list of predictions for the current buffer position.

# `./hacky-ghost-text-view`

*View*. Manipulates the text editor DOM to display predictions inline
in the editor.

# `./status-view`

*View*. *Not Implemented.* Overlays information about the current predictions.

# `./text-formatter`

Utilities for determining how to format whitespace between tokens, both
in inserted text, and in ghost-text previews.

[uml-edit]: http://yuml.me/edit/05de04c0
[uml-svg]: http://yuml.me/52c9fe9d.svg

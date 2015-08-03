less = require 'less'
LessBuildView = require './less-build-view'
{CompositeDisposable} = require 'atom'

module.exports = LessBuild =
  lessBuildView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @lessBuildView = new LessBuildView(state.lessBuildViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @lessBuildView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace', 'less-build:build': => @build()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @lessBuildView.destroy()

  serialize: ->
    lessBuildViewState: @lessBuildView.serialize()

  build: ->
    console.log less

    editor = atom.workspace.getActiveTextEditor()
    text = editor.getText()
    console.log(text)
    @modalPanel.show()

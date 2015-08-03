fs = require("fs")
less = require("less")
path = require("path")
{CompositeDisposable} = require 'atom'

module.exports = LessBuild =
  lastActiveDisposable: null
  subscriptions: null
  options: {}

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'less-build:build': => @build()

    @onActivePanelChanged()
    atom.workspace.onDidChangeActivePaneItem (activePaneItem) =>
      @lastActiveDisposable.dispose()
      @onActivePanelChanged()

  deactivate: ->
    @subscriptions.dispose()

  onActivePanelChanged: ->
    @lastActiveDisposable = atom.workspace.getActiveTextEditor().onDidSave () =>
      @build()

  build: ->
    editor = atom.workspace.getActiveTextEditor()
    fileExtension = editor.getTitle().split(".")[1]
    if fileExtension is 'less'
      @buildLESS(editor)

  buildLESS: (editor) ->
    less.render editor.getText(), @options, (error, output) =>
      if error isnt null
          return @reportError(error, editor)

      css = output.css
      notifications = atom.notifications
      fs.writeFile "/Users/aramaswamy/1.css", css, {}, (error) ->
        if error isnt null
          notifications.addError('Unable to write to output file')
        else
          notifications.addSuccess('less-build: success')

  reportError: (error, editor) ->
      name = error.filename
      if name == 'input'
        name = editor.getTitle()

      errorMessage = "#{name} [#{error.line}, #{error.column}]: #{error.message}"
      atom.notifications.addError errorMessage, {}

fs = require("fs")
less = require("less")
path = require("path")
{CompositeDisposable} = require 'atom'

module.exports = LessBuild =
  lastActiveDisposable: null
  subscriptions: null

  activate: (state) ->
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-workspace', 'less-build:build': => @build()

    @onActivePanelChanged()
    atom.workspace.onDidChangeActivePaneItem (activePaneItem) =>
      @lastActiveDisposable.dispose() if lastActiveDisposable?
      @onActivePanelChanged()

  deactivate: ->
    @subscriptions.dispose()

  onActivePanelChanged: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    @lastActiveDisposable = editor.onDidSave () =>
      @build()

  build: ->
    editor = atom.workspace.getActiveTextEditor()
    fileExtension = editor.getTitle().split(".")[1]
    if fileExtension is 'less'
      @buildLESS()

  buildLESS: () ->
    buildOptions = atom.config.get('less-build')
    return unless buildOptions?

    for src, dest of buildOptions
      @renderLESS(src, dest)

  renderLESS: (src, dest) ->
    text = fs.readFileSync src, {encoding: 'utf8'}
    lessOptions =
      paths: [path.dirname path.resolve(src)]
      filename: path.basename src

    less.render text, lessOptions, (error, output) =>
      if error isnt null
        return @reportError(error)

      css = output.css
      fs.writeFile dest, css, {}, (error) ->
        if error isnt null
          atom.notifications.addError('Unable to write to output file')
        else
          atom.notifications.addSuccess('less-build: success')

  reportError: (error) ->
    errorMessage = "#{error.filename} [#{error.line}, #{error.column}]: #{error.message}"
    atom.notifications.addError errorMessage, {}

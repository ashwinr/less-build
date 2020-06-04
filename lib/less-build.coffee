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
    @lastActiveDisposable.dispose() if lastActiveDisposable?
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
    projectName = atom.config.get('less-build.project')
    projectPath = atom.project.getPaths()[0]
    unless projectPath?
      projectPath = ""

    return if projectPath.slice(-projectName.length) isnt projectName

    buildOptions = atom.config.get('less-build.options')
    return unless buildOptions?

    for src, dests of buildOptions
      if Array.isArray(dests)
        for dest in dests
          srcPath = path.resolve(projectPath, src)
          destPath = path.resolve(projectPath, dest)
          @renderLESS(srcPath, destPath)
      else
        srcPath = path.resolve(projectPath, src)
        destPath = path.resolve(projectPath, dests)
        @renderLESS(srcPath, destPath)

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

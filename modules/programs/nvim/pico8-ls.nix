# pico8-ls is not published to npm; the nixpkgs VSCode extension ships a
# self-contained esbuild bundle of the server, so run that with node.
{ nodejs, vscode-extensions, writeShellScriptBin }:

writeShellScriptBin "pico8-ls" ''
  exec ${nodejs}/bin/node \
    ${vscode-extensions.pollywoggames.pico8-ls}/share/vscode/extensions/PollywogGames.pico8-ls/server/out-min/main.js \
    "$@"
''

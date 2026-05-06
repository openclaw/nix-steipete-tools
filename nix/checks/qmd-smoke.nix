{
  runCommand,
  qmd,
}:

runCommand "qmd-smoke" { nativeBuildInputs = [ qmd ]; } ''
  set -eu

  export HOME="$TMPDIR/home"
  export XDG_CONFIG_HOME="$TMPDIR/config"
  export XDG_CACHE_HOME="$TMPDIR/cache"
  export XDG_DATA_HOME="$TMPDIR/data"
  mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$TMPDIR/notes"

  printf '%s\n\n%s\n' '# Smoke' 'qmd packaging smoke' > "$TMPDIR/notes/smoke.md"

  qmd --help >/dev/null
  qmd collection list >/dev/null
  qmd collection add "$TMPDIR/notes" --name smoke
  qmd update
  qmd search packaging --json | grep -q packaging
  qmd status >/dev/null

  touch "$out"
''

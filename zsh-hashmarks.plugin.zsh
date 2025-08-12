# Entrypoint for the plugin
# Adds functions to fpath, sets defaults, and initializes in interactive shells.

# Ensure functions/ is in $fpath
local _plugin_dir=${0:A:h}
if [[ -d ${_plugin_dir}/functions ]] && [[ -z ${fpath[(r)${_plugin_dir}/functions]} ]]; then
  fpath+=("${_plugin_dir}/functions")
fi

# Default location for bookmark store; allow user override before loading
: ${BOOKMARK_FILE:="$HOME/.zsh_hashed_dirs"}

# Disable AUTO_NAME_DIRS early to prevent auto population from env exports
unsetopt AUTO_NAME_DIRS 2>/dev/null

# Autoload functions
autoload -Uz hashmarks_common init_hashmarks b ba br _b _ba _br 2>/dev/null

# Only initialize in interactive shells
if [[ -o interactive ]]; then
  # Clean all named dirs and then load only plugin-managed bookmarks
  hash -d -r 2>/dev/null
  init_bookmarks
  # Completions
  compdef _b b
  compdef _ba ba
  compdef _br br

  # Optional: watch for external changes and reload automatically
  # Track mtime to avoid excessive reloads
  typeset -g _ZB_MTIME=""
  function _zb_precmd_reload() {
    local mtime
    if [[ -f "$BOOKMARK_FILE" ]]; then
      mtime=$(stat -f %m "$BOOKMARK_FILE" 2>/dev/null || stat -c %Y "$BOOKMARK_FILE" 2>/dev/null)
    else
      mtime="MISSING"
    fi
    if [[ "$mtime" != "$_ZB_MTIME" ]]; then
      _ZB_MTIME="$mtime"
      init_bookmarks
    fi
  }
  autoload -U add-zsh-hook 2>/dev/null
  if whence -w add-zsh-hook >/dev/null 2>&1; then
    add-zsh-hook precmd _zb_precmd_reload
  fi
fi
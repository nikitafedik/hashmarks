# Entrypoint for the plugin
# Adds functions to fpath, sets defaults, and initializes in interactive shells.

# Ensure functions/ is in $fpath (works when sourced)
_plugin_file=${${(%):-%N}}
_plugin_dir=${_plugin_file:A:h}
if [[ -d ${_plugin_dir}/functions ]] && [[ -z ${fpath[(r)${_plugin_dir}/functions]} ]]; then
  fpath+=("${_plugin_dir}/functions")
fi

unsetopt AUTO_NAME_DIRS 2>/dev/null

autoload -Uz hashmarks_common init_hashmarks b ba br _b _ba _br 2>/dev/null

# Load helpers immediately so ba/br can call _zb_* funcs even in non-interactive scripts
hashmarks_common 2>/dev/null || true

# Always load named directories from the bookmarks file once at source-time
hash -d -r 2>/dev/null
init_hashmarks

if [[ -o interactive ]]; then

  if whence -w compdef >/dev/null 2>&1; then
    compdef _b b
    compdef _ba ba
    compdef _br br
  fi

  typeset -g _ZB_MTIME=""
  typeset -g _ZB_FILE_PATH=""
  _zb_precmd_reload() {
    local mtime file
    file=$(_zb_file)
    if [[ "$file" != "$_ZB_FILE_PATH" ]]; then
      _ZB_FILE_PATH="$file"
      mtime=""
    fi
    if [[ -f "$file" ]]; then
      mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
    else
      mtime="MISSING"
    fi
    if [[ "$mtime" != "$_ZB_MTIME" ]]; then
      _ZB_MTIME="$mtime"
      init_hashmarks
        # Ensure ~named-dir completion works if compsys is active
        autoload -Uz _tilde 2>/dev/null
        # Associate words starting with ~ to _tilde unless already defined
        if ! compdef | grep -q "~\\\*" 2>/dev/null; then
          compdef -P '~*' _tilde 2>/dev/null || true
        fi
    fi
  }
  autoload -U add-zsh-hook 2>/dev/null
  if whence -w add-zsh-hook >/dev/null 2>&1; then
    add-zsh-hook precmd _zb_precmd_reload
  fi
fi
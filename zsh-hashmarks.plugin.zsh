# Entrypoint for the plugin
# Adds functions to fpath, sets defaults, and initializes in interactive shells.

# Ensure functions/ is in $fpath (robust across plugin managers)
typeset -ga _hm_search_dirs
_hm_search_dirs=()
[[ -n ${0} ]] && _hm_search_dirs+=(${0:A:h})
local _hm_pf=${${(%):-%N}}
[[ -n ${_hm_pf} && ${_hm_pf} != "-" ]] && _hm_search_dirs+=(${_hm_pf:A:h})

local _hm_base=""
for d in ${_hm_search_dirs[@]}; do
  if [[ -r $d/functions/hashmarks_common ]]; then
    _hm_base=$d
    break
  fi
done
[[ -z $_hm_base ]] && _hm_base=${_hm_search_dirs[1]:-${PWD}}

if [[ -d ${_hm_base}/functions ]] && [[ -z ${fpath[(r)${_hm_base}/functions]} ]]; then
  fpath+=("${_hm_base}/functions")
fi

unsetopt AUTO_NAME_DIRS 2>/dev/null

autoload -Uz hashmarks_common init_hashmarks b ba br _b _ba _br 2>/dev/null || true

# Load helpers and init immediately so ba/br and named dirs work at once
(( $+functions[hashmarks_common] )) || autoload -Uz hashmarks_common 2>/dev/null || true
hashmarks_common 2>/dev/null || true
(( $+functions[init_hashmarks] )) || autoload -Uz init_hashmarks 2>/dev/null || true

# Always load named directories from the bookmarks file once at source-time (no clearing)
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
    # Re-apply named dirs on every prompt; cheap and robust against clears
    init_hashmarks
    # Ensure ~named-dir completion works if compsys is active
    autoload -Uz _tilde 2>/dev/null || true
    if whence -w compdef >/dev/null 2>&1 && typeset -p _comps >/dev/null 2>&1; then
      # Only define once per session
      if [[ -z ${_ZB_TILDE_DEFINED-} ]]; then
        compdef -P '~*' _tilde >/dev/null 2>&1 || true
        typeset -g _ZB_TILDE_DEFINED=1
      fi
      # Ensure command completions for b/ba/br are defined once compsys is active
      if [[ -z ${_ZB_CMD_COMPLETIONS-} ]]; then
        compdef _b b 2>/dev/null || true
        compdef _ba ba 2>/dev/null || true
        compdef _br br 2>/dev/null || true
        typeset -g _ZB_CMD_COMPLETIONS=1
      fi
    fi
  }
  autoload -U add-zsh-hook 2>/dev/null || true
  if whence -w add-zsh-hook >/dev/null 2>&1; then
    add-zsh-hook precmd _zb_precmd_reload
  else
    # Fallback: register via precmd_functions array
    typeset -ga precmd_functions
    if (( ${precmd_functions[(I)_zb_precmd_reload]} == 0 )); then
      precmd_functions+=_zb_precmd_reload
    fi
  fi
fi
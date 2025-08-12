# Zimfw module entrypoint for hashmarks
# Ensure this module is sourced by Zim and delegates to the plugin loader.

# Resolve this module directory and source the plugin loader next to it.
local _mod_file=${${(%):-%N}}
local _mod_dir=${_mod_file:A:h}
if [[ -r ${_mod_dir}/zsh-hashmarks.plugin.zsh ]]; then
  source ${_mod_dir}/zsh-hashmarks.plugin.zsh
fi

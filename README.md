# hashmarks — Zsh bookmarks via named directories

hashmarks lets you use Zsh “named directories” as lightweight, shell-native bookmarks:

- Add a bookmark: `ba proj .`
- Jump to it: `cd ~proj` or `~proj` 
- List all: `b`
- Remove: `br proj`

The whole idea of this small plugin is to leverage native Zsh’s `hash -d` under the hood.

> [!NOTE]  
> This is an early stage side project initially written for personal use. It is provided as‑is, without any warranty or liability.    
> Before using, make sure to back up your current hashed directories (hash -d) to avoid losing existing bookmarks.    
> Your feedback and suggestions are welcome! Feel free to open an issue/pull request/message me to help improve the plugin.    


---

## Features

- Native bookmarks using Zsh named directories
- Works with plugin managers (Zimfw [tested], others - [todo])
- Auto-hash on startup from a single text file (default: `~/.zsh_hashed_dirs`)
- Immediate updates on add/remove (no restart needed)
- **~<hasmark name>** expands to full path: use to `cd`, `cp`, `mv` files without memorizing or tabbing complex paths 

---

## Installation

Pick your setup.

### Zimfw (recommended)
Add to your `~/.zimrc`:
```zsh
zmodule nikitafedik/hashmarks
```
Then:
```zsh
zimfw install && zimfw update
```
[ℹ️ More pluging managers will be tested and documented soon ]

> [!IMPORTANT]
> Before using, make sure that you *save your current hashed dirs* somewhere as they can get lost
> modify completion styles in your .zshrc: 
> `unsetopt AUTO_NAME_DIRS`
> `zstyle ':completion:*' users`
> `zstyle ':completion:*:named-directories' format '%d -> %p'`
>  zstyle ':completion:*:hashed-directories' format '%d -> %p'`  

---

## Usage

- Add a bookmark for the current directory:
  ```zsh
  ba <name> 
  ```
- Add a bookmark pointing to a specific path:
  ```zsh
  ba <name> </usr/path>
  ba zenodo-upload ~/usr/work/zenodo   # dashes are fine
  ```
- Jump and manipulate files using named-dir expansion:
  ```zsh
  ~proj 
  cd ~proj
  ls ~data
  mv file.txt ~proj 
  ```
  > [!TIP]
  > `~<TAB>` shows your keys (named dirs), and `cd ~<key><TAB>` completes them.

- List all bookmarks:
  ```zsh
  b
  ```
- Remove a bookmark:
  ```zsh
  br <name>
  ```

All changes take effect immediately: `~key` expands as soon as you add it, and stops expanding once you remove it. No need to restart shell or plugin.

---

## Bookmark file

- Default file: `~/.zsh_hashed_dirs`
- You can change it by setting `BOOKMARK_FILE` (ideally before your manager sources plugins):
  ```zsh
  export BOOKMARK_FILE="$HOME/.config/hashmarks"
  ```
- File format (one per line):
  ```
  key=/absolute/path
  other-key=~/path/with/tilde
  ```
  A leading `~` is expanded to `$HOME`. **Always** provide absolute paths. 

---

## Key rules

- Allowed characters: `A–Z a–z 0–9 _ -`
- Example valid keys: `work`, `scratch_01`, `zenodo-upload`
- Invalid keys (rejected): contain spaces, slashes, or other punctuation

---


## Troubleshooting

- Completion doesn’t show keys
  - Ensure `compinit` has run (frameworks usually handle this).
- Bookmarks don’t appear at startup
  - Make sure your plugin manager is loading `hashmarks` (see Installation).
  - If another plugin or line in `.zshrc` clears named dirs during init (something like `hash -d -r`), try disabling them. 

---

## Examples

```zsh
ba proj .              # bookmark current dir as "proj"
ba pkgs /opt/pkgs      # bookmark an absolute path
b                      # list: proj=/… and pkgs=/opt/pkgs
cd ~proj               # jump
ls ~pkgs               # use anywhere a path is accepted
br proj                # remove
```



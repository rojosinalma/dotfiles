My dotfiles
---

These are my dotfiles, there's many like them but these are mine.

### Requirements:

* [Chezmoi](https://github.com/twpayne/chezmoi) 2.1.3
* Files

## Usage:

```
    git clone https://github.com/rojosinalma/dotfiles
    cd dotfiles
    chezmoi init
    ln -s $(pwd)/dot_config/chezmoi/chezmoi.toml $HOME/.config/chezmoi/chezmoi.toml
    chezmoi -v apply
```

**NOTES:**
* Chezmoi doesn't allow to store its own config, so we need to copy that first.
* You can change the `sourceDir` inside the `chezmoi.toml` file to wherever you want.



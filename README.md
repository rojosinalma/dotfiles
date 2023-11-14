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
    ln -s $(pwd)/dot_config/chezmoi/chezmoi.yml $HOME/.config/chezmoi/chezmoi.yml
    chezmoi -v apply
```

**NOTE:** Change the `sourceDir` inside the `chezmoi.yml` file to where you cloned this.


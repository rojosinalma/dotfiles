My dotfiles
---

These are my dotfiles, there's many like them but these are mine.

### Requirements:

* [Chezmoi](https://github.com/twpayne/chezmoi) 2.1.3
* Files

## Usage:

1. Clone this repository wherever you want.
    ```
        git clone https://github.com/rojosinalma/dotfiles
        cd dotfiles
        ln -s dot_config/chezmoi/chezmoi.yml $HOME/.config/chezmoi/chezmoi.yml
    ```

2. Change the `sourceDir` inside the `chezmoi.yml` file to where you cloned this.
3. `chezmoi -v apply`
4. Celebrate :tada:

## Notes:

Chezmoi doesn't really need you to change the `sourceDir` of its config, but since I think it's pretty cool to be able to place the dotfiles dir wherever you want, I decided to do it.



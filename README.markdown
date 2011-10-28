# Jon Phenow's dotfiles

## dotfiles

Your dotfiles are how you personalize your system. These are mine. The 
Linux, bash, Ruby, Rails, git, rvm, vim, etc., etc.. If you
match up along most of those lines, you may dig my dotfiles.

If you're interested in the philosophy behind why projects like these are
awesome, you might want to [read Zach Holman's post on the
subject](http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/).

## install

- `git clone git://github.com/jphenow/dotfiles ~/git/dotfiles #2nd directory your choice`
- `cd ~/.dotfiles`
- FIX:
  * zshrc $ZSH var and
  * bashrc {$DOT,$ZSH}
    * These variables will depend on where you cloned to
    * Will be a wiki on article soon
- `rake install`

The install rake task will symlink the appropriate files in `.dotfiles` to your
home directory. Everything is configured and tweaked within `~/.dotfiles`,
though.

The main file you'll want to change right off the bat is `zsh/zshrc.symlink`
or `bash/bashrc.symlink1 depending on your shell,
which sets up a few paths that'll be different on your particular machine.

## topical

Everything's built around topic areas. If you're adding a new area to your
forked dotfiles — say, "Java" — you can simply add a `java` directory and put
files in there. Anything with an extension of `.zsh` will get automatically
included into your shell. Anything with an extension of `.symlink` will get
symlinked without extension into `$HOME` when you run `rake install`.

## what's inside

A lot of stuff. Seriously, a lot of stuff. Check them out in the file browser
above and see what components may mesh up with you. Fork it, remove what you
don't use, and build on what you do use.

## components

There's a few special files in the hierarchy.

- **bin/**: Anything in `bin/` will get added to your `$PATH` and be made
  available everywhere.
- **topic/\*.zsh**: Any files ending in `.zsh` get loaded into your
  ZSH environment.
- **topic/\*.bash**: Any files ending in `.bash` get loaded into your
  bash environment.
- **topic/\*.symlink**: Any files ending in `*.symlink` get symlinked into
  your `$HOME`. This is so you can keep all of those versioned in your dotfiles
  but still keep those autoloaded files in your home directory. These get
  symlinked in when you run `rake install`.
- **topic/\*.completion.sh**: Any files ending in `completion.sh` get loaded
  last so that they get loaded after we set up zsh autocomplete functions.

## add-ons

There are a few things I use to make my life awesome. They're not a required
dependency, but if you install them they'll make your life a bit more like a
bubble bath.

- If you want some more colors for things like `ls`, install grc: `brew install
  grc`.
- If you install the excellent [rvm](http://rvm.beginrescueend.com) to manage
  multiple rubies, your current branch will show up in the prompt. Bonus.

## bugs

I want this to work for everyone; that means when you clone it down it should
work for you even though you may not have `rvm` installed, for example. That
said, I do use this as *my* dotfiles, so there's a good chance I may break
something if I forget to make a check for a dependency.

If you're brand-new to the project and run into any blockers, please
[open an issue](https://github.com/jphenow/dotfiles/issues) on this repository
and I'd love to get it fixed for you!

## thanks

I forked [Zach Holman](http://github.com/holman)'s excellent
[dotfiles](http://github.com/ryanb/dotfiles) just a recently. Its certainly
a work in progress as I clean up his OSX tools, insert some of my bash tools
and organize my own dotfile management, but it already feels better. I
encourage you to continually look around, update, and contribute.

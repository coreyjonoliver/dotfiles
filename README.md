dotfiles
========
My personal dotfiles. The layout is modeled for use with GNU Stow. Special thanks to Brandon Invergo, whose [blog][1] was where I originally happened upon the idea of using my dotfiles in conjunction with Stow.

Usage
-----

Begin by installing GNU Stow.

For a stow package `<package>`, that is a directory in the root of the git repository, the following
command can be executed:

	stow --target $HOME <package>

This will install the contents of `<package>` into your home directory.

To delete a stow package execute the following:

	stow --delete <package>

[1]: http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html

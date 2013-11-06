dotfiles
========
My personal dotfiles. The layout is modeled for use with GNU Stow. Special thanks to Brandon Invergo's, whose [blog][1] was where I originally happened upon the idea of using my dotfiles in conjunction with Stow.

Usage
-----

Begin by installing GNU Stow.

For a directory `<dir>` in the root of the git repository, the following
command can be executed:

	stow <dir>

This will install the contents of `<dir>` into your home directory.

[1]: http://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html

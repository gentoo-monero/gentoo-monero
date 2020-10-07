# Contributing to the Gentoo Monero Overlay

## What

Anything related to Monero and its ecosystem is welcome in the
overlay, including forks of Monero.

## How

Please try to follow [GLEP 66][]
(see the [Gentoo git workflow wiki article][wiki] for more info).
In short:

* Commits should be atomic, i.e. they should contain one logical
  change.
* Commits should be signed with GPG.
* Commits should contain a valid `Signed-off-by` line.
* Commit messages should start with a package atom and then a
  semi-colon.
* Ebuilds should not upset repoman.
* Pull requests should not contain merge commits.

[GLEP 66]: https://www.gentoo.org/glep/glep-0066.html 'GLEP 66'
[wiki]: https://wiki.gentoo.org/wiki/Gentoo_git_workflow 'Gentoo git workflow'

rlatex
======

rlatex is a ruby script for LaTeX scaffolding. It creates the directory and document hierarchy, keeping everything nice 
and tidy. Save time and efforts in creating LaTeX documents, use a good standard for every project.

v 1.0
======
Hooray! v 1.0 is out! Here below you can find its basic (and so far also complete) usage:

    $ ruby rlatex.rb new --author "Edoardo Colombo" --title "My ruby latex manager" --sections my_fist_section foo

The above command will produce the following:

1. a file called `main.tex` with:
    *   author set to Edoardo Colombo
    *   title set to My ruby latex manager
2. a folder named `contents` with inside a file named `my_first_section.tex`

Other options are:

*    `--language`, set to english as default
*    `--date`, set to \today as defaul

The --sections options allow multiple values, but it cannot preceed the project name.

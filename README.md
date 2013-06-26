# rlatex

rlatex is a ruby script for LaTeX scaffolding. It creates the directory and document hierarchy, keeping everything nice 
and tidy. Save time and efforts in creating LaTeX documents, use a good standard for every project.

# Usage

## New Project

Use the `new` command to start a new project,

### Basic Usage

    $ ruby rlatex.rb new --author "Edoardo Colombo" --sections my_fist_section --title "My ruby latex manager" foo

The above command will produce the following:

1. a file called `main.tex` with:
    *   author set to Edoardo Colombo
    *   title set to My ruby latex manager
2. a folder named `contents` with inside a file named `my_first_section.tex`


### Subsectioning

    $ ruby rlatex.rb new foo --sections mysection/subsection_one,subsection_two myothersection

The above command creates:

1. A section called `mysection`, which contains:
    *   a subsection called `subsection_one`
    *   a subsection called `subsection_two`
2. A section called `myothersection`

### Add a Section

    `$ ruby rlatex.rb add-section <new-section> --before <section>


### Other options


*    `--language`, set to english as default
*    `--date`, set to \today as default
*    `--packages` allows you to add extra packages.
*    `--template` allows you to use a template to set up the project. Use the `templates` command to show the available templates.

The --sections option allows multiple values, but it cannot preceed the project name.

## Add Package


To add a package after the project was created:
    

    $ ruby rlatex.rb add-package <package>


## Compile


The `compile` command to compile using `pdflatex`, if installed:

    $ ruby rlatex.rb compile

all of the output files are stored in the `output` folder, keeping the main directory clean.

# v 1.3
Added the `--template` option, which allows to use a specific template to set up the document. Templates are simple .json files

# v 1.2
Added the `--packages` option, which allows you to add extra packages. Added the `add-package` command.

# v 1.1
Kudos to [spinatelli](https://github.com/spinatelli "spinatelli") for the pull request. Even though I didn't merge
the branch (didn't like the excessive nesting), the syntax to add subsections was quite lovely. Here we go: 

# v 1.0
Hooray! v 1.0 is out! Here below you can find its basic (and so far also complete) usage:

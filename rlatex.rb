gem 'trollop'
gem 'facets'

require 'fileutils'
require 'tempfile'
require 'trollop'
require 'facets/string/titlecase'

VERSION = "1.2"
SUB_COMMANDS = %w{new add-package add-section compile}
TEMP_FILE = "temp"
PACKAGES_END_MARKER = "%%% packages (end)"
SECTIONS_END_MARKER = "%%% sections (end)"
HELP = <<-EOS
This is rlatex #{VERSION}, a ruby command line utility for LaTeX projects scaffolding.

usage: ruby rlatex.rb <command> [options]
where <command> can be:

  new <project> [options]: creates the project scaffolding.
  It accepts the following options:
      --class <class>, to specify the document class. Default is set to article.
      --sections <sections>, to specify the sections and subsections.
      --author <author>, to specify the author.
      --title <title>, to specify the document title.
      --date <date>, to specify the date, default set to \\today
      --font-size <size>, format allowed: <SIZE>pt, e.g. 11pt
      --packages <packages>, to add extra packages
EOS

class LatexCreator
  def new_project(name, author, title, date, font_size, language, dclass, sections, packages)
    if not File.exists? name
      @name = name
      @author = author
      @title = title
      @date = date
      @language = language
      @font_size = font_size
      @class = dclass
      @sections = sections
      @packages = packages

      FileUtils.mkdir name
      FileUtils.mkdir "#{name}/contents"
      FileUtils.mkdir "#{name}/pictures"
      FileUtils.mkdir "#{name}/output"

      create_main_tex
      create_sections "#{name}/contents/"
    else
      puts "Directory #{name} already exists. Please provide another name."
    end
  end

  def create_main_tex()
    File.open("#{@name}/main.tex", 'w') do |f|
      f.puts "\\documentclass[#{@font_size}]{#{@class}}"
      f.puts

      f.puts "%%% PACKAGES"
      write_packages(f)
      f.puts

      f.puts "%%% META"
      write_meta(f)
      f.puts

      f.puts "%%% HYPERREF OPTIONS"
      write_hypersetup(f)
      f.puts

      f.puts "\\begin{document}"
      f.puts
      f.puts "\\maketitle"
      f.puts "  %%% INPUT"
      write_sections @sections, f unless @sections.nil?

      f.puts("\\end{document}")
    end
  end

  def create_sections(path)
    @sections.each { |section| create_section section, path } unless @sections.nil?
  end

  def create_section(section, path)
    section_name = parse_section_name(section.split("/")[0])
    subsections = section.split("/")[1].split(",") unless section.split("/")[1].nil?

    File.open("#{path}#{section_name}.tex", 'w') do |f|
      f.puts "\\section{#{parse_heading(section_name)}}"
      f.puts "\\label{sec:#{section_name}}"
      f.puts
      subsections.each { |subsection| create_subsection subsection, f } unless subsections.nil?
      f.puts
      f.puts "% section #{section_name} (end)"
    end
  end

  def add_section(section, position)
    create_section section, "contents/"
    section_line = "\\input{contents/#{position[:section]}.tex}"
    if position[:place] == :before
      add_line_before section_line, "  \\input{contents/#{section}.tex}", "main.tex"
    end
  end

  def write_sections(sections, file)
    sections.each do |section|
      section_name = parse_section_name(section.split("/")[0])
      file.puts "  \\input{contents/#{section_name}.tex}"
    end
    file.puts SECTIONS_END_MARKER
  end

  def create_subsection(subsection, file)
    file.puts "\\subsection{#{parse_heading(subsection)}}"
    file.puts "\\label{subsec:#{subsection}}"
    file.puts
    file.puts "% subsection #{subsection} (end)"
  end

  def write_meta(file)
    file.puts "\\author{#{@author}}"
    file.puts "\\title{#{@title}}"
    file.puts "\\date{#{@date}}"
  end

  def write_hypersetup(file)
    file.puts "\\makeatletter"
    file.puts "\\hypersetup{"
    file.puts "    colorlinks, linkcolor=black, urlcolor=black,"
    file.puts "    pdftitle={\\@title},"
    file.puts "    pdfauthor={\\@author},"
    file.puts "}\n\\makeatother"
  end

  def write_packages(file)
    file.puts "\\usepackage[#{@language}]{babel}"
    file.puts "\\usepackage{amsmath}"
    file.puts "\\usepackage{amssymb}"
    file.puts "\\usepackage{graphicx}"
    file.puts "\\graphicspath{ {pictures/} }"
    file.puts "\\usepackage{booktabs}"
    file.puts "\\usepackage{tikz}"
    file.puts "\\usepackage{hyperref}"
    @packages.each { |pkg| file.puts "\\usepackage{#{pkg}}"} unless @packages.nil?
    file.puts PACKAGES_END_MARKER
  end

  def add_package(package)
    add_line_before PACKAGES_END_MARKER, "\\usepackage{#{package}}", "main.tex"
  end

  def compile(file = "main.tex")
    if pdflatex_is_found?
      system("pdflatex --output-directory=output #{file}")
    else
      puts "pdflatex not found."
    end
  end

  def parse_section_name(section_name)
    section_name.strip.gsub(/\s+/, "_")
  end

  def parse_heading(heading)
    heading.tr('_', ' ').titlecase
  end

  def pdflatex_is_found?()
    ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
      exe = File.join(path, "pdflatex")
      return true if File.executable? exe
    end
    return false
  end

  def add_line_before(line_to_be_found, line_to_be_inserted, path)
    temp_file = Tempfile.new(TEMP_FILE)
    begin
      lines = File.readlines(path)
      lines.each_cons(2) do |line, next_line|
        temp_file.puts line
        temp_file.puts line_to_be_inserted if next_line.strip == line_to_be_found
        temp_file.puts next_line if next_line.equal? lines.last
      end
      temp_file.rewind
      FileUtils.mv(temp_file.path, path)
    rescue Errno::ENOENT
      puts "File #{path} does not exist."
    ensure
      temp_file.close
      temp_file.unlink
    end
  end

end

# Commands parsing
global_opts = Trollop::options do
  version "#{VERSION} 2013 Edoardo Colombo"
  banner "LaTeX scaffolding"
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift
abort(HELP) if cmd.nil?

creator = LatexCreator.new

options = case cmd
  when "new"
    Trollop::options do
      opt :class, "Document class", :default => "article"
      opt :sections, "Document sections", :type => :strings
      opt :author, "Document author", :default => ""
      opt :title, "Document title", :default => "Document Title"
      opt :date, "Document date", :default => "\\today"
      opt :font_size, "Font size", :default => "10pt"
      opt :language, "Language", :default => "english"
      opt :packages, "Extra packages", :type => :strings
    end
  when"add-section"
    Trollop::options do
      opt :after, "Insert section after specified section", :type => :string
      opt :before, "Insert section before specified section", :type => :string
    end
  end

case cmd
when "new"
  abort(HELP) if (name = ARGV.shift).nil?
  creator.new_project(name,
                      options[:author],
                      options[:title],
                      options[:date],
                      options[:font_size],
                      options[:language],
                      options[:class],
                      options[:sections],
                      options[:packages])
when "compile"
  file = ARGV.shift
  if file.nil? then creator.compile else creator.compile file end
when "add-package"
  abort(HELP) if (package = ARGV.shift).nil?
  creator.add_package package
when "add-section"
  abort(HELP) if (section = ARGV.shift).nil? || (options[:before].nil? && options[:after].nil?)
  position = {}
  if !options[:before].nil?
    position[:section], position[:place] = options[:before], :before
  else
    position[:section], position[:place] = options[:after], :after
  end
  creator.add_section section, position
end

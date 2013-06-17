require 'rubygems'
gem 'trollop'
gem 'facets'

require 'fileutils'
require 'trollop'
require 'facets/string/titlecase'

SUB_COMMANDS = %w{new}

class LatexCreator
  def new_project(name, author, title, date, font_size, language, dclass, sections)
    if not File.exists? name
      @name = name
      @author = author
      @title = title
      @date = date
      @language = language
      @font_size = font_size
      @class = dclass
      @sectionsstring = sections
      @sections = Array.new

      FileUtils.mkdir name
      FileUtils.mkdir "#{name}/contents"
      FileUtils.mkdir "#{name}/pictures"

      create_main_tex()
      create_sections()
      create_subsections()
    else
      puts "Directory #{name} already exists. Please provide another name."
    end
  end

  def create_main_tex()
    File.open("#{@name}/main.tex", 'w') do |f|
      f.puts "\\documentclass[#{@font_size}]{#{@class}}\n"

      f.puts "%%% PACKAGES"
      write_packages(f)
      f.puts

      f.puts "%%% META"
      write_meta(f)
      f.puts

      f.puts "\\begin{document}\n"
      f.puts "\\maketitle"
      f.puts "  %%% INPUT"

      @sectionsstring.each { |s| parse_section(s, f) } unless @sectionsstring.nil?

      f.puts("\\end{document}\n")
    end
  end

  def parse_section(s, f)
    sectionname = s.split("/")[0]
    subsecsarray = s.split("/")[1]

    @sections.push(sectionname)

    unless subsecsarray.nil?
      splitted = subsecsarray.split(",")

    subsecs = splitted.map { |el|
      {:SecName => sectionname, :SubSec => el }
    }
    if @subsectionsarray.nil?
      @subsectionsarray = subsecs
    else
      @subsectionsarray = @subsectionsarray + subsecs
    end
    end

  f.puts "  \\input{contents/#{sectionname}.tex}"
  end

  def create_sections()
    @sections.each { |section| create_section section } unless @sections.nil?
  end

  def create_section(section)
    puts "creating section #{@name}/contents/#{section}.tex"
    File.open("#{@name}/contents/#{section}.tex", 'w') do |f|
      f.puts "\\section{#{section.tr('_',' ').titlecase}}\n"
      f.puts "\\label{sec:#{section}}\n"

      f.puts "  %%% INPUT"
      subsecs = @subsectionsarray.select{|s| s[:SecName]==section}
      subsecs.each { |subsec| f.puts "  \\input{contents/#{subsec[:SubSec]}.tex}" } unless subsecs.nil?

    end
  end

  def create_subsections()
    @subsectionsarray.each { |subsection| create_subsection subsection } unless @subsectionsarray.nil?
  end

  def create_subsection(subsection)
    subdir = "#{@name}/contents/#{subsection[:SecName]}"

    if not File.exists?(subdir)
      FileUtils.mkdir subdir
    end

    puts "creating subsection #{subdir}/#{subsection[:SubSec]}.tex"

    File.open("#{subdir}/#{subsection[:SubSec]}.tex", 'w') do |f|
      f.puts "\\subsection{#{subsection[:SubSec].tr('_',' ').titlecase}}\n"
      f.puts "\\label{sec:#{subsection[:SubSec]}}\n"
    end
  end

  def write_meta(file)
    file.puts "\\author{#{@author}}"
    file.puts "\\title{#{@title}}"
    file.puts "\\date{#{@date}}"
  end

  def write_packages(file)
    file.puts "\\usepackage[#{@language}]{babel}"
    file.puts "\\usepackage{asmmath}"
    file.puts "\\usepackage{asmmsymb}"
    file.puts "\\usepackage{graphicx}"
    file.puts "\\graphicspath{ {pictures/} }"
    file.puts "\\usepackage{booktabs}"
    file.puts "\\usepackage{tikz}"
  end

end

# Commands parsing
global_opts = Trollop::options do
  version "0.0 2013 Edoardo Colombo"
  banner "LaTeX scaffolding"
  stop_on SUB_COMMANDS
end

cmd = ARGV.shift
creator = LatexCreator.new

o = case cmd
  when "new"
    Trollop::options do
      opt :class, "Document class", :default => "article"
      opt :sections, "Document sections", :type => :strings
      opt :author, "Document author", :default => ""
      opt :title, "Document title", :default => "Document Title"
      opt :date, "Document date", :default => "\\today"
      opt :font_size, "Font size", :default => "10pt"
      opt :language, "Language", :default => "english"
    end
  end

case cmd
when "new"
  name = ARGV.shift
  creator.new_project(name,
                      o[:author],
                      o[:title],
                      o[:date],
                      o[:font_size],
                      o[:language],
                      o[:class],
                      o[:sections])
end

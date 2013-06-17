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
      @sections = sections

      FileUtils.mkdir name
      FileUtils.mkdir "#{name}/contents"
      FileUtils.mkdir "#{name}/pictures"

      create_main_tex()
      create_sections()
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

      f.puts "\\begin{document}"
      f.puts
      f.puts "\\maketitle"
      f.puts "  %%% INPUT"
      write_sections @sections, f unless @sections.nil?

      f.puts("\\end{document}")
    end
  end

  def create_sections()
    @sections.each { |section| create_section section } unless @sections.nil?
  end

  def create_section(section)
    section_name = section.split("/")[0]
    subsections = section.split("/")[1].split(",") unless section.split("/")[1].nil?

    File.open("#{@name}/contents/#{section_name}.tex", 'w') do |f|
      f.puts "\\section{#{parse_heading(section_name)}}"
      f.puts "\\label{sec:#{section_name}}"
      f.puts
      subsections.each { |subsection| create_subsection subsection, f } unless subsections.nil?
      f.puts
      f.puts "% section #{section_name} (end)"
    end
  end

  def create_subsection(subsection, file)
    file.puts "\\subsection{#{parse_heading(subsection)}}"
    file.puts "\\label{subsec:#{subsection}}"
    file.puts
    file.puts "% subsection #{subsection} (end)"
  end

  def parse_heading(heading)
    heading.tr('_', ' ').titlecase
  end

  def write_sections(sections, file)
    sections.each do |section|
      section_name = section.split("/")[0]
      file.puts "  \\input{contents/#{section_name}.tex}\n"
    end
  end

  def write_meta(file)
    file.puts "\\author{#{@author}}"
    file.puts "\\title{#{@title}}"
    file.puts "\\date{#{@date}}"
  end

  def write_packages(file)
    file.puts "\\usepackage[#{@language}]{babel}"
    file.puts "\\usepackage{amsmath}"
    file.puts "\\usepackage{amssymb}"
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
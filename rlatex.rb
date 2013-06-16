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
      f.write("\\documentclass[#{@font_size}]{#{@class}}\n\n")

      f.write("%%% PACKAGES\n")
      write_packages(f)
      f.write("\n")

      f.write("%%% META\n")
      write_meta(f)
      f.write("\n")

      f.write("\\begin{document}\n\n")
      f.write("\\maketitle\n")
      f.write("  %%% INPUT\n")
      @sections.each do |section|
        f.write("  \\input{contents/#{section}.tex}\n")
      end

      f.write("\\end{document}\n")
      f.write("\n")
    end
  end

  def create_sections()
    @sections.each do |section|
      create_section section
    end
  end

  def create_section(section)
    File.open("#{@name}/contents/#{section}.tex", 'w') do |f|
      f.write("\\section{#{section.tr('_',' ').titlecase}}\n")
      f.write("\\label{sec:#{section}\n")
    end
  end

  def write_meta(file)
    file.write("\\author{#{@author}}\n")
    file.write("\\title{#{@title}}\n")
    file.write("\\date{#{@date}}\n")
  end

  def write_packages(file)
    file.write("\\usepackage[#{@language}]{babel}\n")
    file.write("\\usepackage{asmmath}\n")
    file.write("\\usepackage{asmmsymb}\n")
    file.write("\\usepackage{graphicx}\n")
    file.write("\\usepackage{booktabs}\n")
    file.write("\\usepackage{tikz}\n")
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
     opt :author, "Document author", :default => ""
     opt :title, "Document title", :default => "Document Title"
     opt :date, "Document date", :default => "\\today"
     opt :font_size, "Font size", :default => "10pt"
     opt :language, "Language", :default => "english"
     opt :class, "Document class", :default => "article"
     opt :sections, "Document sections", :type => :strings
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
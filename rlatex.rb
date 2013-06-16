require 'fileutils'
require 'trollop'

SUB_COMMANDS = %w{new}

class LatexCreator
  def new_project(name, author, title, date)
    if not File.exists? name
      @name = name
      @author = author
      @title = title
      @date = date
      FileUtils.mkdir name
      FileUtils.mkdir "#{name}/contents"
      FileUtils.mkdir "#{name}/pictures"
      create_main_tex()
    else
      puts "Directory #{name} already exists. Please provide another name."
    end
  end

  def create_main_tex()
    file = File.open("#{@name}/main.tex", 'w') do |f|
      f.write("\\documentclass[10pt]{article}\n\n")
      f.write("%%% PACKAGES\n\n")

      f.write("%%% META\n\n")
      write_meta(f)
      f.write("\\begin{document}\n\n")
      f.write("\\end{document}\n")
    end
  end

  def write_meta(file)
    file.write("\\author{#{@author}}\n")
    file.write("\\title{#{@title}}\n")
    file.write("\\date{#{@date}}\n")
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

cmd_opts = case cmd
  when "new"
    Trollop::options do
     opt :author, "Document author", :default => ""
     opt :title, "Document title", :default => "Document Title"
     opt :date, "Document date", :default => "\\today"
     opt :font_size, "Font size", :default => "10pt"
    end
  end

case cmd
when "new"
  name = ARGV.shift
  creator.new_project name, cmd_opts[:author], cmd_opts[:title]
end
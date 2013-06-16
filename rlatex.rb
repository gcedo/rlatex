require 'fileutils'
require 'trollop'

SUB_COMMANDS = %w{new}

def new_project(name)
  if not File.exists? name
    FileUtils.mkdir name
    FileUtils.mkdir "#{name}/contents"
    FileUtils.mkdir "#{name}/pictures"
  else
    puts "Directory #{name} already exists. Please provide another name."
  end
end

# Commands parsing
cmd = ARGV.shift

case cmd
when "new"
  name = ARGV.shift
  new_project name
end
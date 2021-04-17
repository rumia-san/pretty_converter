#! /usr/bin/env ruby
require 'optparse'

# Add methods to String class

class String
  def is_upper?
    self == self.upcase
  end

  def is_lower?
    self == self.downcase
  end
end

# Convert to Mathematical Alphanumeric Symbols Unicode
$pretty_fonts = %i[
  Bold
  Italic
  Bold-Italic
  Script
  Bold-Script
  Fraktur
  Double-Struck
  Bold-Fraktur
  Sans-Serif
  Sans-Serif-Bold
  Sans-Serif-Italic
  Sans-Serif-Bold-Italic
  Monospace
]

# The first character is Mathematical Alphanumeric Bold 'A'
BOLD_UNICODE_NUMBER = 0x1D400

class PrettyConverter
  def initialize(pretty_font)
    pretty_index = $pretty_fonts.find_index pretty_font
    @offset = BOLD_UNICODE_NUMBER + pretty_index * 52
  end
  def convert_char(ch)
    return ch.ord.chr('utf-8') unless ('a'..'z').include? ch.downcase
    num = ch.upcase.ord - 'A'.ord
    num = num + 26 if ch.is_lower?
    (num + @offset).chr('utf-8')
  end
  def print_string(str)
    str.chars.each {|ch| print convert_char(ch)}
  end
  def print_file(file)
    File.foreach(file) do |line|
      print_string(line)
    end
  end
  def print_stdin()
    STDIN.each_line do |line|
      print_string(line)
    end
  end
end


def print_file_as_pretty(file, pretty_font)
  File.foreach(file) do |line|
    puts line
  end
end

# Print 'a' to 'z' and 'A' to 'Z' with all Mathematical Alphanumeric Symbols
def print_example
  for font in $pretty_fonts do
    puts font
    converter = PrettyConverter.new font
    for ch in (('a'..'z').to_a + ('A'..'Z').to_a) do
      print(converter.char ch)
    end
    print "\n"
  end
end

# Parse the options
$options = Hash.new
opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{__FILE__} [OPTION]... [FILE]..."
  opts.separator ""
  opts.separator "Ooptions:"
  opts.on("-f", "--font [FONT]", $pretty_fonts,
      "Use specifed font. You could use the option '-e' to list available fonts. The default is Bold-Script.") do |font|
    abort "Invalid Font. Plese Use the option '-e' to list available fonts." if font.nil?
    $options[:font] = font
  end
  opts.on("-h", "--help", "Prints this help") do
    puts opts
    exit
  end
  opts.on("-e", "--example", "Print all Mathematical Alphanumeric Symbols") do
    print_example
    exit
  end
end.parse!

# Set the font and read files
$options[:font] = 'Bold-Script'.intern if $options[:font].nil?
converter = PrettyConverter.new $options[:font]
if ARGV.empty?
  converter.print_stdin
else
  ARGV.each do |file|
    converter.print_file file
  end
end

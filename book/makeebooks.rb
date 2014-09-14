#!/usr/bin/env ruby
# encoding: utf-8
# This script converts markdown book to one of the several e-book
# formats supported with calibre (http://calibre-ebook.com)
#
# Samples:
#
# Build e-book for amazon kindle for english and russian languages
# 	$ ruby makeebooks en ru
# or
# 	$ FORMAT=mobi ruby makeebooks en ru
#
# Build e-book in 'epub' format for russian only
# 	$ FORMAT=epub ruby makeebooks ru

require 'rubygems'
require 'rdiscount'
require 'fileutils'
include FileUtils

def figures(lang,&block)
	begin
		Dir["figures/18333*.png"].each do |file|
			cp(file, file.sub(/18333fig0(\d)0?(\d+)\-tn/, '\1.\2'))
		end
		Dir["#{lang}/figures/*.png"].each do |file|
			cp(file,"figures")
		end
		Dir["#{lang}/figures-dia/*.dia"].each do |file|
			png_dest= file.sub(/.*fig0(\d)0?(\d+).dia/, 'figures/\1.\2.png')
			system("dia -e #{png_dest} #{file}")
		end
		block.call
	ensure
		Dir["figures/18333*.png"].each do |file|
			rm(file.gsub(/18333fig0(\d)0?(\d+)\-tn/, '\1.\2'))
		end
	end
end


if ARGV.length == 0
  puts "you need to specify at least one language. For example: makeebooks en"
  exit
end

format = ENV['FORMAT'] || 'mobi'
puts "using .#{format} (you can change it via FORMAT environment variable. try 'mobi' or 'epub')"

ARGV.each do |lang|
  figures (lang) do
    puts "convert content for '#{lang}' language"

    figure_title = 'Figure'
    book_title = 'Takari Extensions for Apache Maven TEAM - Documentation'
    authors = 'Jason van Zyl, Manfred Moser'
    comments = 'licensed under the Creative Commons Attribution-Non Commercial-Share Alike 3.0 license'

    book_content = %(<html xmlns="http://www.w3.org/1999/xhtml"><head><title>#{book_title}</title></head><body>)
    dir = File.expand_path(File.join(File.dirname(__FILE__), lang))
    Dir[File.join(dir, '**', '*.markdown')].sort.each do |input|
      puts "processing #{input}"
      content = File.read(input)
      content.gsub!(/Insert\s18333fig\d+\.png\s*\n.*?(\d{1,2})-(\d{1,2})\. (.*)/, '![\1.\2 \3](figures/\1.\2.png "\1.\2 \3")')
      book_content << RDiscount.new(content).to_html
    end
    book_content << "</body></html>"

    File.open("team-book.#{lang}.html", 'w') do |output|
      output.write(book_content)
    end

    $ebook_convert_cmd = ENV['ebook_convert_path'].to_s
    if $ebook_convert_cmd.empty?
      $ebook_convert_cmd = `which ebook-convert`.chomp
    end
    if $ebook_convert_cmd.empty?
      mac_osx_path = '/Applications/calibre.app/Contents/MacOS/ebook-convert'
      $ebook_convert_cmd = mac_osx_path
    end

    system($ebook_convert_cmd, "team-book.#{lang}.html", "team-book.#{lang}.#{format}",
           '--cover', 'ebooks/cover.png',
           '--authors', authors,
           '--comments', comments,
           '--level1-toc', '//h:h1',
           '--level2-toc', '//h:h2',
           '--level3-toc', '//h:h3',
           '--language', lang)
  end
end

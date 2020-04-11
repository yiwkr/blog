#!/usr/bin/env ruby

require "liquid"

template_path = ARGV[0]
output_path = ARGV[1]
jekyll_env = ARGV[2]

File.open(template_path, "r") do |infile|
  File.open(output_path, "w") do |outfile|
    outfile.write(Liquid::Template.parse(infile.read).render(
      'production' => jekyll_env == 'production')
    )
  end
end

# Raki - extensible rails-based wiki
# Copyright (C) 2010 Florian Schwab
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'digest/sha1'

class LatexPluginHelper
  class << self
    LATEX_BIN = 'latex'
    DVIPNG_BIN = 'dvipng'

    def convert(input)
      hash = Digest::SHA1.hexdigest(input)
      unless File.exists?("#{Rails.root}/public/latex/#{hash}.png")
        tex = "\\documentclass[12pt]{amsart}\n" +
          "\\usepackage[latin1]{inputenc}\n" +
          "\\usepackage{amssymb,amsmath,latexsym}\n" +
          "\\setlength{\\footskip}{0pt}\n" +
          "\\pagestyle{empty}\n" +
          "\\thispagestyle{empty}\n" +
          "\\begin{document}\n" +
          "\\boldmath\n" +
          "$#{input}$\n" +
          "\\end{document}"
        f = File.new("#{Rails.root}/tmp/latex/#{hash}.tex", 'w')
        f << tex
        f.close
        `cd "#{Rails.root}/tmp/latex/" && #{LATEX_BIN} -halt-on-error -interaction=nonstopmode "#{Rails.root}/tmp/latex/#{hash}.tex"`
        if $? != 0
          raise "#{$?}"
        end
        `#{DVIPNG_BIN} -q -T tight -bg Transparent -Q 10 -o "#{Rails.root}/public/latex/#{hash}.png" "#{Rails.root}/tmp/latex/#{hash}.dvi"`
        if $? != 0
          raise "#{$?}"
        end
        unless File.exists?("#{Rails.root}/public/latex/#{hash}.png")
          raise 'no image created'
        end
        FileUtils.rm(Dir.glob("#{Rails.root}/tmp/latex/#{hash}.*"))
      end
      "<img class=\"latex_inline\" src=\"/latex/#{hash}.png\" alt=\"#{h(input)}\" />"
    end

  end
end

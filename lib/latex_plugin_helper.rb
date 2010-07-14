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

module LatexPluginHelper
  
  LATEX_BIN = 'latex'
  DVIPNG_BIN = 'dvipng'
  
  def img_filename
    "#{Rails.root}/public/latex/#{hash}.png"
  end
  
  def tex_filename
    "#{Rails.root}/tmp/latex/#{hash}.tex"
  end
  
  def dvi_filename
    "#{Rails.root}/tmp/latex/#{hash}.dvi"
  end
  
  def tex_source
    "\\documentclass[12pt]{amsart}\n" +
    "\\usepackage[latin1]{inputenc}\n" +
    "\\usepackage{amssymb,amsmath,latexsym}\n" +
    "\\setlength{\\footskip}{0pt}\n" +
    "\\pagestyle{empty}\n" +
    "\\thispagestyle{empty}\n" +
    "\\begin{document}\n" +
    "\\boldmath\n" +
    "$#{body}$\n" +
    "\\end{document}"
  end
  
  def write_tex_file
    f = File.new(tex_filename, 'w')
    f << tex_source
    f.close
  end
  
  def hash
    "#{body_hash}_#{params_hash}"
  end
  
  def body_hash
    Digest::SHA1.hexdigest(body)
  end
  
  def params_hash
    Digest::SHA1.hexdigest(params.inspect)
  end
  
  def compile
    `cd "#{Rails.root}/tmp/latex/" && #{LATEX_BIN} -halt-on-error -interaction=nonstopmode "#{tex_filename}"`
    raise Raki::Plugin::PluginError.new "#{$?}" if $? != 0
    
    `#{DVIPNG_BIN} -q -T tight -bg Transparent -Q 10 -o "#{img_filename}" "#{dvi_filename}"`
    raise Raki::Plugin::PluginError.new "#{$?}" if $? != 0
    
    raise Raki::Plugin::PluginError.new(t 'latex.no_image_created') unless File.exists? img_filename
    
    FileUtils.rm(Dir.glob("#{Rails.root}/tmp/latex/#{hash}.*"))
    
    true
  end
  
end

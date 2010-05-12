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

Raki::Plugin.register :latex do

  name 'LatexPlugin'
  description 'Insert LaTeX into wiki pages'
  url 'http://github.com/ydkn/raki'
  author 'Florian Schwab'
  version '0.1'

  add_stylesheet '/plugin_assets/latex_plugin/stylesheets/latex.css'

  execute do |params, body, context|
    LatexPluginHelper.convert(body)
  end

end

Dir.mkdir("#{Rails.root}/tmp/latex") unless File.exists?("#{Rails.root}/tmp/latex")
Dir.mkdir("#{Rails.root}/public/latex") unless File.exists?("#{Rails.root}/public/latex")

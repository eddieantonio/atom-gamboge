# Copyright (C) 2014  Eddie Antonio Santos
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PredictionProvider = require './'

console.log('wow', PredictionProvider)

module.exports =
class UnnaturalCodeProvider extends PredictionProvider

  # Do the prediction, calling emiiting 'predictions-ready' when finished.
  predict: (id, {text, language}) ->
    origin = atom.config.get 'gamboge.unnaturalRESTOrigin'
    url = "http://#{origin}/#{language}/predict/"

    xhr = new XMLHttpRequest()
    xhr.open('POST', url, yes)
    xhr.setRequestHeader('Accept', 'application/json')
    xhr.addEventListener 'load', =>
      switch xhr.status
        when 200
          @succeeded(id, JSON.parse(xhr.responseText))
        else
          @failed(id)

    xhr.send("s=#{encodeURIComponent(text)}")

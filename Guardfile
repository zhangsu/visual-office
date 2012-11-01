#guard :sass, output: 'public/stylesheets', style: :compressed do
#  watch %r{views/stylesheets/application.sass}
#end

guard :compass do
  watch %r{^views/stylesheets/application.s[ac]ss}
end

guard :coffeescript, input: 'views/coffeescripts', output: 'public/javascripts'

guard :uglify, destination_file: 'public/javascripts/application.js' do
  watch %r{public/javascripts/application.js}
end


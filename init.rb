Redmine::Plugin.register :redmine_ruby_wasm do
  name 'Redmine ruby.wasm plugin'
  author 'Yuya.Nishida.'
  description 'This is a plugin to run Ruby code on Redmine'
  version '0.1.0'
  url 'https://github.com/nishidayuya/redmine_ruby_wasm'
  author_url 'https://twitter.com/nishidayuya'
end

plugin_path = Pathname(__dir__)
plugin_path.glob("{app,lib}/**/*.rb").sort.each do |path|
  require(path)
end

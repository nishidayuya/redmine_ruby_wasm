class RedmineRubyWasm::ViewHook < Redmine::Hook::ViewListener
  render_on :view_layouts_base_html_head, partial: "hooks/redmine_ruby_wasm/view_layouts_base_html_head"
end

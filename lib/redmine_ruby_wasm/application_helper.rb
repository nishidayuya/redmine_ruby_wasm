module RedmineRubyWasm::ApplicationHelper
  ASSET_PUBLIC_DIRECTORY_NAME = "rubies"

  ActionView::Helpers::AssetUrlHelper::ASSET_EXTENSIONS[:ruby] = ".rb"
  ActionView::Helpers::AssetUrlHelper::ASSET_PUBLIC_DIRECTORIES[:ruby] =
    "/#{ASSET_PUBLIC_DIRECTORY_NAME}"

  def ruby_wasm_ruby_require_tag(feature, plugin: nil)
    source =
      if plugin
        "/plugin_assets/#{plugin}/#{ASSET_PUBLIC_DIRECTORY_NAME}/#{feature}"
      else
        feature
      end
    src = asset_path(source, type: :ruby)
    tag_options = {
      type: "text/ruby",
      src: src,
    }
    return content_tag(:script, "", tag_options)
  end
end

require "js"
require "json"

class Hash
  def to_js
    return JS.eval("return #{to_json}")
  end
end

JsArray = JS.global[:Array]
window = JS.global
console = JS.global[:console]
document = JS.global[:document]

dialog_node = document.createElement("div")
dialog_node[:id] = "ruby-output-dialog"
dialog_node[:title] = "Result"

body_node = document.querySelector("body")
body_node.appendChild(dialog_node)

jq_dialog = window.jQuery("#ruby-output-dialog")
jq_dialog.dialog(
  autoOpen: false,
  modal: true,
)

node_list = document.querySelectorAll("code.ruby.syntaxhl")
JsArray.from(node_list).forEach do |code_node|
  code_node.addEventListener("click") do |_pointer_event|
    code = code_node[:innerText].to_s
    console.log("evaluating: #{code.inspect}")
    evaluated = eval(code)
    console.log("evaluated: #{evaluated.inspect}")

    jq_dialog.text(evaluated.inspect)
    jq_dialog.dialog("open")
  end
end

-- replaces md with html in links
function Link(el)
  el.target = string.gsub(el.target, "%.md", ".html")
  return el
end

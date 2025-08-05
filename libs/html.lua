---@class HTMLElement
---@field name string
---@field attrs table<string, any>
---@field content HTMLElement|string[]

local html_meta = {
    __name = "html-element",
    ---@param self HTMLElement
    __tostring = function (self)
        local attrs = " "
        local content = ""
        for k, v in pairs(self.content) do
            if type(k) == "number" then
                content = content .. tostring(v)
            elseif type(k) == "string" then
                attrs = attrs .. k .. "=" .. ("%q"):format(v) .. " "
            end
        end
        return ("<%s%s>%s</%s>"):format(self.name, attrs, content, self.name)
    end,
}

---@param element HTMLElement
---@return string
function document(element)
    return "<!DOCTYPE html>" .. tostring(element)
end

---@param name string
---@param content table
---@return HTMLElement
function element(name, content)
    return setmetatable({
        name = name,
        content = content,
    }, html_meta)
end

---@param content table
---@return HTMLElement
function html(content)
    return element("html", content)
end
---@param content table
---@return string
function htmlDocument(content)
    return document(html(content))
end
---@param content table
---@return HTMLElement
function head(content)
    return element("head", content)
end
---@param content table
---@return HTMLElement
function body(content)
    return element("body", content)
end
---@param content table
---@return HTMLElement
function style(content)
    content.type = "text/css"
    return element("style", content)
end
---@param content table
---@return HTMLElement
function h1(content)
    return element("h1", content)
end
---@param content table
---@return HTMLElement
function h2(content)
    return element("h2", content)
end
---@param content table
---@return HTMLElement
function h3(content)
    return element("h3", content)
end
---@param content table
---@return HTMLElement
function h4(content)
    return element("h4", content)
end
---@param content table
---@return HTMLElement
function h5(content)
    return element("h5", content)
end
---@param content table
---@return HTMLElement
function h6(content)
    return element("h6", content)
end
---@param content table
---@return HTMLElement
function p(content)
    return element("p", content)
end
---@return HTMLElement
function hr()
    return element("hr", {})
end
---@return HTMLElement
function br()
    return element("br", {})
end
---@param content table
---@return HTMLElement
function pre(content)
    return element("pre", content)
end
---@param content table
---@return HTMLElement
function b(content)
    return element("b", content)
end
---@param content table
---@return HTMLElement
function strong(content)
    return element("strong", content)
end
---@param content table
---@return HTMLElement
function i(content)
    return element("i", content)
end
---@param content table
---@return HTMLElement
function em(content)
    return element("em", content)
end
---@param content table
---@return HTMLElement
function mark(content)
    return element("mark", content)
end
---@param content table
---@return HTMLElement
function del(content)
    return element("del", content)
end
---@param content table
---@return HTMLElement
function ins(content)
    return element("ins", content)
end
---@param content table
---@return HTMLElement
function sub(content)
    return element("sub", content)
end
---@param content table
---@return HTMLElement
function sup(content)
    return element("sup", content)
end
---@param content table
---@return HTMLElement
function blockquote(content)
    return element("blockquote", content)
end
---@param content table
---@return HTMLElement
function q(content)
    return element("q", content)
end
---@param content table
---@return HTMLElement
function abbr(content)
    return element("abbr", content)
end
---@param content table
---@return HTMLElement
function address(content)
    return element("address", content)
end
---@param content table
---@return HTMLElement
function cite(content)
    return element("cite", content)
end
---@param content table
---@return HTMLElement
function bdo(content)
    return element("bdo", content)
end
---@param content table
---@return HTMLElement
function a(content)
    return element("a", content)
end
---@param content table
---@return HTMLElement
function button(content)
    return element("button", content)
end
---@param content table
---@return HTMLElement
function img(content)
    return element("img", content)
end
---@param content table
---@return HTMLElement
function video(content)
    return element("video", content)
end
---@param content table
---@return HTMLElement
function map(content)
    return element("map", content)
end
---@param content table
---@return HTMLElement
function area(content)
    return element("area", content)
end
---@param content table
---@return HTMLElement
function picture(content)
    return element("picture", content)
end
---@param content table
---@return HTMLElement
function link(content)
    return element("link", content)
end
---@param content table
---@return HTMLElement
function title(content)
    return element("title", content)
end
---@param content table
---@return HTMLElement
function htable(content)
    return element("table", content)
end
---@param content table
---@return HTMLElement
function th(content)
    return element("th", content)
end
---@param content table
---@return HTMLElement
function tr(content)
    return element("tr", content)
end
---@param content table
---@return HTMLElement
function td(content)
    return element("td", content)
end
---@param content table
---@return HTMLElement
function caption(content)
    return element("caption", content)
end
---@param content table
---@return HTMLElement
function colgroup(content)
    return element("colgroup", content)
end
---@param content table
---@return HTMLElement
function col(content)
    return element("col", content)
end
---@param content table
---@return HTMLElement
function thead(content)
    return element("thead", content)
end
---@param content table
---@return HTMLElement
function tbody(content)
    return element("tbody", content)
end
---@param content table
---@return HTMLElement
function tfoot(content)
    return element("tfoot", content)
end
---@param content table
---@return HTMLElement
function ul(content)
    return element("ul", content)
end
---@param content table
---@return HTMLElement
function ol(content)
    return element("ol", content)
end
---@param content table
---@return HTMLElement
function il(content)
    return element("il", content)
end
---@param content table
---@return HTMLElement
function li(content)
    return element("li", content)
end
---@param content table
---@return HTMLElement
function dl(content)
    return element("dl", content)
end
---@param content table
---@return HTMLElement
function dt(content)
    return element("dt", content)
end
---@param content table
---@return HTMLElement
function dd(content)
    return element("dd", content)
end
---@param content table
---@return HTMLElement
function div(content)
    return element("div", content)
end
---@param content table
---@return HTMLElement
function article(content)
    return element("article", content)
end
---@param content table
---@return HTMLElement
function canvas(content)
    return element("canvas", content)
end
---@param content table
---@return HTMLElement
function fieldset(content)
    return element("fieldset", content)
end
---@param content table
---@return HTMLElement
function figcaption(content)
    return element("figcaption", content)
end
---@param content table
---@return HTMLElement
function figure(content)
    return element("figure", content)
end
---@param content table
---@return HTMLElement
function header(content)
    return element("header", content)
end
---@param content table
---@return HTMLElement
function nav(content)
    return element("nav", content)
end
---@param content table
---@return HTMLElement
function main(content)
    return element("main", content)
end
---@param content table
---@return HTMLElement
function footer(content)
    return element("footer", content)
end
---@param content table
---@return HTMLElement
function form(content)
    return element("form", content)
end
---@param content table
---@return HTMLElement
function noscript(content)
    return element("noscript", content)
end
---@param content table
---@return HTMLElement
function section(content)
    return element("section", content)
end
---@param content table
---@return HTMLElement
function span(content)
    return element("span", content)
end
---@param content table
---@return HTMLElement
function textarea(content)
    return element("textarea", content)
end
---@param content table
---@return HTMLElement
function code(content)
    return element("code", content)
end
---@param content table
---@return HTMLElement
function input(content)
    return element("input", content)
end
---@param content table
---@return HTMLElement
function output(content)
    return element("output", content)
end
---@param content table
---@return HTMLElement
function script(content)
    return element("script", content)
end
---@param content table
---@return HTMLElement
function select(content)
    return element("select", content)
end
---@param content table
---@return HTMLElement
function time(content)
    return element("time", content)
end
---@param content table
---@return HTMLElement
function var(content)
    return element("var", content)
end
---@param content table
---@return HTMLElement
function meta(content)
    return element("meta", content)
end
---@param content table
---@return HTMLElement
function base(content)
    return element("base", content)
end
---@param content table
---@return HTMLElement
function aside(content)
    return element("aside", content)
end
---@param content table
---@return HTMLElement
function details(content)
    return element("details", content)
end
---@param content table
---@return HTMLElement
function summary(content)
    return element("summary", content)
end
---@class HTMLElement
---@field name string
---@field attrs table<string, any>
---@field content HTMLElement|string[]

local html_meta = {
    __name = "html-element",
    ---@param self HTMLElement
    __tostring = function (self)
        local attrs = ""
        local content = ""
        for k, v in pairs(self.content) do
            if type(k) == "number" then
                content = content .. tostring(v)
            elseif type(k) == "string" then
                attrs = attrs .. k .. "=" .. ("%q"):format(v) .. " "
            end
        end
        return ("<%s %s>%s</%s>"):format(self.name, attrs, content, self.name)
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
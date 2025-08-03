---@class Response
---@field status integer
---@field body string?
---@field headers table<string, string>?
local status_reasons = {
    [200] = "OK",
    [404] = "Not Found",
    [500] = "Internal Server Error",
    -- Add more as needed
}

local reponse_meta = {
    __name = "response",
    ---@param self Response
    ---@return string
    __tostring = function (self)
        local headers = ""
        for k, v in pairs(self.headers or {}) do
            headers = headers .. k .. ": " .. tostring(v) .. "\n"
        end
        return ("HTTP/1.1 %d %s\r\n%s\r\n%s"):format(self.status, status_reasons[self.status] or "Unknown", headers, self.body or "")
    end,
}

---@param res Response
function response(res)
    return setmetatable(res, reponse_meta)
end
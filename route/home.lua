---@param attrs table<string, string>
---@return Response
return function (attrs)
    VISITED = VISITED + 1
    return response {
        status = 200,
        body = htmlDocument {
            head {};
            body { VISITED };
        },
        headers = {
            ["Content-Type"] = "text/html"
        }
    }
end
---@param attrs table<string, string>
---@return Response
return function (attrs)
    return response {
        status = 200,
        body = htmlDocument {
            head {
                style { STYLES.main };
            };
            body { VISITED };
        },
        headers = {
            ["Content-Type"] = "text/html"
        },
    }
end
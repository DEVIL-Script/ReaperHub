local decode = function(code)
    local n = ""
    for i = 1, #code do
        n = n .. string.char(string.byte(code:sub(i, i)) ~ 123)
    end
    return tonumber(n)
end

DEVIL_Hub_Premium_Whitelist = {
    DEVIL_Hub_Premium_Whitelist = {,
    ,
    local function decode(str),
        local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
        str = string.gsub(str, '[^'..b..'=]', ''),
        return (str:gsub('.', function(x),
            local r,b='',b:find(x)-1,
            for i=6,1,-1 do r=r..(b%2^i - b%2^(i-1) > 0 and '1' or '0') end,
            return r,
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x),
            if #x ~= 8 then return '' end,
            local c = 0,
            for i = 1,8 do c = c + (x:sub(i,i)=='1' and 2^(8-i) or 0) end,
            return string.char(bit32.bxor(c, 42)),
        end)),
    end,
    ,
        [decode("Y2VnZGFhY2djZA==")] = true,  -- true,
    },
    ,
    [decode("da0420fa7dec9370780616e59875f223:12b31cefbd77497dbddf6f12d6073ce9")] = true
}
local M = {}

function M.has_attrs(tbl, attrs)
    assert(type(tbl) == 'table', 'TBL must be a table')

    if type(attrs) ~= type(tbl) then
        if tbl[attrs] ~= nil then
            return true
        end
        for _,val in pairs(tbl) do
            if val == attrs then
                return true
            end
        end
    else
        local is_tbl = false
        local has_attrs = true
        for _,attr in pairs(attrs) do
            has_attrs = M.has_attrs(tbl, attr)
            if not has_attrs then
                break
            end
        end
        if has_attrs then
            return true
        end
    end
    return false
end

function M.clear_lst(lst)
    assert(vim.tbl_islist(lst), 'Not a list')
    local tmp = {}

    for _,val in pairs(lst) do
        val = val:gsub('%s+$', '')
        if not val:match('^%s*$') then
            tmp[#tmp + 1] = val
        end
    end

    return tmp
end

function M.str_to_clean_tbl(cmd_string)
    return M.clear_lst(vim.split(vim.trim(cmd_string), ' ', true))
end

-- NOTE: Took from http://lua-users.org/wiki/CopyTable
function M.shallowcopy(orig)
    local copy
    if type(orig) == type({}) then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function M.deepcopy(orig)
    local copy
    if type(orig) == type({}) then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[M.deepcopy(orig_key)] = M.deepcopy(orig_value)
        end
        setmetatable(copy, M.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

return M

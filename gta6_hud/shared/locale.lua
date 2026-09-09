Locales = {}

function Locale(str, ...)
    local template = nil
    if Locales[Config.Locale] and Locales[Config.Locale][str] then
        template = Locales[Config.Locale][str]
    elseif Locales['en'] and Locales['en'][str] then
        template = Locales['en'][str]
    end
    if not template then
        return 'Translation [' .. str .. '] does not exist'
    end
    local ok, result = pcall(string.format, template, ...)
    if ok then return result end
    return template
end

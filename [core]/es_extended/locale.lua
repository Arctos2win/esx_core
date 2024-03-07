Locales = {}

function Translate(str, ...) -- Translate string
    local Locale = Config.Locale or GetConvar("esx:locale", "en") 
    if not str then
        print(("[^1ERROR^7] Resource ^5%s^7 You did not specify a parameter for the Translate function or the value is nil!"):format(GetInvokingResource() or GetCurrentResourceName()))
        return "Given translate function parameter is nil!"
    end
    if Locales[Locale] then
        if Locales[Locale][str] then
            return string.format(Locales[Locale][str], ...)
        elseif Locale ~= "en" and Locales["en"] and Locales["en"][str] then
            return string.format(Locales["en"][str], ...)
        else
            return ("Translation [%s][%s] does not exist"):format(Locale, str)
        end
    elseif Locale ~= "en" and Locales["en"] and Locales["en"][str] then
        return string.format(Locales["en"][str], ...)
    else
        return ("Locale [%s] does not exist"):format(Locale)
    end
end

function TranslateCap(str, ...) -- Translate string first char uppercase
    return _(str, ...):gsub("^%l", string.upper)
end

_ = Translate
_U = TranslateCap

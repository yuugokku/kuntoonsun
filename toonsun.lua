-- toonsun.lua written by @yuugokku (KPHT)

-- 短母音
fecher_mangaton = {
    'a', 'i', 'u', 'e', 'o'
}
-- 長母音
kokia_mangaton = {
    'aa', 'ii', 'uu', 'ee', 'oo'
}
-- イストゥゴア母音
istugoa_mangaton = {
    'ai', 'ui', 'ei', 'oi'
}

-- 単子音
taao_kastanton = {
    'f', 'p', 'b', 'm',
    'z','r', 
    't', 'd', 's', 'j', 'n',
    'k', 'g',
    'v', 'h',
    'w', 'y'
}

-- 二重子音
taaku_kastanton = {
    fy = '1', py = '2', by = '3', ph = '4', phy = '5', bw = '6', my = '7',
    th = 'l', zy = '8', ry = '9', ty = '!', dy = '#', ts = '@', ch = 'c',
    sy = '$', ny = '=', ky = '_', gy = '&', hy = '~',
    x = 'ks' -- xは/ks/と等価
}

function get_all_consonants()
    local consonants = taao_kastanton
    for k, v in pairs(taaku_kastanton) do
        consonants[#consonants + 1] = v
    end
    return consonants
end

function join_lists(list1, list2)
    local new_list = list1
    for i, v in ipairs(list2) do
        new_list[#new_list + 1] = v
    end
    return new_list
end

function get_compound_vowels()
    return join_lists(kokia_mangaton, istugoa_mangaton)
end

function split(str, splitter)
    if splitter == nil then return {} end
    local t = {}
    i = 1
    for s in string.gmatch(str, '([^' .. splitter .. ']+)') do
        t[i] = s
        i = i + 1
    end
    return t
end

function includes(list, elem)
    for idx, list_item in ipairs(list) do
        if list_item == elem then
            return true
        end
    end
    return false
end

function bool_to_num(flag)
    if flag then
        return 1
    end
    return 0
end

function encode(input)
    local text = input:gsub('^%s+', ''):gsub('%s+$', ''):gsub('\\.', ''):gsub(',', ''):gsub('\'', '')
    for from, to in pairs(taaku_kastanton) do
        text = text:gsub(from, to)
    end
    local converted = ''
    for i = 1, string.len(text) do
        to_add = ''
        if string.sub(text, i, i) == " " then
            if includes(fecher_mangaton, string.sub(text, i - 1, i - 1)) and
                includes(fecher_mangaton, string.sub(text, i + 1, i + 1)) then
                to_add = ','
            end
        else
            to_add = string.sub(text, i, i)
        end
        converted = converted .. to_add
    end
    return converted
end

function decode(text)
    local converted = text
    for to, from in pairs(taaku_kastanton) do
        converted = converted:gsub(from, to)
    end
    return converted
end

function count_vowels(text)
    local count = 0
    for i = 1, string.len(text) do
        if includes(fecher_mangaton, string.sub(text, i, i)) then
            count = count + 1
        end
    end
    return count
end

function decompose(syllable)
    local n_consonants = 0
    while n_consonants < string.len(syllable) do
        if includes(fecher_mangaton, string.sub(syllable, n_consonants + 1, n_consonants + 1)) then
            break
        end
        n_consonants = n_consonants + 1
    end
    local head_c = ''
    local vowel = ''
    local foot = ''
    local n_vowels = count_vowels(syllable)
    if n_consonants > 0 then
        head_c = string.sub(syllable, 1, n_consonants)
        vowel = string.sub(syllable, n_consonants + 1, n_consonants + n_vowels)
        if string.len(syllable) > n_consonants + n_vowels then
            foot_c = string.sub(syllable, n_vowels + n_consonants + 1, -1)
        else
            foot_c = ''
        end
    else
        head_c = ''
        vowel = string.sub(syllable, 1, n_vowels)
        if string.len(syllable) > n_vowels then
            foot_c = string.sub(syllable, n_vowels, -1)
        else
            foot_c = ''
        end
    end
    return head_c, vowel, foot_c
end

function _into_syllables(text)
    local mangaton = fecher_mangaton
    local kastanton = get_all_consonants()
    loc = {}
    local n_kastanton = 0
    local kastanton_pre = true
    for i = 1, string.len(text) do
        ch = string.sub(text, i, i)
        if includes(mangaton, ch) then
            if kastanton_pre then
                loc[#loc + 1] = i - bool_to_num(n_kastanton > 0)
            end
            kastanton_pre = false
            n_kastanton = 0
        elseif includes(kastanton, ch) then
            kastanton_pre = true
            n_kastanton = n_kastanton + 1
        end
    end
    loc[#loc + 1] = string.len(text) + 1
    local top_c = string.sub(text, 1, loc[1] - 1)
    if loc[1] == 1 then
        top_c = ''
    end
    local syllables = {}
    for i = 1, #loc - 1 do
        local s, e = loc[i], loc[i + 1]
        local syllable = string.sub(text, s, e - 1):gsub('^%s+', ''):gsub('%s+$', '')
        syllables[#syllables + 1] = syllable
    end
    for i, v in ipairs(syllables) do
    end
    local syllables_ = {}
    for index, s in ipairs(syllables) do
        if count_vowels(s) >= 3 then
            local head_c, v, c = decompose(s)
            start = string.len(head_c) + 1
            i = start
            m = {}
            while string.len(s) > i do
                if includes(kokia_mangaton, string.sub(s, i, i + 1)) then
                    m.kokia = i
                end
                if includes(istugoa_mangaton, string.sub(s, i, i + 1)) then
                    m.istugoa = i
                end
                if includes(mangaton, string.sub(s, i, i)) and
                    includes(kastanton, string.sub(s, i + 1, i + 1)) then
                    break
                end
                i = i + 1
            end
            if m.kokia ~= nil then
                i = m.kokia
            else
                i = m.istugoa
            end
            if count_vowels(s) == 3 then
                if start == i then
                    parts = {string.sub(s, start, i + 1), string.sub(s, i + 2, -1)}
                else
                    parts = {string.sub(s, start, i - 1), string.sub(s, i, -1)}
                end
            else
                -- 今のところ、母音が5回以上連続することはない
                if start == i then -- [aa][a][a]s
                    parts = {
                        string.sub(s, start, start + 1),
                        string.sub(s, start + 2, -1)
                    }
                elseif start + 1 == i then -- [a][aa][a]s
                    parts = {
                        string.sub(s, start, start),
                        string.sub(s, i, i + 1),
                        string.sub(s, i + 2, -1)
                    }
                elseif start + 2 == i then -- [a][a][aa]s
                    parts = {
                        string.sub(s, start, i - 1),
                        string.sub(s, i, -1)
                    }
                end
            end
            for i, part in ipairs(parts) do
                if part ~= '' then
                    syllables_[#syllables_ + 1] = top_c .. head_c .. part
                    head_c = ''
                    top_c = ''
                end
            end
        elseif count_vowels(s) == 2 then
            if includes(kastanton, string.sub(s, 1, 1)) then
                head_c = string.sub(s, 1, 1)
            else
                head_c = ''
            end
            start = string.len(head_c) + 1
            if includes(get_compound_vowels(), string.sub(s, start, start + 1)) then
                syllables_[#syllables_ + 1] = top_c .. head_c .. string.sub(s, start, -1)
            else
                if includes(kastanton, string.sub(s, -1, -1)) then
                    syllables_[#syllables_ + 1] = top_c .. head_c .. string.sub(s, start, start)
                    syllables_[#syllables_ + 1] = string.sub(s, start + 1, -1)
                else
                    syllables_[#syllables_ + 1] = top_c .. head_c .. string.sub(s, start, -1)
                end
            end
            top_c = ''
        else
            syllables_[#syllables_ + 1] = top_c .. s
            top_c = ''
        end
    end
    return syllables_
end

function into_syllables(input)
    local text = string.lower(input)
    text = encode(text)
    text = split(text, ',')
    local syllables = {}
    for i, t in ipairs(text) do
        join_lists(syllables, _into_syllables(t))
    end
    return syllables
end

function scan(headword, translation, example, dictionary_name)
    local syllables = into_syllables(headword)
    mark = ''
    for i, s in ipairs(syllables) do
        head_c, vowel, foot_c = decompose(s)
        print(head_c, vowel, foot_c)
        if string.len(vowel) > 1 then
            mark = mark .. '-'
        elseif foot_c ~= '' then
            if i == #syllables
                and string.len(vowel) == 1
                and string.len(foot_c) == 1 then
                mark = mark .. '='
            else
                mark = mark .. '-'
            end
        else
            mark = mark .. 'u'
        end
    end
    return mark
end

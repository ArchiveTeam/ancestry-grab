----TODO----
--Deeper url scraping for mundiasurnames
--DONE Add support for cgi urls for genforum
--Add support for myfamily


dofile("urlcode.lua")
dofile("table_show.lua")
JSON = (loadfile "JSON.lua")()

local url_count = 0
local tries = 0
local item_type = os.getenv('item_type')
local item_value = os.getenv('item_value')

local downloaded = {}

load_json_file = function(file)
  if file then
    local f = io.open(file)
    local data = f:read("*all")
    f:close()
    return JSON:decode(data)
  else
    return nil
  end
end

read_file = function(file)
  if file then
    local f = assert(io.open(file))
    local data = f:read("*all")
    f:close()
    return data
  else
    return ""
  end
end

wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
  local url = urlpos["url"]["url"]
  local html = urlpos["link_expect_html"]
  local parenturl = parent["url"]
  local html = nil
  
  if downloaded[url] == true then
    return false
  end
  
  if string.match(url, "chat%.genealogy%.com") then
    return false
  elseif string.match(url, "chat01%.genealogy%.com") then
    return false
  end
  
  if string.match(url, "///") then
    return false
  end
  
  if item_type == "genealogy" then
    if string.match(url, "www%.familyorigins%.com") then
      return false
    elseif string.match(url, "familytreemaker%.genealogy%.com") then
      return false
    elseif string.match(url, "genforum%.genealogy%.com") then
      return false
    else
      return verdict
    end
  elseif item_type == "familytreemaker" then
    if string.match(url, "www%.familyorigins%.com") then
      return false
    elseif string.match(url, "www%.genealogy%.com") then
      return false
    elseif string.match(url, "genforum%.genealogy%.com") then
      return false
    else
      return verdict
    end
  elseif item_type == "familyorigins" then
    if string.match(url, "www%.genealogy%.com") then
      return false
    elseif string.match(url, "familytreemaker%.genealogy%.com") then
      return false
    elseif string.match(url, "genforum%.genealogy%.com") then
      return false
    else
      return verdict
    end
  elseif item_type == "genforum" then
    return verdict
  end
  
  if item_type == "genealogy" or
    item_type == "familytreemaker" or
    item_type == "familyorigins" then
    local url_kind = os.getenv('url_kind')
    local url_first = os.getenv('url_first')
    local url_second = os.getenv('url_second')
    local url_third = os.getenv('url_third')
    local url_name = os.getenv('url_name')
    if string.match(url, "chat%.genealogy%.com") then
      return false
    elseif string.match(url, "chat01%.genealogy%.com") then
      return false
    elseif (string.match(url, "%.genealogy%.com/genealogy/") or string.match(url, "%.familyorigins%.com/genealogy/")) and
      html == 1 then
      --example url: http://www.genealogy.com/genealogy/users/s/c/h/Aaron-D-Scholl/
      local url_kind_url = string.match(url, "[a-z]+%.[a-z]+%.com/genealogy/([^/]+)/[^/]+/[^/]+/[^/]+/[^/]+/")
      local url_first_url = string.match(url, "[a-z]+%.[a-z]+%.com/genealogy/[^/]+/([^/]+)/[^/]+/[^/]+/[^/]+/")
      local url_second_url = string.match(url, "[a-z]+%.[a-z]+%.com/genealogy/[^/]+/[^/]+/([^/]+)/[^/]+/[^/]+/")
      local url_third_url = string.match(url, "[a-z]+%.[a-z]+%.com/genealogy/[^/]+/[^/]+/[^/]+/([^/]+)/[^/]+/")
      local url_name_url = string.match(url, "[a-z]+%.[a-z]+%.com/genealogy/[^/]+/[^/]+/[^/]+/[^/]+/([^/]+)/")
      if url_kind_url ~= url_kind or
        url_first_url ~= url_first or
        url_second_url ~= url_second or
        url_third_url ~= url_third or
        url_name_url ~= url_name then
        return false
      else
        return verdict
      end
    elseif (string.match(url, "%.genealogy%.com") or string.match(url, "%.familyorigins%.com"))
      and html == 1 then
      --example url: http://www.genealogy.com/users/s/c/h/Aaron-D-Scholl/
      local url_kind_url = string.match(url, "[a-z]+%.[a-z]+%.com/([^/]+)/[^/]+/[^/]+/[^/]+/[^/]+/")
      local url_first_url = string.match(url, "[a-z]+%.[a-z]+%.com/[^/]+/([^/]+)/[^/]+/[^/]+/[^/]+/")
      local url_second_url = string.match(url, "[a-z]+%.[a-z]+%.com/[^/]+/[^/]+/([^/]+)/[^/]+/[^/]+/")
      local url_third_url = string.match(url, "[a-z]+%.[a-z]+%.com/[^/]+/[^/]+/[^/]+/([^/]+)/[^/]+/")
      local url_name_url = string.match(url, "[a-z]+%.[a-z]+%.com/[^/]+/[^/]+/[^/]+/[^/]+/([^/]+)/")
      if url_kind_url ~= url_kind or
        url_first_url ~= url_first or
        url_second_url ~= url_second or
        url_third_url ~= url_third or
        url_name_url ~= url_name then
        return false
      else
        return verdict
      end
    elseif (string.match(parenturl, "%.genealogy%.com/") or string.match(parenturl, "%.familyorigins%.com"))
      and html == 1 then
      return true
    elseif html == 0 then
      return true
    else
      return false
    end
  elseif item_type == "mundiasurnames" then
    if string.match(url, "c%.muncn%.com") then
      return true
    elseif string.match(url, "mediasvc%.ancestry%.com") then
      return true
    elseif string.match(url, "ecn%.dev%.virtualearth%.net") then
      return true
    elseif string.match(url, "myfamily2%.[0-9]+%.[a-z0-9]+%.net") then
      return true
    elseif string.match(url, "tiles%.virtualearth%.net") then
      return true
    elseif string.match(url, "dev%.virtualearth%.net") then
      return true
    elseif string.match(url, "mundia%.com/[^/]+/surnames/[a-z0-9A-Z]+") then
      return true
    elseif string.match(url, "mundia%.com/[^/]+/Search/Results%?surname=[^&]+&birthPlace=") then
      return true
    elseif string.match(url, "mundia%.com/[^/]+/Person/[^/]+/.+") then
      return true
    elseif string.match(url, "mundia%.com/[^/]+/Tree/Family/[^/]+/.+") then
      return true
    elseif string.match(url, "mundia%.com/[^/]+/Messages%?sendMessageTo=[^&]+&subject=") then
      return true
    elseif string.match(url, "/media/") then
      return true
    elseif string.match(url, ".jpg") or string.match(url, ".png") or string.match(url, ".gif") then
      return true
    elseif html == 0 then
      return true
    else
      return false
    end
  elseif item_type == "genforum" then
    if string.match(url, "genforum%.genealogy%.com/([^/]+)/") and
      html == 1 then
      local item_value_url = string.match(url, "genforum%.genealogy%.com/([^/])/")
      if item_value_url ~= item_value then
        return false
      else
        return verdict
      end
    elseif string.match(url, "genforum%.com/([^/]+)/") and
      html == 1 then
      local item_value_url = string.match(url, "genforum%.com/([^/])/")
      if item_value_url ~= item_value then
        return false
      else
        return verdict
      end
    elseif string.match(url, "genforum%.genealogy%.com[.]+"..item_value) or
      string.match(url, "genforum%.com[.]+"..item_value) then
      if string.match(url, ":::") then
        if not html then
          html = read_file(file)
        end
        if string.match(html, '<FONT FACE=[^>]+><B><[^<]+</A>[^<]+<A[^<]+</A></B></FONT><BR>[^<]+<UL>[^<]+</UL>[^<]+<[^<]+<B><[^<]+</A>[^<]+<[^<]+</A></B></font><BR>') then
          return false
        else
          return true
        end
      else
        return true
      end
    elseif html == 0 then
      return true
    else
      return false
    end
  elseif item_type == 'myfamily' then
    if string.match(url, item_type) then
      return verdict
    elseif string.match(url, "/Styles/")
      or string.match(url, "/Scripts/")
      or string.match(url, "/Features/")
      or string.match(url, "/Images/")
      or string.match(url, "share%?s=")
      or string.match(url, "/images/")
      or string.match(url, "media%.myfamily%.com")
      or string.match(url, "myfamily[0-9]%.[0-9]+%.[0-9a-z]+%.net")
      or string.match(url, "/group/") then
      return true
    else
      return false
    end
  elseif item_type == 'genealogysite' then
    if string.match(url, "/users/[^/]+/[^/]+/[^/]+/[^/]+/")
      or string.match(url, "/genealogy/users/[^/]+/[^/]+/[^/]+/[^/]+/") then
      return false
    end
  else
    return false
  end
end


wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}
  local html = nil
  
  if item_type == "mundiasurnames" then
    --example url: http://www.mundia.com/us/surnames/aleo
    if string.match(url, "%.mundia%.com/[^/]+/surnames/[^/]+") then
      local surname_lower = string.match(url, "%.mundia%.com/[^/]+/surnames/([^/]+)")
      local surname_upper = string.upper(surname_lower)
      local country_code = string.match(url, "%.mundia%.com/([^/]+)/surnames/[^/]+")
      --chfoo - is it alright is I add all these urls for all countries?
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Afghanistan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Albania" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Algeria" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Argentina" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Armenia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Australia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Austria" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Azerbaijan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Bahrain" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Bangladesh" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Belgium" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Belize" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Bolivia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Bosnia%20%26%20Herzegovina" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Brazil" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Brunei" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Bulgaria" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Cambodia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Canada" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Chile" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=China" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Colombia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Costa%20Rica" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Croatia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Czech%20Republic" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Denmark" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Dominican%20Republic" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Ecuador" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Egypt" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=El%20Salvador" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Estonia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Ethiopia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Faroe%20Is." })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Finland" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=France" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Georgia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Germany" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Greece" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Greenland" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Guatemala" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Honduras" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Hungary" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Iceland" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=India" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Indonesia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Ireland" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Israel" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Italy" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Jamaica" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Japan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Jordan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Kazakhstan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Kenya" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Kuwait" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Kyrgyzstan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Laos" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Latvia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Lebanon" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Libya" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Liechtenstein" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Lithuania" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Luxembourg" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Macedonia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Malaysia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Maldives" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Malta" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Mexico" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Monaco" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Mongolia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Morocco" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Nepal" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Netherlands" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=New%20Zealand" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Nicaragua" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Nigeria" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Norway" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Oman" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Pakistan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Panama" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Paraguay" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Peru" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Philippines" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Poland" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Portugal" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Qatar" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Romania" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Russia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Rwanda" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Saudi%20Arabia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Senegal" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Singapore" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Slovakia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Slovenia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=South%20Africa" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=South%20Korea" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Spain" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Sri%20Lanka" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Sweden" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Switzerland" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Taiwan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Tajikistan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Thailand" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Trinidad%20%26%20Tobago" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Tunisia" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Turkey" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Turkmenistan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Ukraine" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=United%20Arab%20Emirates" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=United%20Kingdom" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=United%20States" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Uruguay" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Uzbekistan" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Venezuela" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Vietnam" })
      table.insert(urls, { url="http://www.mundia.com/"..country_code.."/Search/Results?surname="..surname_upper.."&birthPlace=Yemen" })
    end
--    --example url: http://www.mundia.com/pk/Search/Results?surname=ABDULA&birthPlace=Verenigde%20Staten
--    if string.match(url, "%.mundia%.com/[^/]+/Search/Results%?surname=[^/&]+&birthPlace=[^<>/&]+") then
--      if not html then
--        html = read_file(file)
--      end
--      --example string: <a href="/pk/Person/5586782/-1432906874" class="">Joseph Sadula Abdula</a>
--      for person_url in string.gmatch(html, '<a href="(/[^/]+/Person/[^/]/[^/"& ]+)" class="">[^<>/]+</a>') do
--        --------------Multiple links possible as results probably - chfoo - help?-------------------
--        table.insert(urls, { url=mundia_url..person_url })
--      end
--      --example string: <a class="tree" href="/pk/Tree/Family/5586782/-1432906874"><span class="view-tree">Stamboom tonen</span></a>
--      for tree_url in string.gmatch(html, '<a class="[^"/<>]+" href="(/[^/]+/Tree/Family/[^/]/[^<>/]+)"><span class="view%-tree">[^<>/]+</span></a>') do
--        --------------Multiple links possible as results probably - chfoo - help?-------------------
--        table.insert(urls, { url=mundia_url..tree_url })
--      end
--      --example string: <img src="http://mediasvc.ancestry.com/v2/image/namespaces/1093/media/11f96e77-c39c-4ca4-b659-32f67aa8d129.jpg?client=TreeService&MaxSide=96" width="68" alt="Foto" /></a>
--      for person_image in string.gmatch(html, '<img src="(http://mediasvc%.ancestry%.com/v[^/]+/image/namespaces/[^/]+/media/[^/%.]+%.jpg%?client=TreeService&MaxSide=[^"]+)" width="[^"]+" alt="[^"]+"[^/]+/></a>') do
--        --------------Multiple links possible as results probably - chfoo - help?-------------------
--        table.insert(urls, { url=person_image })
--        for person_image_big in string.gmatch(person_image, "(http://mediasvc%.ancestry%.com/v[^/]+/image/namespaces/[^/]+/media/[^/%.]+%.jpg%?client=TreeService)&MaxSide=[.]+") do
--          table.insert(urls, { url=person_image_big })
--        end
--      end
--    end
--    --example url: http://www.mundia.com/us/Person/743375/6809259973
--    --example url: http://www.mundia.com/us/Person/12748608/-190814136
--    if string.match(url, "%.mundia%.com/[^/]+/Person/[^/]+/[^<>/&]+") then
--      if not html then
--        html = read_file(file)
--      end
--      --example string: href="/pk/Messages?sendMessageTo=0120cac9-0003-0000-0000-000000000000&subject=Joseph%2BSadula%2BAbdula"
--      for adding_user in string.gmatch(html, 'href="(/[^/]+/Messages%?sendMessageTo=[^&]+&subject=[^"]+)"') do
--      end
--    end
  elseif item_type == "genealogy" then
    if string.match(url, "http[s]?://[^%.]+%.genealogy%.com/users/") then
      local genealogybase = string.match(url, "(http[s]?://[^%.]+%.genealogy%.com/)users/")
      local genealogyrest = string.match(url, "http[s]?://[^%.]+%.genealogy%.com/(users/.+)")
      local genealogyurl = genealogybase.."genealogy/"..genealogyrest
      table.insert(urls, { url=genealogyurl })
    elseif string.match(url, "http[s]?://[^%.]+%.genealogy%.com/genealogy/") then
      local genealogybase = string.match(url, "(http[s]?://[^%.]+%.genealogy%.com/)genealogy/")
      local genealogyrest = string.match(url, "http[s]?://[^%.]+%.genealogy%.com/genealogy/(.+)")
      local genealogyurl = genealogybase..genealogyrest
      table.insert(urls, { url=genealogyurl })
    end
    
    if string.match(url, "http[s]?://.+/.+") then
      for genealogybasea in string.gmatch(url, "(http[s]?://.+/)") do
        table.insert(urls, { url=genealogybasea })
      end
      
      for genealogybaseb in string.gmatch(url, "(http[s]?://.+)/") do
        table.insert(urls, { url=genealogybaseb })
      end
    end
  elseif item_type == "familytreemaker" then
    if string.match(url, "http[s]?://familytreemaker%.genealogy%.com/users/") then
      local genealogybase = string.match(url, "(http[s]?://familytreemaker%.genealogy%.com/)users/")
      local genealogyrest = string.match(url, "http[s]?://familytreemaker%.genealogy%.com/(users/.+)")
      local genealogyurl = genealogybase.."genealogy/"..genealogyrest
      table.insert(urls, { url=genealogyurl })
    elseif string.match(url, "http[s]?://familytreemaker%.genealogy%.com/genealogy/") then
      local genealogybase = string.match(url, "(http[s]?://familytreemaker%.genealogy%.com/)genealogy/")
      local genealogyrest = string.match(url, "http[s]?://familytreemaker%.genealogy%.com/genealogy/(.+)")
      local genealogyurl = genealogybase..genealogyrest
      table.insert(urls, { url=genealogyurl })
    end
    
    if string.match(url, "http[s]?://.+/.+") then
      for genealogybasea in string.gmatch(url, "(http[s]?://.+/)") do
        table.insert(urls, { url=genealogybasea })
      end
      
      for genealogybaseb in string.gmatch(url, "(http[s]?://.+)/") do
        table.insert(urls, { url=genealogybaseb })
      end
    end
  elseif item_type == "familyorigins" then
    if string.match(url, "http[s]?://[^%.]+%.familyorigins%.com/users/") then
      local genealogybase = string.match(url, "(http[s]?://[^%.]+%.familyorigins%.com/)users/")
      local genealogyrest = string.match(url, "http[s]?://[^%.]+%.familyorigins%.com/(users/.+)")
      local genealogyurl = genealogybase.."genealogy/"..genealogyrest
      table.insert(urls, { url=genealogyurl })
    elseif string.match(url, "http[s]?://[^%.]+%.familyorigins%.com/genealogy/") then
      local genealogybase = string.match(url, "(http[s]?://[^%.]+%.familyorigins%.com/)genealogy/")
      local genealogyrest = string.match(url, "http[s]?://[^%.]+%.familyorigins%.com/genealogy/(.+)")
      local genealogyurl = genealogybase..genealogyrest
      table.insert(urls, { url=genealogyurl })
    end
    
    if string.match(url, "http[s]?://.+/.+") then
      for genealogybasea in string.gmatch(url, "(http[s]?://.+/)") do
        table.insert(urls, { url=genealogybasea })
      end
      
      for genealogybaseb in string.gmatch(url, "(http[s]?://.+)/") do
        table.insert(urls, { url=genealogybaseb })
      end
    end
  elseif item_type == "genforum" then
    if string.match(url, "http[s]?://genforum%.genealogy%.com/[^/]+/") then
      local genealogyrest = string.match(url, "http[s]?://genforum%.genealogy%.com/([^/]+/.+)")
      local genealogyurl = "http://genforum.com/"..genealogyrest
      table.insert(urls, { url=genealogyurl })
    elseif string.match(url, "http[s]?://genforum%.com/[^/]+/") then
      local genealogyrest = string.match(url, "http[s]?://genforum%.com/([^/]+/.+)")
      local genealogyurl = "http://genforum.genealogy.com/"..genealogyrest
      table.insert(urls, { url=genealogyurl })
    end
    
    if string.match(url, "http[s]?://.+/.+") then
      for genealogybasea in string.gmatch(url, "(http[s]?://.+/)") do
        table.insert(urls, { url=genealogybasea })
      end
      
      for genealogybaseb in string.gmatch(url, "(http[s]?://.+)/") do
        table.insert(urls, { url=genealogybaseb })
      end
    end
  elseif item_type == 'genealogysite' then
    if string.match(url, "http[s]?://[^/]/genealogy/users/.+") then
      local genealogybase = string.match(url, "(http[s]?://[^/]/)genealogy/users/.+")
      local genealogyrest = string.match(url, "http[s]?://[^/]/genealogy/(users/.+)")
      local genealogyurl = genealogybase..genealogyrest
      table.insert(urls, { url=genealogyurl })
    end
    if string.match(url, "http[s]?://[^/]/users/.+") then
      local genealogybase = string.match(url, "(http[s]?://[^/]/)users/.+")
      local genealogyrest = string.match(url, "http[s]?://[^/]/(users/.+)")
      local genealogyurl = genealogybase.."genealogy/"..genealogyrest
      table.insert(urls, { url=genealogyurl })
    end
  elseif item_type == 'myfamily' then
    if string.match(url, "/blog/") then
      html = read_file(file)
      for signinurl in string.gmatch(html, 'SignInUrl:"([^"]+)"') do
        if downloaded[signinurl] ~= true then
          table.insert(urls, { url=signinurl })
        end
      end
      for signupurl in string.gmatch(html, 'SignUpUrl:"([^"]+)"') do
        if downloaded[signupurl] ~= true then
          table.insert(urls, { url=signupurl })
        end
      end
      for avatarurl in string.gmatch(html, 'avatarUrl:"([^"]+)"') do
        if downloaded[avatarurl] ~= true then
          table.insert(urls, { url=avatarurl })
        end
      end
      for searchurl in string.gmatch(html, 'searchUrl:"([^"]+)"') do
        if downloaded["http://www.myfamily.com"..searchurl] ~= true then
          table.insert(urls, { url="http://www.myfamily.com"..searchurl })
        end
      end
      for editurl in string.gmatch(html, 'editUrl:"([^"]+)"') do
        if downloaded["http://www.myfamily.com"..editurl] ~= true then
          table.insert(urls, { url="http://www.myfamily.com"..editurl })
        end
      end
      for uurl in string.gmatch(html, 'url:"([^"]+)"') do
        if downloaded["http://www.myfamily.com"..uurl] ~= true then
         table.insert(urls, { url="http://www.myfamily.com"..uurl })
        end
      end
      for imageurl in string.gmatch(html, 'imageUrl:"([^"]+)"') do
        if downloaded[imageurl] ~= true then
         table.insert(urls, { url=imageurl })
        end
      end
      for videourl in string.gmatch(html, 'videoUrl:"([^"]+)"') do
        if downloaded[videourl] ~= true then
         table.insert(urls, { url=videourl })
        end
      end
      for feedurl in string.gmatch(html, 'feedUrl:"([^"]+)') do
        if downloaded[feedurl] ~= true then
          table.insert(urls, { url=feedurl })
        end
      end
      for followsurl in string.gmatch(html, 'followsUrl:"([^"]+)"') do
        if downloaded["http://www.myfamily.com"..followsurl] ~= true then
          table.insert(urls, { url="http://www.myfamily.com"..followsurl })
        end
      end
      if string.match(url, "http[s]?://[^/]+/blog/[0-9]+%?start=[0-9]+") then
        if string.match(html, "editUrl:") then
          local page = string.match(url, "http[s]?://[^/]+/blog/[0-9]+%?start=([0-9]+)")
          local nextpage = page + 1
          local base = string.match(url, "(http[s]?://[^/]+/blog/[0-9]+%?start=)[0-9]+")
          table.insert(urls, { url=base..nextpage })
        end
      end
    end
  end
  
  return urls
end
  

wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  local status_code = http_stat["statcode"]
  
  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. ".  \n")
  io.stdout:flush()
  
  if (status_code >= 200 and status_code <= 399) or status_code == 403 then
    downloaded[url.url] = true
  end
  
  if status_code >= 500 or
    (status_code >= 400 and status_code ~= 404 and status_code ~= 403) then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 10")

    tries = tries + 1

    if tries >= 20 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  elseif status_code == 0 then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 10")

    tries = tries + 1

    if tries >= 100 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  else
    return wget.actions.NOTHING
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)

  --  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
  --    -- We should be able to go fast on images since that's what a web browser does
  --    sleep_time = 0
  --  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end

dofile("urlcode.lua")
dofile("table_show.lua")
JSON = (loadfile "JSON.lua")()

local url_count = 0
local tries = 0

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

-- wget.callbacks.download_child_p = function(urlpos, parent, depth, start_url_parsed, iri, verdict, reason)
--   local url = urlpos["url"]["url"]
--   
--   -- Don't download the favicon over and over again
--   if url == "http://wallbase.cc/fav.gif" then
--     return false
--   
--   else
--     return verdict
--   end
-- end

wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}
  local html = nil
  local mundia_url = "http://www.mundia.com"
  
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
  
  --example url: http://www.mundia.com/pk/Search/Results?surname=ABDULA&birthPlace=Verenigde%20Staten
  if string.match(url, "%.mundia%.com/[^/]+/Search/Results?surname=[^/&]+%&birthPlace=[^<>/&]+") then
    if not html then
      html = read_file(file)
    end
    
    --example string: <a href="/pk/Person/5586782/-1432906874" class="">Joseph Sadula Abdula</a>
    for person_url in string.gmatch(html, '<a href="(/[^/]+/Person/[^/]/[^/"& ]+)" class="">[^<>/]+</a>') do
      --------------Multiple links possible as results probably - chfoo - help?-------------------
      table.insert(urls, { url=mundia_url..person_url })
    end
    
    --example string: <a class="tree" href="/pk/Tree/Family/5586782/-1432906874"><span class="view-tree">Stamboom tonen</span></a>
    for tree_url in string.gmatch(html, '<a class="[^"/<>]+" href="(/[^/]+/Tree/Family/[^/]/[^<>/]+)"><span class="view-tree">[^<>/]+</span></a>') do
      --------------Multiple links possible as results probably - chfoo - help?-------------------
      table.insert(urls, { url=mundia_url..tree_url })
    end
    
    --example string: <img src="http://mediasvc.ancestry.com/v2/image/namespaces/1093/media/11f96e77-c39c-4ca4-b659-32f67aa8d129.jpg?client=TreeService&MaxSide=96" width="68" alt="Foto" /></a>
    for person_image in string.gmatch(html, '<img src="(http://mediasvc%.ancestry%.com/v[^/]+/image/namespaces/[^/]+/media/[^/%.]+%.jpg%?client=TreeService&MaxSide=[^"]+)" width="[^"]+" alt="[^"]+" /></a>') do
      --------------Multiple links possible as results probably - chfoo - help?-------------------
      table.insert(urls, { url=person_image })
      for person_image_big in string.gmatch(person_image, "(http://mediasvc%.ancestry%.com/v[^/]+/image/namespaces/[^/]+/media/[^/%.]+%.jpg%?client=TreeService)&MaxSide=[.]+") do
        table.insert(urls, { url=person_image_big })
      end
    end
  end
  
  --example url: http://www.mundia.com/us/Person/743375/6809259973
  --example url: http://www.mundia.com/us/Person/12748608/-190814136
  if string.match(url, "%.mundia%.com/[^/]+/Person/[^/]+/[^<>/&]+") then
    if not html then
      html = read_file(file)
    end
    
    --example string: href="/pk/Messages?sendMessageTo=0120cac9-0003-0000-0000-000000000000&subject=Joseph%2BSadula%2BAbdula"
    for adding_user in string.gmatch(html, 'href="(/[^/]+/Messages%?sendMessageTo=[^&]+&subject=[^"]+)"') do
    end
    
  end
  
end
  

wget.callbacks.httploop_result = function(url, err, http_stat)
  -- NEW for 2014: Slightly more verbose messages because people keep
  -- complaining that it's not moving or not working
  local status_code = http_stat["statcode"]
  
  url_count = url_count + 1
  io.stdout:write(url_count .. "=" .. status_code .. " " .. url["url"] .. ".  \r")
  io.stdout:flush()
  
  if status_code >= 500 or
    (status_code >= 400 and status_code ~= 404 and status_code ~= 403) then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 10")

    tries = tries + 1

    if tries >= 5 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  elseif status_code == 0 then
    return wget.actions.ABORT
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

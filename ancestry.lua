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

downloaded["http://c.muncn.com/images/ico/facebook.gif"] = true
downloaded["http://ecn.dev.virtualearth.net/mapcontrol/mapcontrol.ashx?v=6.2&mkt=en-US"] = true
downloaded["http://c.muncn.com/scripts/merged/shared/mapservercontrol.js"] = true
downloaded["http://c.muncn.com/scripts/merged/surname/index.js"] = true
downloaded["http://c.muncn.com/style/contacts/facebookfriendpicker.css"] = true
downloaded["http://c.muncn.com/scripts/merged/contacts/facebookfriendpicker.js"] = true
downloaded["http://c.muncn.com/style/surname/index.css"] = true
downloaded["http://c.muncn.com/scripts/merged/shared/core.js"] = true
downloaded["http://c.muncn.com/scripts/mbox.js"] = true
downloaded["http://c.muncn.com/style/lt7.css"] = true
downloaded["http://c.muncn.com/style/shared/_RolesHintControl.css"] = true
downloaded["http://c.muncn.com/style/form.css"] = true
downloaded["http://c.muncn.com/style/site.css"] = true
downloaded["http://c.muncn.com/images/errors/error_ico.png"] = true
downloaded["http://c.muncn.com/images/circle_green_clockwise.gif"] = true
downloaded["http://c.muncn.com/scripts/merged/search/results.js"] = true
downloaded["http://c.muncn.com/style/search/resultselection.css"] = true
downloaded["http://c.muncn.com/style/search/results.css"] = true
downloaded["http://ecn.dev.virtualearth.net/mapcontrol/v6.3"] = true
downloaded["http://ecn.dev.virtualearth.net/mapcontrol/v6.3/"] = true
downloaded["http://www.mundia.com/images/circle_green_clockwise.gif"] = true
downloaded["http://c.muncn.com/images/tree-create-bg.png"] = true
downloaded["http://www.mundia.com/images/btn-sub-right.png"] = true
downloaded["http://www.mundia.com/images/btn-sub-left.png"] = true
downloaded["http://www.mundia.com/images/photoimport/fblogo.gif"] = true
downloaded["http://www.mundia.com/images/fotolog-full-logo.png"] = true
downloaded["http://www.mundia.com/images/photoimport/checkbox.png"] = true
downloaded["http://www.mundia.com/images/photoimport/main-photo-image-selected.png"] = true
downloaded["http://www.mundia.com/images/bg-main-info-image.gif"] = true
downloaded["http://c.muncn.com/images/ico/lessThanAvg.png"] = true
downloaded["http://c.muncn.com/images/personicon-f.gif"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/circle_green_clockwise.gif"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/btn-sub-right.png"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/btn-sub-left.png"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/photoimport/fblogo.gif"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/fotolog-full-logo.png"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/photoimport/checkbox.png"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/photoimport/main-photo-image-selected.png"] = true
downloaded["http://www.mundia.com/Error?aspxerrorpath=/ar/images/bg-main-info-image.gif"] = true
downloaded["http://c.muncn.com/scripts/merged/shared/fancyupload.js"] = true
downloaded["http://c.muncn.com/scripts/merged/person/index.js"] = true
downloaded["http://c.muncn.com/scripts/merged/media/bulkeditdialog.js"] = true
downloaded["http://c.muncn.com/images/pedigree-loading.gif"] = true
downloaded["http://c.muncn.com/images/profilepic_female.gif"] = true
downloaded["http://c.muncn.com/images/white.gif"] = true
downloaded["http://c.muncn.com/images/ico/invite.png"] = true
downloaded["http://c.muncn.com/style/media/bulkedit.css"] = true
downloaded["http://c.muncn.com/style/fancyupload/fancyupload.css"] = true
downloaded["http://c.muncn.com/style/contacts/import.css"] = true
downloaded["http://c.muncn.com/style/invitation/invite.css"] = true
downloaded["http://c.muncn.com/style/contactuser.css"] = true
downloaded["http://c.muncn.com/style/gallery/index.css"] = true
downloaded["http://c.muncn.com/style/tree/editperson.css"] = true
downloaded["http://c.muncn.com/style/person/index.css"] = true
downloaded["http://c.muncn.com/images/personicon-m.gif"] = true
downloaded["http://c.muncn.com/images/profilepic_male.gif"] = true
downloaded["http://c.muncn.com/style/person/restricted.css"] = true
downloaded["http://c.muncn.com/images/ico/greaterThanAvg.png"] = true

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
  
  if item_type == "genforum" then
    if string.match(url, "[^0-9a-zA-Z]"..item_value.."[^0-9a-zA-Z]") then
      return true
    else
      return false
    end
  end
  
end


wget.callbacks.get_urls = function(file, url, is_css, iri)
  local urls = {}
  local html = nil
  
  if item_type == "genforum" then
    if string.match(url, "http[s]?://genforum%.genealogy%.com/") then
      local newurl = string.gsub(url, "http[s]?://genforum%.genealogy%.com/", "http[s]?://genforum%.com/")
      if downloaded[newurl] ~= true then
        table.insert(urls, { url=newurl })
      end
    end
    if string.match(url, "http[s]?://genforum%.com/") then
      local newurl = string.gsub(url, "http[s]?://genforum%.com/", "http[s]?://genforum%.genealogy%.com/")
      if downloaded[newurl] ~= true then
        table.insert(urls, { url=newurl })
      end
    end
    
    if string.match(url, "[^0-9a-zA-Z]"..item_value.."[^0-9a-zA-Z]") then
      html = read_file(html)
      
      for customurl in string.gmatch(html, '"(http[s]?://[^"]+)"') do
        if string.match(customurl, "[^0-9a-zA-Z]"..item_value.."[^0-9a-zA-Z]") then
          if downloaded[customurl] ~= true then
            table.insert(urls, { url=customurl })
          end
        end
      end
      for customurlnf in string.gmatch(html, '"(/[^"]+)"') do
        if string.match(customurlnf, "[^0-9a-zA-Z]"..item_value.."[^0-9a-zA-Z]") then
          if string.match(url, "http[s]?://genforum%.genealogy%.com/") then
            local base = "http://genforum.genealogy.com"
          elseif string.match(url, "http[s]?://genforum%.com/") then
            local base = "http://genforum.com/"
          end
          if base then
            local customurl = base..customurlnf
            if downloaded[customurl] ~= true then
              table.insert(urls, { url=customurl })
            end
          end
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
    if string.match(url.url, "https://") then
      local newurl = string.gsub(url.url, "https://", "http://")
      downloaded[newurl] = true
    else
      downloaded[url.url] = true
    end
  end
  
  if status_code >= 500 or
    (status_code >= 400 and status_code ~= 404 and status_code ~= 403) then
    io.stdout:write("\nServer returned "..http_stat.statcode..". Sleeping.\n")
    io.stdout:flush()

    os.execute("sleep 1")

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

    if tries >= 10 then
      io.stdout:write("\nI give up...\n")
      io.stdout:flush()
      return wget.actions.ABORT
    else
      return wget.actions.CONTINUE
    end
  end

  tries = 0

  -- We're okay; sleep a bit (if we have to) and continue
  -- local sleep_time = 0.1 * (math.random(75, 1000) / 100.0)
  local sleep_time = 0

  --  if string.match(url["host"], "cdn") or string.match(url["host"], "media") then
  --    -- We should be able to go fast on images since that's what a web browser does
  --    sleep_time = 0
  --  end

  if sleep_time > 0.001 then
    os.execute("sleep " .. sleep_time)
  end

  return wget.actions.NOTHING
end

dofile("urlcode.lua")
dofile("table_show.lua")
JSON = (loadfile "JSON.lua")()

local url_count = 0
local tries = 0
local item_type = os.getenv('item_type')
local item_value = os.getenv('item_value')

local downloaded = {}
local addedtolist = {}

downloaded["http://genforum.genealogy.com/javascript/TSpacer_wrapper.js"] = true

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
  
  if downloaded[url] == true
    or addedtolist[url] == true then
    return false
  end
  
  if (item_type == "genforum" and (downloaded[url] ~= true or addedtolist[url] ~= true)) then
    if (string.match(url, "%?"..item_value)
      or string.match(url, "="..item_value)
      or string.match(url, "%."..item_value)
      or string.match(url, "/"..item_value)
      or string.match(url, "/3/")
      or string.match(url, "/images/") 
      or string.match(url, "/javascript/") 
      or string.match(url, "gco%.[0-9]+%.[0-9a-zA-Z]+%.net") 
      or string.match(url, "email%.cgi") 
      or string.match(url, "picture%.cgi") 
      or string.match(url, "%.jpg")
      or string.match(url, "%.gif")
      or string.match(url, "%.png")
      or string.match(url, "%.jpeg") 
      or string.match(url, "%.css")
      or string.match(url, "%.js")
      or html == 0 
      or string.match(url, "service%.ancestry%.com")) then
      return true
      addedtolist[url] = true
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
      local newurl = string.gsub(url, "http[s]?://genforum%.genealogy%.com/", "http://genforum%.com/")
      if (downloaded[newurl] ~= true and addedtolist[newurl] ~= true) then
        table.insert(urls, { url=newurl })
        addedtolist[newurl] = true
      end
    end
    if string.match(url, "http[s]?://genforum%.com/") then
      local newurl = string.gsub(url, "http[s]?://genforum%.com/", "http://genforum%.genealogy%.com/")
      if (downloaded[newurl] ~= true and addedtolist[newurl] ~= true) then
        table.insert(urls, { url=newurl })
        addedtolist[newurl] = true
      end
    end
    
    if string.match(url, item_value) then
      html = read_file(html)
      
      for customurl in string.gmatch(html, '"(http[s]?://[^"]+)"') do
        if string.match(customurl, "%?"..item_value)
          or string.match(customurl, "="..item_value)
          or string.match(customurl, "%."..item_value)
          or string.match(customurl, "/"..item_value)
          or string.match(customurl, "/3/")
          or string.match(customurl, "/images/") 
          or string.match(customurl, "/javascript/") 
          or string.match(customurl, "gco%.[0-9]+%.[0-9a-zA-Z]+%.net") 
          or string.match(customurl, "email%.cgi") 
          or string.match(customurl, "picture%.cgi") 
          or string.match(customurl, "%.jpg")
          or string.match(customurl, "%.gif")
          or string.match(customurl, "%.png")
          or string.match(customurl, "%.jpeg") 
          or string.match(customurl, "%.css")
          or string.match(customurl, "%.js")
          or string.match(customurl, "service%.ancestry%.com") then
          if (string.match(url, ":::") and string.match(customurl, ":::") and not string.match(html, '<FONT FACE="[^"]+"><B><A HREF="[^"]+">[^<]+</A>[^<]+<A HREF="[^>]+">[^<]+</A></B></FONT><BR>[^<]+<UL>[^<]+</UL>[^<]+<font face="[^"]+"><B><A HREF="[^"]+">[^<]+</A>[^<]+<A HREF="[^"]+">[^<]+</A></B></font><BR>')) 
            or not string.match(url, ":::") then
            if (downloaded[customurl] ~= true and addedtolist[customurl] ~= true) then
              table.insert(urls, { url=customurl })
              addedtolist[customurl] = true
            end
          end
        end
      end
      for customurlnf in string.gmatch(html, '"(/[^"]+)"') do
        if string.match(customurlnf, "%?"..item_value)
          or string.match(customurlnf, "="..item_value)
          or string.match(customurlnf, "%."..item_value)
          or string.match(customurlnf, "/"..item_value)
          or string.match(customurlnf, "/3/")
          or string.match(customurlnf, "/images/") 
          or string.match(customurlnf, "/javascript/")
          or string.match(customurlnf, "email%.cgi") 
          or string.match(customurlnf, "picture%.cgi") 
          or string.match(customurlnf, "%.jpg")
          or string.match(customurlnf, "%.gif")
          or string.match(customurlnf, "%.png")
          or string.match(customurlnf, "%.jpeg") 
          or string.match(customurlnf, "%.css")
          or string.match(customurlnf, "%.js") then
          local base = string.match(url, "(http[s]?://[^/]+)")
          local customurl = base..customurlnf
          if (string.match(url, ":::") and string.match(customurl, ":::") and not string.match(html, '<FONT FACE="[^"]+"><B><A HREF="[^"]+">[^<]+</A>[^<]+<A HREF="[^>]+">[^<]+</A></B></FONT><BR>[^<]+<UL>[^<]+</UL>[^<]+<font face="[^"]+"><B><A HREF="[^"]+">[^<]+</A>[^<]+<A HREF="[^"]+">[^<]+</A></B></font><BR>')) 
            or not string.match(url, ":::") then
            if (downloaded[customurl] ~= true and addedtolist[customurl] ~= true) then
              table.insert(urls, { url=customurl })
              addedtolist[customurl] = true
            end
          end
        end
      end
      for customurlnf in string.gmatch(html, '="([^"]+)"') do
        local base = string.match(url, "(http[s]?://.+/)")
        local customurl = base..customurlnf
        if (string.match(url, ":::") and string.match(customurl, ":::") and not string.match(html, '<FONT FACE="[^"]+"><B><A HREF="[^"]+">[^<]+</A>[^<]+<A HREF="[^>]+">[^<]+</A></B></FONT><BR>[^<]+<UL>[^<]+</UL>[^<]+<font face="[^"]+"><B><A HREF="[^"]+">[^<]+</A>[^<]+<A HREF="[^"]+">[^<]+</A></B></font><BR>')) 
          or not string.match(url, ":::") then
          if (downloaded[customurl] ~= true and addedtolist[customurl] ~= true) then
            table.insert(urls, { url=customurl })
            addedtolist[customurl] = true
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
    downloaded[url["url"]] = true
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

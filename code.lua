local network = require("network")
local json = require("json")
local lfs = require("lfs")

local firebase_url = "https://kritireg-default-rtdb.firebaseio.com/"

local id = system.getInfo( "deviceID" )
local VERSION = "0.05"

local gms_list = {}

function len( t )
 
    local len = 0
    for _,_ in pairs( t ) do
        len = len + 1
    end
 
    return len
end



function SortDowns(a, b)
    if len(a) > 1 and len(b) > 1 then
        return len(a.downloads) > len(b.downloads)
    else
        return nil
    end
end

display.newRect(0,0,10000,10000):setFillColor(0.1,0.1,0.1)

local scr = display.newGroup()
local gms = display.newGroup()
local inf = display.newGroup()
local prf = display.newGroup()
local oth_gms = display.newGroup()
local tags_group = display.newGroup()
local oth = display.newGroup()
local move_oth = display.newGroup()

local allow_games = false
local allow_loaded = true
local allow_downloads_loaded = false
local allow1 = true

local dw = display.newText("",display.contentCenterX,display.contentHeight-250)
local nm = ""
local y_velocity = 0


local function post(data, pr)

  local data_json = json.encode(data)
  local headers = {
  ["Content-Type"] = "application/json",
  ["Content-Length"] = data_json
  }
  local options = {
  body = data_json,
  headers = headers
  }
  network.request(firebase_url..pr..".json", "PUT", function(event)
  end, options)
end

local function get(pr,callback)
  network.request(pr, "GET", function(event)
  local response = event.response
  callback(response)
  end)
end


get(
    "https://kritireg-default-rtdb.firebaseio.com/games.json",
    function(event)
        gms_list = event
    end)

local function clear_group(group)
    while group.numChildren > 0 do
        local object = group[1]
        object:removeSelf()
    end
end

local moderator = false
local developer = {
    value=false,
    username="пусто"
}

local info_app = ""
local users = {}

get("https://kritireg-default-rtdb.firebaseio.com/information.json", function(event)
    local full = ""
    for i=0, #event do
        if string.sub(event,i,i) == "|" then
            full = full.."\n"
        elseif string.sub(event,i,i) ~= "\"" then
            full = full..string.sub(event,i,i)
        end

    info_app = full
end
end)
local function opn_game(game)

    clear_group(oth_gms)
    clear_group(inf)
    clear_group(tags_group)
    display.remove(serch)
    allow1 = false
    allow_loaded = false


    event = gms_list


            event = json.decode(event)
            if len(event[game]) < 3 then
                game = game + 1
                print(game)
            end

            allow_downloads_loaded = true


            clear_group(gms)
            clear_group(scr)

            local transistor = "Неизвестный переходник"

            local url_razd = event[game]["url"]:gmatch("([^%.]+)")
            for i in url_razd do
                if i == "yandex" then
                    transistor = "Яндекс диск"
                elseif i == "google" then
                    transistor = "Гугл диск"
                end
            end
            local dad_event = event
            for i in pairs(event) do

                if moderator then

                    local transit = display.newText(transistor,display.screenOriginX+80,display.contentHeight/2.4)
                    inf:insert(transit)

                    local heght = display.newText("Вес",display.screenOriginX+80,display.contentHeight/2.2)
                    if event[game]["ves"] then
                        heght.text = "Вес: " .. event[game]["ves"] .. " МБ"
                    else
                        heght.text = "Вес ??? "
                    end

                    inf:insert(heght)

                    local text_input = native.newTextField(display.contentCenterX+50,display.screenOriginY+250,130,30)
                    text_input.placeholder = "Новое название"
                    local short_input = native.newTextField(display.contentCenterX+50,display.screenOriginY+280,130,30)
                    short_input.placeholder = "Новое короткое название"

                    local save_btn = display.newRoundedRect(display.contentCenterX,display.contentHeight*1.15,200,50,10)
                    save_btn:setFillColor(0.5,0,0)
                    save_btn:addEventListener("touch", function(event2)
                        if event2.phase == "began" then
                            if text_input.text then
                                event[game]["full_name"] = text_input.text
                            end
                            if short_input.text then
                                event[game]["name"] = short_input.text
                            end
                        end
                        post(event, "games")
                    end)

                    local save_text = display.newText("Сохранить",display.contentCenterX,display.contentHeight*1.15)
                    save_text:setFillColor(1,0,0)

                    inf:insert(save_btn)
                    inf:insert(save_text)
                    inf:insert(text_input)
                    inf:insert(short_input)


                end


                local fulname = display.newText(event[game]["full_name"],display.contentCenterX+50,display.screenOriginY+200)
                fulname.size =  (display.contentHeight+display.contentWidth)/65
                inf:insert(fulname)

                if event[game]["owner"] then
                    local owner = display.newText("Owner: "..event[game]["owner"],display.screenOriginX+80,display.contentHeight/3)
                    owner.size = (display.contentHeight+display.contentWidth)/65
                    inf:insert(owner)
                end


                display.loadRemoteImage(event[game]["icon"], "GET", function (event)
                    clear_group(oth)
                    local img = event.target
                    inf:insert(img)
                    img.width = 100
                    img.height = 100
                    img.y = display.contentHeight/5
                    img.x = display.screenOriginX+80


                    if not allow_downloads_loaded then
                        display.remove(img)
                    end
                end, 
                "image.png", system.TemporaryDirectory
                )
            end



                 local download_btn = display.newRoundedRect(display.contentCenterX,display.contentHeight-100,180,80,20)
                 local down_text = display.newText("СКАЧАТЬ",display.contentCenterX,display.contentHeight-100)
                 down_text:setFillColor(0,0,0)
                 inf:insert(download_btn)
                inf:insert(down_text)
                
                local dwns = display.newText("Скачали " .. len(dad_event[game]["downloads"])-1 .. " человек",display.contentCenterX,display.contentHeight-180)
                inf:insert(dwns)

                local y_tags = display.contentCenterY-50

                local stroke_tags = display.newRoundedRect(display.contentWidth/1.2,y_tags+50,100,100,10)
                stroke_tags:setFillColor(0,0,0,0.5)

                tags_group = display.newGroup()

                inf:insert(stroke_tags)

                local oldy_tgs = 0

                stroke_tags:addEventListener("touch", function(event)
                    if event.phase == "began" then
                        oldy_tgs = event.y
                    elseif event.phase == "moved" then
                        tags_group.y = tags_group.x+(oldy_tgs-event.y)
                    end
            end)
                local tgs = display.newText("Хештеги\n\n",display.contentWidth/1.2,y_tags)
                inf:insert(tgs)
                tags_group:insert(tgs)
                y_tags = y_tags + 15
                tgs:setFillColor(0.8)

                if event[game]["tegs"] then
                    for i in pairs(event[game]["tegs"]) do
                        if i then
                            local tgs = display.newText(i,display.contentWidth/1.2,y_tags)
                            inf:insert(tgs)
                            tags_group:insert(tgs)
                            y_tags = y_tags + 15
                            tgs:setFillColor(0.8)

                            if not allow_downloads_loaded then

                                display.remove(tgs)
                            end

                        end
                    end
                else
                    tags = "Хештегов нет"
                end

                download_btn:addEventListener("touch",function(event)
                    if event.phase == "ended" then
                       system.openURL(dad_event[game]["url"])
                       dw = display.newText("Пожалуйста, перейдите по ссылке",display.contentCenterX,display.contentHeight-200)
                        dad_event[game]["downloads"][id] = 0
                        post(dad_event,"games")
                   end

           end)

                local exit_btn = display.newRoundedRect(display.contentCenterX,display.actualContentWidth*1.5,150,50,10)
                local exit_text = display.newText("Вернутся в каталог",display.contentCenterX,display.actualContentWidth*1.5)
                inf:insert(exit_btn)
                inf:insert(exit_text)
                exit_text:setFillColor(0)
                exit_btn:addEventListener("touch", function(event)
                    if allow_games == true then
                        allow_games = false
                        clear_group(gms)
                        clear_group(inf)
                        update_games()
                        dw.text = ""
                        clear_group(tags_group)
                    end
            end)
end


local function sortTop(event)

    allow_downloads_loaded = true
    allow_loaded = false
    allow1 = true


    clear_group(gms)
    clear_group(inf)
    clear_group(prf)

    local y = 30
    ys = {}

    if len(event) > 1 then
        table.sort(event, SortDowns)
        for i,game in ipairs(event) do

            ys[game] = y+70
            y = y + 70


            if game["icon"] then
                local game = display.loadRemoteImage(game.icon, "GET", function(event)
                    clear_group(gms)
                    local dwns_text = display.newText(len(game.downloads) .. " Загрузок", display.contentWidth/1.15, ys[game])
                    local name_text = display.newText(game.name, display.contentWidth/2, ys[game])
                    local img = event.target
                    img.y = ys[game]
                    img.x = display.contentWidth/5
                    img.width = 50
                    img.height = 50
                    img.name = i


                    move_oth:insert(dwns_text)
                    move_oth:insert(name_text)
                    move_oth:insert(img)

                    if allow_downloads_loaded and allow1 then
                        img:addEventListener("touch", function(event)
                            if event.phase == "began" then
                                clear_group(inf)
                                clear_group(move_oth)
                                opn_game(img.name)
                            end
                        end)
                    end

                    if not allow_downloads_loaded or not allow1 then
                        display.remove(img)
                        display.remove(name_text)
                        display.remove(dwns_text)
                    end

                end, "image.png"..i, TemporaryDirectory)
            else
                y = y - 70
            end
        end
    end

    local exit_btn = display.newRoundedRect(display.contentCenterX,display.actualContentWidth*1.3,150,50,10)
    local exit_text = display.newText("Вернутся в каталог",display.contentCenterX,display.actualContentWidth*1.3)
    oth:insert(exit_btn)
    oth:insert(exit_text)
    exit_text:setFillColor(0)
    exit_btn:addEventListener("touch", function(event)
        if allow_games == true then
            allow_games = false
            clear_group(gms)
            clear_group(inf)
            clear_group(oth)
            update_games()
            dw.text = ""
            clear_group(move_oth)
        end
    end)

end

local function profile()

    allow_loaded = false

    local function information()

        clear_group(gms)
        clear_group(inf)

        local exit = display.newRoundedRect(30,30,50,50,10)
        local exit_text = display.newText("Выйти",30,30)
        exit:setFillColor(0.3,0.3,1)
        move_oth:insert(exit)
        move_oth:insert(exit_text)
        exit:addEventListener("touch", function(event)
            clear_group(inf)
            profile()
        end)

            local inform = display.newText(info_app,display.contentWidth/1.8, display.contentCenterY,250,0)
            move_oth:insert(inform)

            y = 0
            print(#info_app)

            for i=0,#info_app/120 do
                y = y + 50
            end

            local dwns_text = display.newText("Количество скачиваний: "..len(users), display.contentWidth/3, y)
            move_oth:insert(dwns_text)


    end

    local profile_btn = display.newImage("images/profile.png",display.contentCenterX,display.contentHeight-10)
    profile_btn.width, profile_btn.height = 50, 50
    profile_btn:addEventListener("touch",function(event)
        if event.phase == "began" then
                clear_group(gms)
                update_games()
                clear_group(prf)
                display.remove(profile_btn)
                profile_btn = nil

        end
    end)

    clear_group(scr)
    clear_group(move_oth)
    clear_group(gms)

    in_profile = true

    local bg = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight*2)
    bg:setFillColor(0.2,0.2,0.6)
    prf:insert(bg)

    local userid = display.newText("ID: "..id, display.contentCenterX, display.contentCenterY*1.05)
    local user_main_id = display.newText("Main ID: "..string.sub(id,1,3), display.contentCenterX, display.contentCenterY*1.1)

    local userstatus = display.newText("Статус: Гость", display.contentCenterX, display.contentCenterY/1.2)

    prf:insert(userid)
    prf:insert(user_main_id)
    prf:insert(userstatus)

    if moderator then
        userstatus.text = "Статус: Модератор"
        userstatus:setFillColor(0.5,0.5,1)
    end
    if developer["value"] then
        userstatus.text = "Статус: Разработчик\n".."Студия: "..developer["username"]
        userstatus:setFillColor(0.3,1,0.3)
    end

    local url1 = display.newText("ТГК сефера", display.contentCenterX,display.contentHeight/1.15)
    url1.size = display.contentWidth/30
    url1:setFillColor(0.5,0.5,1)
    url1:addEventListener("touch", function(event)
        if event.phase == "began" then
            system.openURL("https://t.me/+PnX1GdAq6f1lNzQy")
        end
    end)

    local url2 = display.newText("ТГК kouto (Разработчика)", display.contentCenterX,display.contentHeight/1.1)
    url2.size = display.contentWidth/30
    url2:setFillColor(0.5,0.5,1)
    url2:addEventListener("touch", function(event)
        if event.phase == "began" then
            system.openURL("https://t.me/sqgtems")
        end
    end)
    prf:insert(url1)
    prf:insert(url2)
    prf:insert(profile_btn)


    local info_btn = display.newRoundedRect(display.contentCenterX,display.contentHeight/4,100,50,10)
    prf:insert(info_btn)
    info_btn:setFillColor(0.2,0.2,0.4)
    local info_text = display.newText("Информация", display.contentCenterX, display.contentHeight/4)
    prf:insert(info_text)
    info_btn:addEventListener("touch", function (event)
        if event.phase == "began" then
            clear_group(prf)
            information()
            clear_group(gms)
        end
    end)

end


function search(tag)
    allow_loaded = false
    allow_downloads_loaded = false
    clear_group(scr)
    clear_group(oth)
    clear_group(move_oth)
    event = gms_list
        event = json.decode(event)
        local dad_event = event

        local y = 100
        local tag_find = false
        local completes = 0

        for i in pairs(event) do
            if event[i]["tegs"] then
                for i2 in pairs(event[i]["tegs"]) do
                    if i2 == tag then
                        tag_find = true
                    end
                end
            end
                if tag_find or event[i]["name"] == tag or event[i]["full_name"] == tag then
                    completes = completes + 1
                    tag_find = false
                    clear_group(gms)
                    display.loadRemoteImage(event[i]["icon"], "GET", function(event)
                        local img = event.target
                        img.y = y
                        img.x = 50
                        img.width = 50
                        img.height = 50
                        img.name = i
                        scr:insert(img)
                        local text = display.newText(dad_event[i]["full_name"], img.x+150, y)
                        scr:insert(text)
                        y = y + 80
                        
                        img:addEventListener("touch", function(event)
                            if event.phase == "began" then
                                opn_game(img.name)
                            end
                        end)

                    end,"image.png"..i, system.TemporaryDirectory)
                end
        end

    if completes < 1 then
        local result = display.newText("Результатов не найдено",display.contentCenterX, display.contentCenterY)
        inf:insert(result)
    end

end



update_games = function()

    allow_downloads_loaded = false
    allow_loaded = true
    gms.isVisible = true

    clear_group(scr)
    clear_group(inf)
    clear_group(oth)

    event = gms_list

            allow_loaded = true
            allow_downloads_loaded = false

            local profile_btn = display.newImage("images/profile.png",30,display.screenOriginY+40)
            oth_gms:insert(profile_btn)
            profile_btn.width, profile_btn.height = 40, 40
            profile_btn:addEventListener("touch",function(event)
                if event.phase == "began" then
                        profile()
                        display.remove(profile_btn)
                        profile_btn = nil

                end
            end)

            allow_games = true
            local x = 80
            local y = 300
            event = json.decode(event)
            local dad_event = event

            local serch = native.newTextField( display.contentWidth/1.7, display.safeScreenOriginY+30, 250,40 )
            serch.placeholder = "Поиск"
            serch.size = 15

            local bal = display.contentWidth+display.contentHeight
            local top_src_btn = display.newRoundedRect(display.contentWidth/4, display.contentHeight/4.3, bal/9, bal/20, 9)
            local top_scr_text = display.newText("Скачивания", display.contentWidth/4, display.contentHeight/4.3)
            top_scr_text:setFillColor(0)
            gms:insert(top_src_btn)
            gms:insert(top_scr_text)

            top_src_btn:addEventListener("touch", function(event)
                if event.phase == "began" then
                    sortTop(dad_event)
                end
        end)

            serch:addEventListener( "userInput", function( event )
                if event.phase == "submitted" then
                    search(serch.text)
                    print(serch.text)
                    clear_group(inf)
                    clear_group(gms)
                    local exit_btn = display.newRoundedRect(display.contentCenterX,display.actualContentWidth*1.3,150,50,10)
                    local exit_text = display.newText("Вернутся в каталог",display.contentCenterX,display.actualContentWidth*1.3)
                    oth:insert(exit_btn)
                    oth:insert(exit_text)
                    exit_text:setFillColor(0)
                    exit_btn:addEventListener("touch", function(event)
                        if allow_games == true then
                            allow_games = false
                            inf.isVisible = false
                            clear_group(gms)
                            clear_group(inf)
                            update_games()
                            dw.text = ""
                        end
                end)
                    end
            end )

            local dad_event = event
            for i in pairs(event) do
                if event[i]["icon"] and dad_event[i]["name"] ~= nil then
                    local img
                    if event[i]["url"] and event[i]["icon"] and dad_event[i]["name"] ~= nil then
                        display.loadRemoteImage(event[i]["icon"], "GET", function (event)
                            if x > display.contentWidth/1.2 then
                                y = y + 100
                                x = 80
                            end

                            img = event.target

                            if dad_event[i]["name"] ~= nil then
                                img.name = i
                                img.width = 50
                                img.height = 50
                                img.y = y
                                img.x = x
                                local stroke = display.newRoundedRect(x,y+45,70,30,15)
                                gms:insert(stroke)
                                local text = display.newText(dad_event[i]["name"], x+3, y+45, 50,0)
                                text:setFillColor(0)
                                gms:insert(text)
                                text.size = 10
                                x = x + 70
                                if img then
                                    gms:insert(img)
                                end
                                img:addEventListener("touch", function(event)
                                    if event.phase == "began" then
                                        opn_game(img.name)
                                    end
                                end)
                            end


                                if not allow_loaded or dad_event[i]["name"] == nil then
                                    display.remove(img)
                                    display.remove(stroke)
                                    display.remove(text)
                                end


                        end, 
                        "image.png"..i, system.TemporaryDirectory
                        )
                    end
                end
            end

            get("https://kritireg-default-rtdb.firebaseio.com/banner.json", function(event)
                
                local full = ""
                for i=0, #event do
                    if string.sub(event,i,i) ~= "\"" then
                        full = full..string.sub(event,i,i)
                    end
                end

                display.loadRemoteImage(full, "GET", function(event)
                    
                    local img = event.target
                    img.x = display.contentWidth/4
                    img.y = display.contentHeight/20
                    gms:insert(img)
                    img.width = display.contentWidth/2
                    img.height = display.contentHeight/4


                    if not allow_loaded then
                        display.remove(img)
                        gms.remove(img)
                    end

            end, "image.png".."banner", system.TemporaryDirectory)
            end)

    local title1_stroke = display.newRect(display.contentCenterX,display.contentHeight/3,500,50)
    local title1 = display.newText("Каталог приложений",120,display.contentHeight/3)
    title1_stroke:setFillColor(0.1,0.1,0.3)
    title1.size = 20
    gms:insert(title1_stroke)
    gms:insert(title1)

        end

local function list(event)
    if event.phase == "ended" then
        print("suc")
    end
end


local limit = 0
get("https://kritireg-default-rtdb.firebaseio.com/limit.json",function(event)
    limit = event
end)




get(
    "https://kritireg-default-rtdb.firebaseio.com/ver.json",
    function(event)
        if VERSION ~= event then
            print(event)
            local verE = display.newRect(display.contentCenterX,display.contentCenterY,display.contentWidth,display.contentHeight*2)
            verE:setFillColor(0.3)
            

            local title = display.newText("ОШИБКА!",display.contentCenterX, display.contentCenterY/3)
            title:setFillColor(255,0,0)
            title.size = 50

            local erback = display.newRect(display.contentCenterX, display.contentCenterY/1.5,display.contentWidth,100)
            erback:setFillColor(0.2)

            local error = display.newText("Пожалуйста, используйте актуальную версию приложения\n\nАктуальная версия: " .. event .. "\nВаша версия: " .. VERSION, display.contentCenterX, display.contentCenterY/1.5)
            error.size = display.contentWidth/30
            error:setFillColor(0.7,0.7,0.7)

            local other1 = display.newText("Приложение разработано для Sefer-а студией Kouto", 120, display.contentHeight+50)
            other1.size = display.contentWidth/35
            other1:setFillColor(0.7,0.7,0.7)

            local other2 = display.newText("Хотите знать больше?", display.contentWidth/1.5,display.contentHeight/2.9)
            other2.size = display.contentWidth/30
            other2:setFillColor(0.7)

            local url1 = display.newText("ТГК сефера", display.contentWidth/1.5,display.contentHeight/2.7)
            url1.size = display.contentWidth/30
            url1:setFillColor(0.5,0.5,1)
            url1:addEventListener("touch", function(event)
                if event.phase == "began" then
                    system.openURL("https://t.me/+PnX1GdAq6f1lNzQy")
                end
        end)

            local url2 = display.newText("ТГК kouto (Разработчика)", display.contentWidth/1.5,display.contentHeight/2.5)
            url2.size = display.contentWidth/30
            url2:setFillColor(0.5,0.5,1)
            url2:addEventListener("touch", function(event)
                if event.phase == "began" then
                    system.openURL("https://t.me/sqgtems")
                end
        end)

        else
            get("https://kritireg-default-rtdb.firebaseio.com/users.json", function(event)

                get("https://kritireg-default-rtdb.firebaseio.com/allowed.json", function(event2)

                    get("https://kritireg-default-rtdb.firebaseio.com/developers.json", function(event3)

                    event2 = json.decode(event2)
                    event3 = json.decode(event3)
                    event = json.decode(event)
                    users = event
                    if event[id] == nil then
                        event[id] = {index=id}
                        post(event, "users")
                    end

                    for i in pairs(event2) do
                        if i == string.sub(event[id]["index"], 1,3) then
                            moderator = true
                        end
                    end

                    for i in pairs(event3) do
                        if i == string.sub(event[id]["index"], 1,3) then
                            developer = event3[i]
                        end
                    end

                    update_games()

                    end)
                end)
            end)
        end
    end
    )

local old_x = 0
local old_y = 0
local xpos = 0
local ypos = 0

Runtime:addEventListener("touch", 
function(event)
    if event.phase == "began" then
        old_x = event.x
        old_y = event.y
        y_velocity = 0

    elseif event.phase == "moved" then
        xpos = event.x
        ypos = event.y 
        y_velocity = tonumber((old_y-ypos)/15)

        gms.y = gms.y + (old_y-ypos)/25
        scr.y = scr.y + (old_y-ypos)/25
        move_oth.y = move_oth.y + (old_y-ypos)/25
        if gms.y < -tonumber(limit) then
            gms.y = -limit
            scr.y = -limit
            move_oth.y = -limit
        end
        if gms.y > 200 then
            gms.y = 200
            scr.y = 200
            move_oth.y = 200
        end
    end

end)

local function round(number)
  return math.floor(number * 10 + 0.5) / 10
end

Runtime:addEventListener("enterFrame", function(event)
    y_velocity = round(y_velocity)
    if gms.y > -tonumber(limit) and gms.y < 200 then
        gms.y = gms.y + y_velocity
        scr.y = scr.y + y_velocity
        move_oth.y = move_oth.y + y_velocity
    end

        if y_velocity > 0 then
            y_velocity = y_velocity - 0.1
        elseif y_velocity < 0 then
            y_velocity = y_velocity + 0.1
    end
end)

--------------------------------------------------------------------------------
-- App 실행, 창 호출 기능 
--------------------------------------------------------------------------------

hs.application.enableSpotlightForNameSearches(true)

require('lamune_stack')

-- 최소화된 app들의 이름을 저장할 구조체        
local hide_Stack = Stack:new()

--------------------------------------------------

-- App window 보이기 전환
function toggleApplication(appName)
    -- print ( "toggleApplication" )

    if appName == "Code" then
        local app = hs.application.get(appName)
        local app2 = hs.application.find(appName)
        
        if app then
            print ( "isFrontmost = " .. tostring(app:isFrontmost()) )
            print ( "isHidden = " .. tostring(app:isHidden()) )
            print ( "isRunning = " .. tostring(app:isRunning()) )

            -- 프로그램이 구동중인 경우 이어야 하는데...
            if app:isFrontmost() then
                if app:isHidden() then
                    print("1-1-1")
                    -- 보이기 
                    hide_Stack:delete(app:name())
                    app:unHide()
                else
                    -- vs code의 경우 get으로 가져올 때 실행중이고 보이는 경우 이곳으로 온다.
                    print("1-1-2")
                    -- 숨기기
                    hide_Stack:push(app:name())
                    app:hide()
                end
            else
            -- 프로그램이 메모리에 예비 상태인 경우... 이어야 하는데
            -- vs code의 경우 get으로 가져올 경우 실행중이고 안 보이는 경우에도 이곳으로 온다.(이유 모름)
            -- vs code의 경우 get으로 가져올 경우 종료되고 메모리에만 남아 있는 경우에도 이곳으로 온다.(이유는 모름)
            -- vs code의 경우 get으로 가져올 경우 실행중이고 보이고 focus만 없는 경우에도 이곳으로 온다.(이유는 모름)
                -- if app:isRunning() then
                --     print("1-2-1")
                --     hide_Stack:delete(app:name())
                --     -- hs.application.launchOrFocus(appName)
                --     app:activate()
                -- else
                --     print("1-2-2")
                --     hide_Stack:delete(appName)
                --     hs.application.launchOrFocus("Visual Studio Code")
                -- end

                print("1-2-1")
                -- 보이기 
                hide_Stack:delete(app:name())
                app:activate()
                hs.application.launchOrFocus("Visual Studio Code")

            end
        else
            print("2")
            -- 프로그램이 비 구동중인 경우
            hide_Stack:delete(appName)
            hs.application.launchOrFocus("Visual Studio Code")
        end

        return true
    end  


    local app = hs.application.find(appName)
    if app then
        -- 프로그램이 구동중인 경우
        if app:isFrontmost() then
            if app:isHidden() then
                print("1-1-1")
                -- 보이기 
                hide_Stack:delete(app:name())
                app:unHide()
            else
                print("1-1-2")
                -- 숨기기
                hide_Stack:push(app:name())
                app:hide()
            end
        else
        -- 프로그램이 메모리에 예비 상태인 경우
            print("1-2" .. appName)
            hide_Stack:delete(app:name())
            hs.application.launchOrFocus(appName)
        end
    else
        print("2")
        -- 프로그램이 구동중인 경우
        hide_Stack:delete(app:name())
        hs.application.launchOrFocus(appName)
    end
    print("3")
end


-- 활성 창 최소화
function minimizeActiveWindow()
    local app = hs.application.frontmostApplication()
    hide_Stack:push(app:name())
    -- lastAppName = app:name()
    app:hide()
end

-- 최소화된 창을 복원
restoreMinimizedWindow = function()
    lastAppName = hide_Stack:pop()
    if lastAppName then
        toggleApplication(lastAppName)
    end
end

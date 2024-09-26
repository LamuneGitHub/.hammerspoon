-- 스택 구조체 구현

-- local myStack = Stack:new()

-- myStack:push(10)
-- myStack:push(20)
-- print(myStack:peek())  -- 20 출력
-- print(myStack:pop())   -- 20 출력
-- print(myStack:size())  -- 1 출력

Stack = {}
Stack.__index = Stack

-- 스택 생성 함수
function Stack:new()
    local stack = { items = {} }
    setmetatable(stack, Stack)
    return stack
end

-- 스택에 값 추가 (push)
function Stack:push(item)

    -- 값이 중복되지 않도록 먼저 삭제
    self.delete(item)

    -- 값을 새로 입력
    table.insert(self.items, item)
    -- self.items[item] = item
end

-- 값이 있으면 삭제
function Stack:delete(item)
    -- if self.items[item] ~= nil then
    --     self.items[item] = nil  -- 키가 존재하면 삭제
    --     return true  -- 삭제가 성공하면 true 반환
    -- else
    --     return false  -- 키가 없으면 false 반환
    -- end

    if self.items == nil then
        return false  -- 값이 없으면 false 반환
    end

    for key, value in pairs(self.items) do
        if value == item then
            -- self.items[key] = nil  -- 값이 item과 일치하면 해당 항목 삭제
            table.remove(self.items,key)
            return true  -- 삭제 성공 시 true 반환
        end
    end

    return false  -- 값이 없으면 false 반환
end


-- 스택에서 값 제거 및 반환 (pop)
function Stack:pop()

    if self.items == nil then
        return nil
    end


    if #self.items == 0 then
        return nil  -- 스택이 비어 있으면 nil 반환
    else
        return table.remove(self.items)  -- 마지막 값을 반환하며 제거
    end
end

-- 스택의 마지막 값을 확인 (peek)
function Stack:peek()
    if self.items == nil then
        return nil
    end

    return self.items[#self.items]
end

-- 스택이 비었는지 확인
function Stack:isEmpty()
    if self.items == nil then
        return true
    end

    return #self.items == 0
end

-- 스택의 크기 반환
function Stack:size()
    if self.items == nil then
        return 0
    end

    return #self.items
end


-- 테이블을 재귀적으로 출력하는 함수
function Stack:print()
    indent = indent or 0
    local prefix = string.rep("  ", indent)


    if self.items == nil then
        return false
    end

    for key, value in pairs(self.items) do
        if type(value) == "table" then
            print(prefix .. tostring(key) .. ":")
            printTable(value, indent + 1)  -- 테이블 내부가 또 있으면 재귀적으로 출력
        else
            print(prefix .. tostring(key) .. ": " .. tostring(value))
        end
    end
end



-- local hide_Stack_test = Stack:new()
-- hide_Stack_test:push("a1")
-- hide_Stack_test:push("a3")
-- hide_Stack_test:push("a2")

-- print( hide_Stack_test:size())
-- hide_Stack_test:print()

-- hide_Stack_test:delete("a3")
-- print( hide_Stack_test:size())
-- hide_Stack_test:print()

-- hide_Stack_test:delete("f3")
-- print( hide_Stack_test:size())
-- hide_Stack_test:print()


-- print( hide_Stack_test:pop() )
-- print( hide_Stack_test:size())
-- hide_Stack_test:print()



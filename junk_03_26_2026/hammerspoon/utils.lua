function DeepCopy(o, seen)
    seen = seen or {}
    if o == nil then return nil end
    if seen[o] then return seen[o] end
  
    local no
    if type(o) == 'table' then
      no = {}
      seen[o] = no
  
      for k, v in next, o, nil do
        no[DeepCopy(k, seen)] = DeepCopy(v, seen)
      end
      setmetatable(no, DeepCopy(getmetatable(o), seen))
    else -- number, string, boolean, etc
      no = o
    end
    return no
  end
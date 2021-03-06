function courseplay:isEven(n)
   return tonumber(n) % 2 == 0;
end;

function courseplay:isOdd(n)
   return tonumber(n) % 2 == 1;
end;

--Table concatenation: http://stackoverflow.com/a/1413919
-- return a new array containing the concatenation of all of its parameters. Scaler parameters are included in place, and array parameters have their values shallow-copied to the final array. Note that userdata and function values are treated as scalar.
function tableConcat(...) 
    local t = {}
    for n = 1,select("#",...) do
        local arg = select(n,...)
        if type(arg)=="table" then
            for _,v in ipairs(arg) do
                t[#t+1] = v
            end
        else
            t[#t+1] = arg
        end
    end
    return t
end

--stringToMath [Jakob Tischler, 22 Mar 2013]
function courseplay:stringToMath(str)
	local result = str;
	
	if string.find(str, "+") then
		local strAr = Utils.splitString("+", str);
		if table.getn(strAr) == 2 then
			result = tonumber(strAr[1]) + tonumber(strAr[2]);
			return result;
		end;
	elseif string.find(str, "-") and string.find(str, "-") > 1 then --Note: >1 so that it doesn't match simple negative numbers (e.g. "-2");
		local strAr = Utils.splitString("-", str);
		if table.getn(strAr) == 2 then
			result = tonumber(strAr[1]) - tonumber(strAr[2]);
			return result;
		end;
	elseif string.find(str, "*") then
		local strAr = Utils.splitString("*", str);
		if table.getn(strAr) == 2 then
			result = tonumber(strAr[1]) * tonumber(strAr[2]);
			return result;
		end;
	elseif string.find(str, "/") then
		local strAr = Utils.splitString("/", str);
		if table.getn(strAr) == 2 then
			result = tonumber(strAr[1]) / tonumber(strAr[2]);
			return result;
		end;
	end;
	
	return tonumber(result);
end;


function courseplay:isFolding(workTool) --TODO: use getIsAnimationPlaying(animationName)
	if courseplay:isFoldable(workTool) then
		for k, foldingPart in pairs(workTool.foldingParts) do
			local charSet = foldingPart.animCharSet;
			local animTime = nil
			if charSet ~= 0 then
				animTime = getAnimTrackTime(charSet, 0);
			else
				animTime = workTool:getRealAnimationTime(foldingPart.animationName);
			end;

			if animTime ~= nil then
				if workTool.foldMoveDirection > 0 then
					if animTime < foldingPart.animDuration then
						return true;
					end
				elseif workTool.foldMoveDirection < 0 then
					if animTime > 0 then
						return true;
					end
				end
			end
		end;
		return false;
	else
		return false;
	end;
end;

function courseplay:isAnimationPartPlaying(workTool, index)
	if type(index) == "number" then
		local animPart = workTool.animationParts[index];
		if animPart == nil then
			print(nameNum(workTool) .. ": animationParts[" .. tostring(index) .. "] doesn't exist! isAnimationPartPlaying() returns nil");
			return nil;
		end;
		return animPart.clipStartTime == false and animPart.clipEndTime == false;
	elseif type(index) == "table" then
		for i,singleIndex in pairs(index) do
			local animPart = workTool.animationParts[singleIndex];
			if animPart == nil then
				print(nameNum(workTool) .. ": animationParts[" .. tostring(singleIndex) .. "] doesn't exist! isAnimationPartPlaying() returns nil");
				return nil;
			end;
			if animPart.clipStartTime == false and animPart.clipEndTime == false then
				return true;
			end;
		end;
		return false;
	else
		print(nameNum(workTool) .. ": type of index doesn't work with animationParts! isAnimationPartPlaying() returns nil");
		return nil;
	end;
end;

function courseplay:round(num, decimals)
	if num == nil or type(num) ~= "number" then
		return nil;
	end;

	if decimals and decimals > 0 then
		local mult = 10^decimals;
		return math.floor(num * mult + 0.5) / mult;
	end;
	return math.floor(num + 0.5);
end;

function courseplay:nilOrBool(variable, bool)
	return variable == nil or (variable ~= nil and variable == bool);
end;

function table.contains(table, element) --TODO: always use Utils.hasListElement
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end;

function table.map(table, func)
	local newArray = {};
	for i,v in ipairs(table) do
		newArray[i] = func(v);
	end;
	return newArray;
end;

function startswith(sbig, slittle) --TODO: always use Utils.startsWith
	if type(slittle) == "table" then
		for k, v in ipairs(slittle) do
			if string.sub(sbig, 1, string.len(v)) == v then
				return true
			end
		end
		return false
	end
	return string.sub(sbig, 1, string.len(slittle)) == slittle
end

function endswith(sbig, slittle) --TODO: always use Utils.endsWith
	if type(slittle) == "table" then
		for k, v in ipairs(slittle) do
			if string.sub(sbig, string.len(sbig) - string.len(v) + 1) == v then
				return true
			end
		end
		return false
	end
	return string.sub(sbig, string.len(sbig) - string.len(slittle) + 1) == slittle
end

function nameNum(vehicle)
	if vehicle.working_course_player_num ~= nil then
		return tostring(vehicle.name) .. " (#" .. tostring(vehicle.working_course_player_num) .. ")";
	elseif vehicle.isHired then
		return tostring(vehicle.name) .. " (helper)";
	end;
	return tostring(vehicle.name);
end;

function courseplay:isBetween(n, num1, num2, include)
	if type(n) ~= "number" or type(num1) ~= "number" or type(num2) ~= "number" then
		return;
	end;
	if include then
		return (num1 > num2 and n <= num1 and n >= num2) or (num1 < num2 and n >= num1 and n <= num2);
	else
		return (num1 > num2 and n < num1 and n > num2) or (num1 < num2 and n > num1 and n < num2);
	end;
end;

function courseplay:setVarValueFromString(self, str, value)
	local what = Utils.splitString(".", str);
	local whatDepth = table.getn(what);
	if whatDepth < 1 or whatDepth > 5 then
		return;
	end;

	local baseVar = nil;
	if what[1] == "self" then 
		baseVar = self;
	elseif what[1] == "courseplay" then
		baseVar = courseplay;
	end;

	if baseVar ~= nil then
		local result = nil;
		if whatDepth == 1 then --self
			baseVar = value;
			result = value;
		elseif whatDepth == 2 then --self.cp or self.var
			baseVar[what[2]] = value;
			result = value;
		elseif whatDepth == 3 then --self.cp.var
			baseVar[what[2]][what[3]] = value;
			result = value;
		elseif whatDepth == 4 then --self.cp.table.var
			baseVar[what[2]][what[3]][what[4]] = value;
			result = value;
		elseif whatDepth == 5 then --self.cp.table1.table2.var
			baseVar[what[2]][what[3]][what[4]][what[5]] = value;
			result = value;
		end;

		courseplay:debug("					" .. table.concat(what, ".") .." = " .. tostring(result),5);
	end;

	what = nil;
end;
function courseplay:getVarValueFromString(self, str)
	local what = Utils.splitString(".", str);
	local whatDepth = table.getn(what);
	local whatObj = nil;
	if what[1] == "self" then 
		whatObj = self;
	elseif what[1] == "courseplay" then
		whatObj = courseplay;
	end;

	if whatObj ~= nil then
		for i=2,whatDepth do
			local key = what[i];
			whatObj = whatObj[key];
			
			if i ~= whatDepth and type(whatObj) ~= "table" then
				print(nameNum(self) .. ": error in string \"" .. str .. "\" @ \"".. key .. "\": traversal failed");
				whatObj = nil;
				break;
			end;
		end;
	end;

	--print(table.concat(what, ".") .."=" .. tostring(whatObj))
	return whatObj;
end;

function courseplay:boolToInt(bool)
	if bool == nil or type(bool) ~= "boolean" then
		return nil;
	elseif bool == true then
		return 1;
	elseif bool == false then
		return 0; 
	end;
end;
function courseplay:intToBool(int)
	if int == nil or type(int) ~= "number" then
		return nil;
	end;
	return int == 1;
end;

function courseplay:loopedTable(tab, idx)
	local maxIdx = #tab;
	if idx > maxIdx then
		while idx > maxIdx do
			idx = maxIdx - idx;
		end;
	elseif idx < 1 then
		while idx < 1 do
			idx = maxIdx + idx;
		end;
	end;

	return tab[idx]
end;

function courseplay:varLoop(var, changeBy, max, min)
	local min = min or 1;
	local var = var + changeBy;
	if var > max then
		var = min;
	end;
	if var < min then
		var = max;
	end;
	return var;
end;

-- by horoman
courseplay.utils.table = {}

function courseplay.utils.table.compare(t1,t2,field)
	local result = false
	local C1 = t1[field]
	local C2 = t2[field]
	
	if type(C1) == 'string' or type(C2) == 'string' then
		local c1 = string.lower(C1)
		local c2 = string.lower(C2)
		if c1 == c2 then
			result = C1 < C2
		else
			result = c1 < c2
		end
	else
		result = C1 < C2
	end

	return result
end

function courseplay.utils.table.compare_name(t1,t2)
	return courseplay.utils.table.compare(t1,t2,'name')
end

function courseplay.utils.table.search_in_field(tab, field, term)
	local result = {}
	for k,v in pairs(tab) do
		if v[field] == term then
			table.insert(result, v)
		end
	end
	return result
end

function courseplay.utils.table.copy(tab)
-- note that only tab is copied. if tab contains tables itself again, these tables are not copied but referenced again (the reference is copied).
	local result = {}
	for k,v in pairs(tab) do
		result[k]=v
	end
	return result
end

function courseplay.utils.table.append(t1,t2)
	for k,v in pairs(t2) do
		table.insert(t1,v)
	end
	return t1
end

function courseplay.utils.table.merge(t1, t2, overwrite)
	if overwrite == nil then
		overwrite = false
	end
	for k, v in pairs(t2) do
		if overwrite or t1[k] == nil then
			t1[k] = v		
		end
	end
	return t1
end

function courseplay.utils.table.move(t1, t2, t1_index, t2_index)
	t1_index = t1_index or (#t1);
	t2_index = t2_index or (#t2 + 1);
	if t1[t1_index] == nil then
		return false;
	end;

	t2[t2_index] = t1[t1_index];
	t1[t1_index] = nil;
	return t2[t2_index] ~= nil;
end;

function courseplay.utils.table.last(tab)
	if #tab == 0 then
		return nil;
	end;
	return tab[#tab];
end;

function courseplay.utils.table.getMax(tab, field)
	local max = nil
	if tab ~= nil and field ~= nil then
		max = false
		for k, v in pairs(tab) do
			if v[field] ~= nil then
				max = v[field]
				break
			end
		end
		for k, v in pairs(tab) do
			if v[field] ~= nil then
				if v[field] > max then
					max = v[field]
				end
			end
		end
	end
	return max
end

function courseplay.utils.findXMLNodeByAttr(File, node, attr, value, val_type)
	-- returns the node number in case of success
	-- else it returns the negative value of the next unused node (if there are 6 nodes with the name defined by the node parameter and none matches the search, the function returns -7)
	val_type = val_type or 'Int'
	local i = -1
	local done = false
	local dummy
	
	-- this solution does not look very nice but has no unnecessary statements in the loops which should make them as fast as possible
	if val_type == 'Int' then
		repeat
			i = i + 1
			dummy = ''				
			dummy = getXMLInt(File, string.format(node .. '(%d)' .. "#" .. attr, i))			
			if dummy == value then
				done = true
			elseif dummy == nil then
				--the attribute seems not to exist. Does the node?
				if not hasXMLProperty(File, string.format(node .. '(%d)', i)) then
					-- if the node does not exist, we are at the end and done
					done = true
				end
			end
		until done
	elseif val_type == 'String' then
		repeat
			i = i + 1
			dummy = ''				
			dummy = getXMLString(File, string.format(node .. '(%d)' .. "#" .. attr, i))
			if dummy == value then
				done = true
			elseif dummy == nil then
				--the attribute seems not to exist. Does the node?
				if not hasXMLProperty(File, string.format(node .. '(%d)', i)) then
					-- if the node does not exist, we are at the end and done
					done = true
				end
			end
		until done
	elseif val_type == 'Float' then
		repeat
			i = i + 1
			dummy = ''				
			dummy = getXMLFloat(File, string.format(node .. '(%d)' .. "#" .. attr, i))
			if dummy == value then
				done = true
			elseif dummy == nil then
				--the attribute seems not to exist. Does the node?
				if not hasXMLProperty(File, string.format(node .. '(%d)', i)) then
					-- if the node does not exist, we are at the end and done
					done = true
				end
			end
		until done		
	elseif val_type == 'Bool' then
		repeat
			i = i + 1
			dummy = ''				
			dummy = getXMLBool(File, string.format(node .. '(%d)' .. "#" .. attr, i))
			if dummy == value then
				done = true
			elseif dummy == nil then
				--the attribute seems not to exist. Does the node?
				if not hasXMLProperty(File, string.format(node .. '(%d)', i)) then
					-- if the node does not exist, we are at the end and done
					done = true
				end
			end
		until done		
	else
		-- Error?!
	end	
	
	if dummy ~= nil then
		return i
	else
		return -1*i
	end
end

function courseplay.utils.findFreeXMLNode(File, node)
	-- returns the node number in case of success
	local i = -1
	local done = false
	local exists
	
	repeat
		i = i+1
		exists = hasXMLProperty(File, string.format(node .. '(%d)', i))
		if not exists then
			done = true
		end
	until done
	
	return i
end

function courseplay.utils.setXML(File, node, attribute, value, val_type, match_attr, match_attr_value, match_attr_type)
	-- this function is not meant do be called in loops as it is rather slow: 
	-- 1) due to the loadstring function.
	-- 2) it is searched for the node everytime the function is called.
	-- Use setMultipleXML instead.
	attribute = attribute or ''
	val_type = val_type or 'Int'
	match_attr = match_attr or ''
	match_attr_value = match_attr_value or ''
	match_attr_type = match_attr_type or 'Int'
	
	if attribute ~= '' then
		attribute = '#' .. attribute
	end
	if match_attr ~= '' and match_attr_value ~= '' then
		local i = courseplay.utils.findXMLNodeByAttr(File, node, match_attr, match_attr_value, match_attr_type)
		if i < 0 then i = -i end
		assert(loadstring('setXML' .. val_type .. '(...)'))(File, string.format(node .. '(%d)' .. attribute, i), value)
	else
		assert(loadstring('setXML' .. val_type .. '(...)'))(File, node .. attribute, value)
	end
end

function courseplay.utils.setMultipleXML(File, node, values, types, skip_attr)
-- function to save multiple attributes (and to the node itself) of one node
--
-- File: File got by loadXML(...)
-- node (string)
-- values has to be a table of the form:
-- {attribute1 = value1, attribute2 = value2, ...}
-- to write into the node directly set attribute = '_node_'
-- types is a table of the form:
-- {attribute1 = type1, attribute2 = type2, ...}; type1 is a string (e.g. 'Int')
-- skip_attr (table): contains attributes to be skipped as strings
	if skip_attr == nil then
		skip_attr = false
	end
	
	local skip = false
	local attribute, value, val_type
	
	for k, v in pairs(values) do
		attribute = k
		
		if skip_attr ~= false then
			if Utils.hasListElement(skip_attr, k) then
				skip = true
			else
				skip = false
			end
		end
		
		if not skip then
			value = v
			val_type = types[k]
	
			if attribute ~= '_node_' then
				attribute = '#' .. attribute
			else
				attribute = ''
			end
		
			if val_type == 'Int' then
				setXMLInt(File, node .. attribute, value)
			elseif val_type == 'String' then
				setXMLString(File, node .. attribute, value)
			elseif val_type == 'Float' then
				setXMLFloat(File, node .. attribute, value)
			elseif val_type == 'Bool' then
				setXMLBool(File, node .. attribute, value)
			else
				-- Error?!
			end
		end -- end if not skip then
	end	 -- end for k, v in pairs(values) do
end

function courseplay.utils.setMultipleXMLNodes(File, root_node, node_name , values, types, skip_attr, unique_nodes)
	-- values has to be a table of the form:
	-- {attribute1 = value1, attribute2 = value2, ...}
	-- types a table of the form:
	-- {attribute1 = type1, attribute2 = type2, ...}
	-- to write into the node directly set attribute = '_node_'

	if skip_attr == nil then
		skip_attr = false
	end
	if unique_nodes == nil then
		unique_nodes = true
	end
	
	local skip = false
	local j = 0
	local node = ''

	
	for k, v in pairs(values) do
		if unique_nodes then
			node = root_node .. '.' .. node_name .. k
		else
			node = string.format(root_node .. '.' .. node_name .. '(%d)', j)
			j = j+1
		end		
		courseplay.utils.setMultipleXML(File, node, v, types, skip_attr)
	end
end

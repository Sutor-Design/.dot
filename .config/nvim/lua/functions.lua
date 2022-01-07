local function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end


function _G.EslintToQF(root_path, target_path)
	local command = "cd " .. root_path .. " && yarn eslint " .. target_path .. " --format unix"
	print(command)
	local results_list = vim.fn.systemlist(command)
	print(vim.inspect(results_list))
	-- vim.cmd("cex systemlist('" .. command .. "')")
	vim.fn.setqflist({}, "r", { title = "ESLint issues", items = results_list })
	vim.cmd("copen")
end

function _G.TSCToQF(root_path, target_path)
	-- tsc does not produce nice output, so need to parse it to something more usable.
	-- (it's multiline and has a bunch of spaces). Just using `sed` for now.
	-- Example output:
	--
	--		src/App/AppMain/BlockTrips.tsx:37:5: error TS2322: Type 'string | undefined' is not assignable to type 'string'.
	--		Type 'undefined' is not assignable to type 'string'.
	--
	local command = "cd " .. root_path .. " && yarn tsc --noEmit --pretty false"
	-- FIXME: can't get an error format that works.
	-- vim.cmd([[
	-- 	setlocal errorformat^=%E%f %#(%l\,%c): error %m,%E%f %#(%l\,%c): %m,%Eerror %m,%C%\s%\+%m
	-- ]])
  -- local sed_format = [=[sed -E '$!N;s/(.+)\((.+),(.+)\): (error .+): (.+)\.\n[[:space:]]+(.+)/\1:\2:\3:\4:\5 - \6/']=]
	local results_list = vim.fn.systemlist(command)
	local results_list_formatted = {}
	for _, result in ipairs(results_list) do
		-- trim the line
		if result:match(".+%(%d+,%d+%)") then
			local filepath, line, column, error_message = result:match("%s*(.-)%((%d-),(%d-)%):(.-)$")
			if error_message:match("^%s*error TS%d+:") then error_message = error_message:gsub("^%s*(.-):(.-)$", "%1 - %2") end
			table.insert(results_list_formatted, {
				filename = filepath,
				lnum = line,
				col = column,
				text = error_message,
			})
		end
	end

	print(vim.inspect(results_list_formatted))
	vim.fn.setqflist({}, "r", { title = "TSC issues", items = results_list_formatted })
	vim.cmd("copen")
	-- print(vim.inspect(results_list))
	-- vim.cmd("cex systemlist('" .. command .. "')")
end

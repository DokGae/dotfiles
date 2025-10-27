-- Zoxide integration plugin for Yazi

local function shell_execute(cmd)
	local handle = io.popen(cmd)
	if not handle then
		return ""
	end
	local result = handle:read("*a") or ""
	handle:close()
	return result:gsub("%s+$", "")
end

local function extract_path(entry)
	if not entry or entry == "" then
		return ""
	end
	local path = entry:match("^[^	]*	([^	]+)")
	if path then
		return path:gsub("^%s+", ""):gsub("%s+$", "")
	end
	local trimmed = entry:gsub("^%s+", "")
	local fallback = trimmed:match("^%S+%s+(.+)$") or trimmed
	return fallback:gsub("^%s+", "")
end

return {
	entry = function(_, args)
		if args and args[1] == "fzf" then
			local script = os.getenv("HOME") .. "/.config/yazi/plugins/zoxide.yazi/rank_zoxide.sh"
			local script_quoted = string.format("%q", script)
			local cmd = string.format([[ \
				fzf \
					--ansi \
					--prompt="z > " \
					--height=50%% \
					--layout=reverse \
					--border \
					--info=inline \
					--disabled \
					--no-sort \
					--delimiter="\t" \
					--with-nth=3 \
					--bind 'start:reload(%s "")' \
					--bind 'change:reload(%s {q})' \
					--bind 'enter:become(bash -c '\''printf "%s\\n" "$1"'\'' -- {2})' \
					--preview 'bash -c '\''path="$1"; ls -la "$path"'\'' -- {2}' \
					--preview-window=down,40%%,border-top
			]], script_quoted, script_quoted)

			local selected = shell_execute(cmd)
			if selected and selected ~= "" then
				local path = extract_path(selected)
				if path ~= "" then
					ya.manager_emit("cd", { path })
				end
			end
		else
			local selected = shell_execute("zoxide query -i")
			if selected and selected ~= "" then
				ya.manager_emit("cd", { selected })
			end
		end
	end,
}

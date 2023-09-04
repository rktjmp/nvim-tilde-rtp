vim.cmd("version")
-- Script expects
local cache = vim.fn.stdpath("cache")
local lua_dir = vim.fs.normalize(cache .. "/some-dir/lua")
local lua_file = vim.fs.normalize(lua_dir .. "/abc.lua")

vim.fn.mkdir(lua_dir, "p")
local fd = assert(io.open(lua_file, "w"))
fd:write("true")
fd:close()

-- check file exists
assert(vim.loop.fs_access(lua_file, "R"), "Failed to create lua file")

print("Cache:", cache)
print("Lua file:", lua_file)
print("RTP", vim.go.rtp)

-- Try to find file (should fail, we have not added it to rtp yet)
print(vim.inspect(vim.api.nvim_get_runtime_file("", true)))
print(vim.inspect(vim.api.nvim_get_runtime_file("lua/abc.lua", true)))

-- Add cache to rtp
vim.opt.runtimepath:prepend(cache.."/*")
-- Now we have RUNNER~1/temp in the RTP
print("RTP", vim.go.rtp)

-- try to find files, should now work as we have added to rtp
-- but it will fail because the dir contains ~ or possibly fails
-- some "does it exist?" check.
-- 
-- For ref, windows creates two entries, users/RUNNER~1 (invisible) and
-- users/runneradmin, both pointing to the same dir.
print(vim.inspect(vim.api.nvim_get_runtime_file("", true)))
print(vim.inspect(vim.api.nvim_get_runtime_file("lua/abc.lua", true)))

-- convert `RUNNER~1` into runneradmin in RTP
vim.go.rtp = vim.go.rtp:gsub("RUNNER~1", "runneradmin", 1)
print("RTP", vim.go.rtp)

-- Search now succeeds
print(vim.inspect(vim.api.nvim_get_runtime_file("", true)))
print(vim.inspect(vim.api.nvim_get_runtime_file("lua/abc.lua", true)))

print("fs_realpath(cache)", vim.loop.fs_realpath(cache))
print("fs_realpath(lua_dir)", vim.loop.fs_realpath(lua_dir))

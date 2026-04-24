local util = {}
function util.read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local s = f:read("*a")
  f:close()
  return s
end
function util.detect_iface()
  local env = os.getenv("NEONWAVE_NET_IFACE")
  if env and #env > 0 then return env end
  local p = io.popen("ls -1 /sys/class/net 2>/dev/null")
  if not p then return "lo" end
  local list = p:read("*a") or ""
  p:close()
  for iface in list:gmatch("[^\r\n]+") do
    if iface ~= "lo" then return iface end
  end
  return "lo"
end
function util.human_rate(bytes_per_sec)
  local b = tonumber(bytes_per_sec) or 0
  local units = { "B/s", "KB/s", "MB/s", "GB/s" }
  local i = 1
  while b >= 1024 and i < #units do b = b / 1024; i = i + 1 end
  if i == 1 then return string.format("%d %s", math.floor(b + 0.5), units[i]) end
  return string.format("%.2f %s", b, units[i])
end
return util

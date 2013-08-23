local socket = require "socket"
local http = require "socket.http"

local char = string.char
local gsub = string.gsub
local random = math.random

blacklist = {
  -- for ipv6
  '1.1.1.1', '255.255.255.255',
  -- for google+
  '74.125.127.102', '74.125.155.102', '74.125.39.102', '74.125.39.113',
  '209.85.229.138',
  -- other ip list
  '4.36.66.178', '8.7.198.45', '37.61.54.158', '46.82.174.68',
  '59.24.3.173', '64.33.88.161', '64.33.99.47', '64.66.163.251',
  '65.104.202.252', '65.160.219.113', '66.45.252.237', '72.14.205.104',
  '72.14.205.99', '78.16.49.15', '93.46.8.89', '128.121.126.139',
  '159.106.121.75', '169.132.13.103', '192.67.198.6', '202.106.1.2',
  '202.181.7.85', '203.161.230.171', '203.98.7.65', '207.12.88.98',
  '208.56.31.43', '209.145.54.50', '209.220.30.174', '209.36.73.33',
  '209.85.229.138', '211.94.66.147', '213.169.251.35', '216.221.188.182',
  '216.234.179.13', '243.185.187.3', '243.185.187.39'
}

google_cn_domain = {
  'www.google.cn', 'www.g.cn'
}

google_cn_ip_predefine = {
  "203.208.46.131", "203.208.46.132", "203.208.46.133", "203.208.46.134",
  "203.208.46.135", "203.208.46.136", "203.208.46.137", "203.208.46.138",
}

google_hk_domain = {
  "www.google.com", "www.l.google.com", "mail.google.com", "mail.l.google.com",
  "mail-china.l.google.com"
}

google_cn_valid_ip_prefix = '203.208.'

function remote_resolve(dnsserver, qname, timeout)
  data = _dns_remote_resolve(dnsserver, qname, timeout or 30)
  return _dns_reply_to_iplist(data or '')
end

function _dns_remote_resolve(dnsserver, qname, timeout)
  data = char(random(0,255)) .. char(random(0,255))
  data = data .. "\1\0\0\1\0\0\0\0\0\0"
  data = data .. gsub(qname, "([^.]+)%.?", function(s) return char(#s)..s end) .. '\0'
  data = data .. "\0\1\0\1"
  
  local s = socket.udp()
  s:setpeername(dnsserver, 53)
  s:settimeout(timeout)
  local ok,_ = s:send(data)
  if not ok then
    return nil, "failed to send request to UDP server"
  end
  local buf,err = s:receive(2^10)
  if err then
    return nil
  end
  return buf
end

function _dns_reply_to_iplist(data)
  for i = 1,#data do
    if data:byte(i) == 192 and data:byte(i+2) == 0
       and data:byte(i+3) == 1 and data:byte(i+4) == 0
       and data:byte(i+5) == 1 then
      digits = {}
      for j = 12,15 do
        digits[#digits + 1] = data:byte(i+j)
      end
      local ip = table.concat(digits, ".")
      print(ip)
    end
  end
  local ip = ""
  return ip
end

function main()
  math.randomseed(os.time())
  s = remote_resolve("8.8.8.8", "www.g.cn", 5)
  print(s)
end

local debug = require "debug"
if debug.getinfo(1).what == "main" then
  main()
end

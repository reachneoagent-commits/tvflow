sub init()
    m.top.functionName = "serve"
end sub

sub serve()
    m.clients = {}
    listener = CreateObject("roStreamSocket")
    addr = CreateObject("roSocketAddress")
    addr.setPort(8888)
    listener.setAddress(addr)
    listener.setReuseAddr(true)
    listener.listen(4)
    if not listener.eOK() then
        m.top.error = "could not listen on port 8888"
        return
    end if
    port = CreateObject("roMessagePort")
    listener.setMessagePort(port)
    listener.notifyReadable(true)
    m.top.ready = true
    while true
        msg = wait(0, port)
        if type(msg) = "roSocketEvent" then
            id = msg.getSocketID()
            if id = listener.getID() then
                if listener.isReadable() then
                    c = listener.accept()
                    if c <> invalid then
                        c.setMessagePort(port)
                        c.notifyReadable(true)
                        m.clients[c.getID().toStr()] = c
                    end if
                end if
            else
                key = id.toStr()
                c = m.clients[key]
                if c <> invalid then handleClient(c, key)
            end if
        end if
    end while
end sub

sub handleClient(c as object, key as string)
    if not c.isReadable() then return
    buf = CreateObject("roByteArray")
    buf[8191] = 0
    n = c.receive(buf, 0, 8192)
    if n <= 0 then
        c.close()
        m.clients.delete(key)
        return
    end if
    req = Left(buf.toAsciiString(), n)
    body = page("")
    re = CreateObject("roRegex", "^GET ([^ ]+) HTTP", "")
    mt = re.match(req)
    if mt.count() = 2 then
        path = mt[1]
        q = Instr(1, path, "?")
        route = path
        query = ""
        if q > 0 then
            route = Left(path, q - 1)
            query = Mid(path, q + 1)
        end if
        if route = "/add" then body = handleAdd(query)
    end if
    crlf = chr(13) + chr(10)
    c.sendStr("HTTP/1.1 200 OK" + crlf + "Content-Type: text/html; charset=utf-8" + crlf + "Content-Length: " + Len(body).toStr() + crlf + "Connection: close" + crlf + crlf + body)
    c.close()
    m.clients.delete(key)
end sub

function unesc(v as string) as string
    v = CreateObject("roRegex", "\+", "").replaceAll(v, " ")
    return CreateObject("roUrlTransfer").unescape(v)
end function

function handleAdd(query as string) as string
    p = {}
    for each part in query.split("&")
        i = Instr(1, part, "=")
        if i > 0 then p[Left(part, i - 1)] = unesc(Mid(part, i + 1))
    end for
    name = "Phone source"
    if p.name <> invalid and p.name <> "" then name = p.name
    src = invalid
    if p.url <> invalid and p.url <> "" then
        src = { name: name, type: "m3u", url: p.url.trim() }
    else if p.server <> invalid and p.server <> "" and p.username <> invalid and p.password <> invalid then
        srv = p.server.trim()
        if Left(srv, 4) <> "http" then srv = "http://" + srv
        src = { name: name, type: "xtream", server: srv, username: p.username.trim(), password: p.password.trim() }
    end if
    if src = invalid then return page("Nothing received. Fill in a link, or server + username + password.")
    m.top.newSource = src
    return page("Sent. Look at your TV: the source is added and selected.")
end function

function page(msg as string) as string
    h = "<!doctype html><meta name='viewport' content='width=device-width,initial-scale=1'><title>TVflow</title>"
    h = h + "<body style='font-family:sans-serif;max-width:480px;margin:20px auto;padding:0 12px'><h2>Add a playlist to TVflow</h2>"
    if msg <> "" then h = h + "<p style='background:#ffe9a8;padding:10px'>" + msg + "</p>"
    h = h + "<form action='/add'><h3>Playlist M3U link</h3>"
    h = h + "<p><input name='name' placeholder='Name' style='width:100%;padding:10px'></p>"
    h = h + "<p><textarea name='url' placeholder='Paste the link here' rows='4' style='width:100%'></textarea></p>"
    h = h + "<button style='padding:12px 20px'>Add M3U source</button></form>"
    h = h + "<form action='/add'><h3>Or Xtream Codes</h3>"
    h = h + "<p><input name='name' placeholder='Name' style='width:100%;padding:10px'></p>"
    h = h + "<p><input name='server' placeholder='Server, e.g. http://host:8080' style='width:100%;padding:10px'></p>"
    h = h + "<p><input name='username' placeholder='Username' style='width:100%;padding:10px'></p>"
    h = h + "<p><input name='password' placeholder='Password' style='width:100%;padding:10px'></p>"
    h = h + "<button style='padding:12px 20px'>Add Xtream source</button></form></body>"
    return h
end function

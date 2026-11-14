sub init()
    m.top.functionName = "run"
end sub

sub run()
    xfer = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    xfer.setMessagePort(port)
    xfer.setUrl(m.top.url)
    xfer.retainBodyOnError(true)
    res = { code: 0, body: "", error: "" }
    if not xfer.asyncGetToString() then
        res.error = "could not start request"
        m.top.result = res
        return
    end if
    msg = wait(20000, port)
    if msg = invalid then
        xfer.asyncCancel()
        res.error = "timed out after 20 s"
    else if type(msg) = "roUrlEvent" then
        res.code = msg.getResponseCode()
        res.body = msg.getString()
        if res.code < 0 then res.error = msg.getFailureReason()
    end if
    m.top.result = res
end sub

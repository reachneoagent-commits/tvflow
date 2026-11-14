sub init()
    m.top.findNode("chip").font = mkF(17, true)
    m.top.findNode("name").font = mkF(20, true)
    m.top.findNode("meta").font = mkF(16, false)
end sub

function mkF(size as integer, bold as boolean) as object
    f = CreateObject("roSGNode", "Font")
    f.uri = "font:SystemFontFile"
    if bold then f.uri = "font:BoldSystemFontFile"
    f.size = size
    return f
end function

sub onContent()
    c = m.top.itemContent
    if c = invalid then return
    m.top.findNode("pic").uri = c.hdPosterUrl
    m.top.findNode("name").text = c.title
    m.top.findNode("meta").text = c.shortdescriptionline1
    m.top.findNode("chip").text = c.shortdescriptionline2
    watched = (c.rating = "watched")
    m.top.findNode("tick").visible = watched
    showBar = (c.playStart > 20 and c.length > 0 and not watched)
    m.top.findNode("barbg").visible = showBar
    m.top.findNode("bar").visible = showBar
    if showBar then m.top.findNode("bar").width = Int(252 * c.playStart / c.length)
end sub

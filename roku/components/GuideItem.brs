sub init()
    b = CreateObject("roSGNode", "Font")
    b.uri = "font:BoldSystemFontFile"
    b.size = 18
    r = CreateObject("roSGNode", "Font")
    r.uri = "font:SystemFontFile"
    r.size = 18
    n = CreateObject("roSGNode", "Font")
    n.uri = "font:SystemFontFile"
    n.size = 16
    m.top.findNode("name").font = b
    m.top.findNode("now").font = r
    m.top.findNode("next").font = n
end sub

sub onContent()
    c = m.top.itemContent
    if c = invalid then return
    m.top.findNode("logo").uri = c.hdPosterUrl
    m.top.findNode("name").text = c.title
    m.top.findNode("now").text = c.shortdescriptionline1
    nx = c.shortdescriptionline2
    if nx <> invalid and nx <> "" then
        m.top.findNode("next").text = "Next: " + nx
    else
        m.top.findNode("next").text = ""
    end if
    tf = m.top.findNode("trackfill")
    tb = m.top.findNode("trackbg")
    show = (c.length > 0 and c.playStart > 0)
    tb.visible = show
    tf.visible = show
    if show then
        pct = c.playStart / c.length
        if pct > 1 then pct = 1
        tf.width = Int(330 * pct)
    end if
end sub

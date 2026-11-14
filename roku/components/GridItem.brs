sub init()
    f = CreateObject("roSGNode", "Font")
    f.uri = "font:SystemFontFile"
    f.size = 18
    m.top.findNode("name").font = f
end sub

sub layout()
    w = m.top.width
    h = m.top.height
    if w <= 0 or h <= 0 then return
    ph = h - 28
    m.top.findNode("bgbox").width = w
    m.top.findNode("bgbox").height = ph
    pic = m.top.findNode("pic")
    if w <= 112 then
        pic.translation = [10, 10]
        pic.width = w - 20
        pic.height = ph - 20
    else
        pic.translation = [0, 0]
        pic.width = w
        pic.height = ph
    end if
    nm = m.top.findNode("name")
    nm.translation = [0, ph + 4]
    nm.width = w
    m.top.findNode("favbg").translation = [w - 30, 4]
    m.top.findNode("fav").translation = [w - 27, 7]
end sub

sub onContent()
    c = m.top.itemContent
    if c = invalid then return
    m.top.findNode("pic").uri = c.hdPosterUrl
    t = c.title
    if t = "" then t = c.shortdescriptionline1
    m.top.findNode("name").text = t
    isFav = (c.rating = "fav")
    m.top.findNode("favbg").visible = isFav
    m.top.findNode("fav").visible = isFav
end sub

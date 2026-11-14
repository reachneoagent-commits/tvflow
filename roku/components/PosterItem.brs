sub init()
    m.name = m.top.findNode("name")
    m.sub = m.top.findNode("subtitle")
    f = CreateObject("roSGNode", "Font")
    f.uri = "font:BoldSystemFontFile"
    f.size = 18
    m.name.font = f
    g = CreateObject("roSGNode", "Font")
    g.uri = "font:SystemFontFile"
    g.size = 18
    m.sub.font = g
end sub

' three looks, picked by the slot size the row gives us: wide card (continue watching), small tile (channels), poster
sub layout()
    c = m.top.itemContent
    w = m.top.width
    h = m.top.height
    if c = invalid or w < 10 or h < 10 then return
    bg = m.top.findNode("bgbox")
    pic = m.top.findNode("pic")
    bg.width = w
    bg.height = h
    pad = 0
    if w < 110 then pad = 8
    pic.translation = [pad, pad]
    pic.width = w - pad * 2
    pic.height = h - pad * 2
    pic.uri = c.hdPosterUrl
    m.name.width = w
    m.name.translation = [0, h + 6]
    m.name.text = c.title
    m.sub.width = w
    m.sub.translation = [0, h + 30]
    sub1 = c.shortDescriptionLine2
    m.sub.text = sub1
    m.sub.visible = (sub1 <> invalid and sub1 <> "")
    tb = m.top.findNode("trackbg")
    tf = m.top.findNode("trackfill")
    show = (c.length > 0 and c.playStart > 0)
    tb.visible = show
    tf.visible = show
    if show then
        tb.width = w
        tb.translation = [0, h - 5]
        pct = c.playStart / c.length
        if pct > 1 then pct = 1
        tf.width = Int(w * pct)
        tf.translation = [0, h - 5]
    end if
    isFav = (c.rating = "fav")
    fb = m.top.findNode("favbg")
    fv = m.top.findNode("fav")
    fb.translation = [w - 30, 4]
    fv.translation = [w - 27, 7]
    fb.visible = isFav
    fv.visible = isFav
end sub

sub init()
    m.nav = m.top.findNode("nav")
    m.pill = m.top.findNode("pill")
    m.cats = m.top.findNode("cats")
    m.grid = m.top.findNode("grid")
    m.eps = m.top.findNode("eps")
    m.chlist = m.top.findNode("chlist")
    m.navTimer = m.top.findNode("navTimer")
    m.web = m.top.findNode("web")
    m.list = m.top.findNode("list")
    m.header = m.top.findNode("header")
    m.status = m.top.findNode("status")
    m.clock = m.top.findNode("clock")
    m.video = m.top.findNode("video")
    m.catTimer = m.top.findNode("catTimer")
    m.sources = []
    m.active = 0
    m.form = invalid
    m.tab = -1
    m.favs = []
    m.recent = []
    m.homeRows = []
    m.playRec = invalid
    m.fromHome = false
    m.homelist = m.top.findNode("homelist")
    m.homerow = m.top.findNode("homerow")
    m.saveTimer = m.top.findNode("saveTimer")
    m.saveTimer.observeField("fire", "onSaveTimer")
    m.homerow.rowLabelFont = mkFont(22, true)
    m.hint = m.top.findNode("hint")
    m.plname = m.top.findNode("plname")
    m.sdetail = m.top.findNode("sdetail")
    m.sdposter = m.top.findNode("sdposter")
    m.sdfav = m.top.findNode("sdfav")
    m.sdfavbg = m.top.findNode("sdfavbg")
    m.dfav = m.top.findNode("dfav")
    m.dfavbg = m.top.findNode("dfavbg")
    m.sdtitle = m.top.findNode("sdtitle")
    m.sdmeta = m.top.findNode("sdmeta")
    m.sdplot = m.top.findNode("sdplot")
    m.sdbtns = m.top.findNode("sdbtns")
    m.sdseasons = m.top.findNode("sdseasons")
    m.sdBtnLabels = []
    m.sdBtnIcons = []
    m.dLabels = []
    m.dIcons = []
    m.dIdx = 0
    m.sdBtnIdx = 0
    m.seasonLabels = []
    m.sdeps = m.top.findNode("sdeps")
    m.epg = m.top.findNode("epg")
    m.epgTimer = m.top.findNode("epgTimer")
    m.autoTimer = m.top.findNode("autoTimer")
    m.trk = m.top.findNode("trk")
    m.trkbg = m.top.findNode("trkbg")
    m.watched = {}
    m.seasonKeys = []
    m.epSeason = {}
    m.curSeasonIdx = 0
    m.nextRec = invalid
    m.trkActs = []
    m.detail = m.top.findNode("detail")
    m.pform = m.top.findNode("pform")
    m.pfIdx = 0
    m.pfBtn = 0
    m.pfMsg = ""
    m.dposter = m.top.findNode("dposter")
    m.dtitle = m.top.findNode("dtitle")
    m.dmeta = m.top.findNode("dmeta")
    m.dplot = m.top.findNode("dplot")
    m.dbtns = m.top.findNode("dbtns")
    m.detailRec = invalid
    m.dacts = []
    m.sortMode = 0
    m.itemsOrig = []
    m.noResume = false
    m.toast = m.top.findNode("toast")
    m.toastTimer = m.top.findNode("toastTimer")
    m.playIdx = -1
    m.homeSecs = []
    m.homeIsRow = false
    m.recs = { movies: [], series: [], live: [] }
    m.recsLoaded = false
    m.recsBusy = false
    m.rc = invalid
    m.area = "nav"
    m.reqSeq = 0
    m.curTag = ""
    m.catIds = []
    m.items = []
    m.epItems = []
    m.maxItems = 300
    m.canHevc = false
    m.model = ""
    di0 = CreateObject("roDeviceInfo")
    m.model = di0.GetModel()
    hv = di0.CanDecodeVideo({ Codec: "hevc" })
    if hv <> invalid and hv.result = true then m.canHevc = true
    ' Newer Rokus (HEVC / 4K capable) have more memory: allow longer lists.
    if m.canHevc then m.maxItems = 500
    print "DEVICE model="; m.model; " hevc="; m.canHevc; " maxItems="; m.maxItems
    m.guide = m.top.findNode("guide")
    m.sbtn = m.top.findNode("sbtn")
    m.lmodes = m.top.findNode("lmodes")
    m.pbar = m.top.findNode("pbar")
    m.pbtns = m.top.findNode("pbtns")
    m.toastbg = m.top.findNode("toastbg")
    m.pbarTimer = m.top.findNode("pbarTimer")
    m.pvTimer = m.top.findNode("pvTimer")
    m.gdTimer = m.top.findNode("gdTimer")
    m.liveMode = 0
    m.pvOn = false
    m.pvTs = false
    m.pvRec = invalid
    m.gd = { done: {} }
    m.gdBusy = false
    m.gdIdx = 0
    m.editSrc = -1
    m.acctIdx = 0
    m.pbActs = []
    m.pbIdx = 0
    m.pbEpg = ""
    m.catCache = {}
    m.hidden = {}
    m.sq = []
    m.set = { sort: 0, caps: 0 }
    m.gsRes = invalid
    m.gsRun = false
    m.gsView = "all"
    m.gsT = 0
    m.gsI = 1
    m.gsCatT = 0
    m.prevLive = invalid
    m.confirmAct = ""
    m.srch = invalid
    m.kbMode = ""
    m.loadedTab = -1
    m.pane = "browse"
    m.phoneUrl = ""
    loadSources()
    loadUser()
    applyFonts()
    updatePlaylistLabel()

    m.tabNames = ["Home", "Live TV", "Movies", "Series", "Playlists", "Settings"]
    m.navX = []
    m.navW = []
    nx0 = 124
    for i = 0 to 5
        nw0 = 58 + Len(m.tabNames[i]) * 11
        m.navX.push(nx0)
        m.navW.push(nw0)
        nx0 = nx0 + nw0 + 28
    end for
    m.navLabels = []
    m.navIcons = []
    m.navIconNames = ["house", "tv", "clapperboard", "tv-minimal-play", "list-video", "settings"]
    for i = 0 to 5
        ic = CreateObject("roSGNode", "Poster")
        ic.width = 22
        ic.height = 22
        ic.loadDisplayMode = "scaleToFit"
        ic.translation = [m.navX[i] + 12, 53]
        ic.uri = iconUri(m.navIconNames[i], "m")
        m.nav.appendChild(ic)
        m.navIcons.push(ic)
        l = CreateObject("roSGNode", "Label")
        l.text = m.tabNames[i]
        l.translation = [m.navX[i] + 40, 44]
        l.width = m.navW[i] - 44
        l.height = 40
        l.horizAlign = "left"
        l.vertAlign = "center"
        l.color = "0xB8C4C5"
        l.font = mkFont(18, true)
        m.nav.appendChild(l)
        m.navLabels.push(l)
    end for

    updatePlaylistLabel()
    m.cats.observeField("itemFocused", "onCatFocus")
    m.catTimer.observeField("fire", "onCatTimer")
    m.grid.observeField("itemSelected", "onGridSelect")
    m.cats.observeField("itemSelected", "onCatSelect")
    m.eps.observeField("itemSelected", "onEpSelect")
    m.homelist.observeField("itemSelected", "onHomeSelect")
    m.homerow.observeField("rowItemSelected", "onHomeRowSelect")
    m.chlist.observeField("itemSelected", "onChSelect")
    m.navTimer.observeField("fire", "onNavTimer")
    m.toastTimer.observeField("fire", "onToastTimer")
    m.sdeps.observeField("rowItemSelected", "onSdEpSelect")
    m.grid.observeField("itemFocused", "onGridFocus")
    m.epgTimer.observeField("fire", "onEpgTimer")
    m.autoTimer.observeField("fire", "onAutoTimer")
    m.trk.observeField("itemSelected", "onTrkSelect")
    m.guide.observeField("itemSelected", "onGuideSelect")
    m.guide.observeField("itemFocused", "onGuideFocus")
    m.chlist.observeField("itemFocused", "onChFocus")
    m.pbarTimer.observeField("fire", "onPbarTimer")
    m.pvTimer.observeField("fire", "onPvTimer")
    m.gdTimer.observeField("fire", "onGdTimer")
    buildModeChips()
    buildSearchBtn()
    m.web.observeField("ready", "onWebReady")
    m.web.observeField("newSource", "onNewSource")
    m.web.control = "run"
    m.list.observeField("itemSelected", "onListSelect")
    m.video.observeField("state", "onVideoState")
    m.tick = m.top.findNode("tick")
    m.tick.observeField("fire", "updateClock")
    m.tick.control = "start"
    updateClock()
    setPane("home")
    setArea("nav")
    updateNav()
    m.header.text = "Home"
    m.navTimer.control = "start"
end sub

' ---------- helpers ----------
function iconUri(name as string, variant as string) as string
    return "pkg:/images/ic_" + name + "_" + variant + ".png"
end function

function mkFont(size as integer, bold as boolean) as object
    f = CreateObject("roSGNode", "Font")
    f.uri = "font:SystemFontFile"
    if bold then f.uri = "font:BoldSystemFontFile"
    f.size = size
    return f
end function

' TV type scale: nothing smaller than 20 px at 1280x720, body 24, titles 34
sub applyFonts()
    m.header.font = mkFont(22, false)
    m.plname.font = mkFont(20, true)
    m.status.font = mkFont(20, true)
    m.hint.font = mkFont(20, false)
    m.top.findNode("clock").font = mkFont(24, false)
    m.dtitle.font = mkFont(34, true)
    m.dmeta.font = mkFont(22, false)
    m.dplot.font = mkFont(24, false)
    m.toast.font = mkFont(24, true)
    m.sdtitle.font = mkFont(34, true)
    m.sdmeta.font = mkFont(22, false)
    m.sdplot.font = mkFont(22, false)
    m.epg.font = mkFont(22, true)
end sub

function num(v as dynamic) as float
    t = type(v)
    if t = "roString" or t = "String" then return val(v)
    if t = "roInt" or t = "Integer" or t = "roInteger" or t = "LongInteger" or t = "roLongInteger" or t = "roFloat" or t = "Float" or t = "roDouble" or t = "Double" then return v
    return 0
end function

function firstOf(o as object, keys as object) as string
    for each k in keys
        v = o[k]
        if type(v) = "roString" or type(v) = "String" then
            if v <> "" then return v
        else if v <> invalid and s(v) <> "" then
            return s(v)
        end if
    end for
    return ""
end function

function goodUrl(u as dynamic) as string
    if type(u) = "roString" or type(u) = "String" then
        if Left(u, 4) = "http" then
            ' TMDB serves any size: ask for a small one so the Roku 3 doesn't load 600x900 posters
            if Instr(1, u, "image.tmdb.org/t/p/") > 0 then
                u = CreateObject("roRegex", "/t/p/[^/]+/", "").replace(u, "/t/p/w185/")
            end if
            return u
        end if
    end if
    return ""
end function

' best thumbnail the provider data offers
function pickPic(it as object) as string
    keys = ["stream_icon", "cover", "movie_image", "cover_big"]
    for each k in keys
        u = goodUrl(it[k])
        if u <> "" then return u
    end for
    bd = it.backdrop_path
    if type(bd) = "roArray" and bd.count() > 0 then return goodUrl(bd[0])
    return ""
end function

function shrinkUrl(u as string) as string
    if Instr(1, u, "image.tmdb.org/t/p/") > 0 then
        return CreateObject("roRegex", "/t/p/[^/]+/", "").replace(u, "/t/p/w185/")
    end if
    return u
end function

' portrait poster for tall slots (Home rows): episodes use their show's cover, never a wide thumbnail
function homePoster(rec as object) as string
    if rec.kind = "episode" then
        if rec.spic <> invalid and rec.spic <> "" then return shrinkUrl(rec.spic)
        return "pkg:/images/ph_series.png"
    end if
    return posterFor(rec)
end function

function posterFor(rec as object) as string
    if rec.pic <> invalid and rec.pic <> "" then return shrinkUrl(rec.pic)
    return "pkg:/images/ph_" + rec.kind + ".png"
end function

function gridContent(recs as object) as object
    c = CreateObject("roSGNode", "ContentNode")
    for each rec in recs
        n = c.createChild("ContentNode")
        n.hdPosterUrl = posterFor(rec)
        n.sdPosterUrl = posterFor(rec)
        n.title = itemLabel(rec)
        if favIndex(rec) >= 0 then n.rating = "fav"
    end for
    return c
end function

function makeContent(items as object) as object
    c = CreateObject("roSGNode", "ContentNode")
    for each t in items
        n = c.createChild("ContentNode")
        n.title = t
    end for
    return c
end function

function s(v as dynamic) as string
    t = type(v)
    if t = "roString" or t = "String" then return v
    if t = "roInt" or t = "Integer" or t = "roInteger" or t = "LongInteger" or t = "roLongInteger" then return Str(v).trim()
    if t = "roFloat" or t = "Float" or t = "roDouble" or t = "Double" then return Str(Int(v)).trim()
    return ""
end function

sub setInfo(txt as string)
    if m.catInfo = invalid then m.catInfo = ""
    if txt = "" then
        m.status.text = m.catInfo
    else if m.catInfo = "" then
        m.status.text = txt
    else
        m.status.text = m.catInfo + "  |  " + txt
    end if
end sub

sub updateClock()
    d = CreateObject("roDateTime")
    d.toLocalTime()
    h = d.getHours()
    ap = "AM"
    if h >= 12 then ap = "PM"
    h = h mod 12
    if h = 0 then h = 12
    mi = d.getMinutes()
    ms = mi.toStr()
    if mi < 10 then ms = "0" + ms
    m.clock.text = h.toStr() + ":" + ms + " " + ap
end sub

sub updateNav()
    m.pill.translation = [m.navX[m.tab + 1], 44]
    m.pill.width = m.navW[m.tab + 1]
    if m.area = "nav" then
        m.pill.color = "0xF5C400"
    else
        m.pill.color = "0x20383D"
    end if
    for i = 0 to 5
        if i = m.tab + 1 and m.area = "nav" then
            m.navLabels[i].color = "0x080D0F"
            m.navIcons[i].uri = iconUri(m.navIconNames[i], "d")
        else if i = m.tab + 1 then
            m.navLabels[i].color = "0xF5C400"
            m.navIcons[i].uri = iconUri(m.navIconNames[i], "g")
        else
            m.navLabels[i].color = "0xB8C4C5"
            m.navIcons[i].uri = iconUri(m.navIconNames[i], "m")
        end if
    end for
end sub

sub setPane(p as string)
    m.pane = p
    closeOverlays()
    m.cats.visible = (p = "browse")
    m.grid.visible = (p = "browse")
    m.eps.visible = (p = "eps")
    m.detail.visible = (p = "detail")
    m.pform.visible = (p = "form")
    m.sdetail.visible = (p = "sdetail")
    m.list.visible = (p = "list")
    m.header.visible = (p = "list")
    m.homelist.visible = (p = "home" and not m.homeIsRow)
    m.homerow.visible = (p = "home" and m.homeIsRow)
    layoutBrowse()
    applyLiveVisibility()
end sub

sub layoutBrowse()
    top = 120
    rows = 10
    if m.tab = 0 then
        top = 160
        rows = 9
    end if
    m.sbtn.translation = [100, top]
    m.cats.translation = [100, top + 54]
    m.cats.numRows = rows - 1
    m.grid.translation = [400, top]
    m.guide.translation = [400, top]
    m.chlist.translation = [390, top]
end sub

sub applyLiveVisibility()
    live = (m.tab = 0 and m.pane = "browse")
    m.sbtn.visible = (m.pane = "browse" and m.tab >= 0 and m.tab <= 2)
    m.lmodes.visible = live
    m.grid.visible = (m.pane = "browse") and not (live and m.liveMode <> 0)
    m.guide.visible = live and m.liveMode = 1
    m.chlist.visible = live and m.liveMode = 2
    m.epg.visible = live and m.liveMode <> 1
    if live and m.liveMode = 2 then
        m.epg.translation = [760, 410]
        m.epg.width = 420
        m.epg.height = 110
        m.epg.wrap = true
    else
        m.epg.translation = [400, 596]
        m.epg.width = 780
        m.epg.height = 28
        m.epg.wrap = false
    end if
    if not (live and m.liveMode = 2) then previewReset()
end sub

function rightNode() as object
    if m.tab = 0 then
        if m.liveMode = 1 then return m.guide
        if m.liveMode = 2 then return m.chlist
    end if
    return m.grid
end function

' give focus to the scene itself and make sure no hidden list still holds it (a held list swallows the arrow keys)
sub focusScene()
    m.cats.setFocus(false)
    m.grid.setFocus(false)
    m.chlist.setFocus(false)
    m.guide.setFocus(false)
    m.list.setFocus(false)
    m.homelist.setFocus(false)
    m.homerow.setFocus(false)
    m.eps.setFocus(false)
    m.sdeps.setFocus(false)
    m.trk.setFocus(false)
    m.video.setFocus(false)
    m.top.setFocus(true)
end sub

' hide every player overlay (bar, track / channel / episode panel, toast): called whenever the user leaves the player
sub closeOverlays()
    m.trk.visible = false
    m.trkbg.visible = false
    m.pbar.visible = false
    m.pbarTimer.control = "stop"
    hideToastNow()
end sub

sub setArea(area as string)
    print "AREA "; area
    if area <> "video" and area <> "tracks" and area <> "pbar" then closeOverlays()
    m.area = area
    if area = "nav" then
        focusScene()
    else if area = "cats" then
        m.cats.setFocus(true)
    else if area = "modes" or area = "search" then
        focusScene()
    else if area = "pbar" then
        focusScene()
    else if area = "grid" then
        rightNode().setFocus(true)
    else if area = "eps" then
        m.eps.setFocus(true)
    else if area = "list" then
        m.list.setFocus(true)
    else if area = "pform" then
        focusScene()
    else if area = "detail" then
        focusScene()
    else if area = "sdbtn" or area = "sdseason" then
        focusScene()
    else if area = "sdeps" then
        m.sdeps.setFocus(true)
    else if area = "tracks" then
        m.trk.setFocus(true)
    else if area = "autonext" then
        focusScene()
    else if area = "home" then
        if m.homeIsRow then
            m.homerow.setFocus(true)
        else
            m.homelist.setFocus(true)
        end if
    end if
    hints = { search: "OK: search by name    Down: categories    Right: titles    Up: menu    Back: menu", modes: "Left/Right: switch view    Down: open    Up: menu    Back: menu", pbar: "Left/Right: choose    OK: open    Back: hide", nav: "Left/Right: browse    Down: open    Back: exit", cats: "OK: open    Right: titles    Up: menu    Back: menu", grid: "OK: open    *: favourite    Play/Pause: sort    Left or Back: categories", eps: "OK: play    Left or Back: details", detail: "OK: choose    Up/Down: move    *: favourite on/off    Back: return", sdbtn: "OK: choose    Left/Right: move    Down: seasons    *: favourite on/off    Back: return", sdseason: "Left/Right: season    Down: episodes    Up: buttons    Back: return", sdeps: "OK: play    *: mark watched    Left/Right: episodes    Up: seasons    Back: return", tracks: "OK: choose    Back: close", autonext: "Back: cancel auto-play", home: "OK: play or open    *: remove from row    Up: menu" }
    h = hints[area]
    if area = "cats" and m.tab >= 0 and m.tab <= 2 then h = "OK: open    Right: titles    *: hide category    Up: menu    Back: menu"
    if area = "grid" and m.tab = 4 then h = "OK: open    Left or Back: results"
    if area = "grid" and m.tab = 0 and m.liveMode = 1 then h = "OK: watch    *: favourite    Left or Back: categories    Up: views"
    if area = "grid" and m.tab = 0 and m.liveMode = 2 then h = "OK: full screen    *: favourite    Left or Back: categories    Up: views"
    if area = "list" and m.mode = "settings" then h = "OK: open or change    Up: menu    Back: menu"
    if area = "list" then
        h = "OK: select     Back: cancel"
        if m.mode = "settings" then h = "OK: open or change    Up: menu    Back: menu"
        if m.mode = "sources" then h = "OK: refresh, edit or remove    *: remove    Up: menu    Back: menu"
    end if
    if h = invalid then h = ""
    m.hint.text = h
    renderModes()
    renderSearchBtn()
    if area = "sdbtn" or area = "sdseason" then renderSdChips()
    if area = "detail" then renderDetailChips()
    if area = "pform" then renderPForm()
    updateNav()
end sub

sub onWebReady()
    if not m.web.ready then return
    ips = CreateObject("roDeviceInfo").getIPAddrs()
    for each k in ips
        if ips[k] <> "" and m.phoneUrl = "" then m.phoneUrl = "http://" + ips[k] + ":8888"
    end for
end sub

sub onNewSource(event as object)
    src = event.getData()
    if src = invalid then return
    addSource(src)
    saved = m.sources[m.sources.count() - 1]
    if saved.server = invalid or saved.server = "" then
        m.sources.pop()
        m.status.text = "Link needs a username and password"
        return
    end if
    m.active = m.sources.count() - 1
    saveSources()
    m.catCache = {}
    m.loadedTab = -1
    doRefresh()
end sub

' ---------- storage ----------
sub loadSources()
    sec = CreateObject("roRegistrySection", "tvone")
    if sec.exists("sources") then
        r = ParseJson(sec.read("sources"))
        if type(r) = "roArray" then m.sources = r
    end if
    if sec.exists("active") then m.active = val(sec.read("active"))
    if m.sources.count() = 0 then
        seed = ParseJson(ReadAsciiFile("pkg:/config/seed.json"))
        if seed <> invalid and seed.sources <> invalid then
            for each src in seed.sources
                addSource(src)
            end for
            saveSources()
        end if
    end if
end sub

sub saveSources()
    sec = CreateObject("roRegistrySection", "tvone")
    sec.write("sources", FormatJson(m.sources))
    sec.write("active", m.active.toStr())
    sec.flush()
end sub

sub addSource(src as object)
    if src.type = "m3u" then
        re = CreateObject("roRegex", "^(https?://[^/]+)/.*[?&]username=([^&]+).*[?&]password=([^&]+)", "i")
        mt = re.match(src.url)
        if mt.count() = 4 then
            src.server = mt[1]
            src.username = mt[2]
            src.password = mt[3]
        end if
    end if
    m.sources.push(src)
end sub

function activeSource() as dynamic
    if m.sources.count() = 0 then return invalid
    if m.active >= m.sources.count() then m.active = 0
    src = m.sources[m.active]
    if src.server = invalid or src.server = "" then return invalid
    return src
end function

function apiUrl(src as object, query as string) as string
    return src.server + "/player_api.php?username=" + src.username + "&password=" + src.password + query
end function

' ---------- network ----------
sub request(url as string, kind as string)
    m.reqSeq = m.reqSeq + 1
    t = CreateObject("roSGNode", "ApiTask")
    t.tag = kind + "|" + m.reqSeq.toStr()
    m.curTag = t.tag
    t.observeField("result", "onApi")
    t.url = url
    m.task = t
    t.control = "run"
end sub

sub onApi(event as object)
    t = event.getRoSGNode()
    if t.tag <> m.curTag then
        k0 = Left(t.tag, Instr(1, t.tag, "|") - 1)
        if k0 = "rc" or k0 = "ri" then m.recsBusy = false
        if k0 = "gd" then m.gdBusy = false
        return
    end if
    r = t.result
    kind = Left(t.tag, Instr(1, t.tag, "|") - 1)
    if r.error <> "" then
        if Left(kind, 3) = "epg" then return
        if kind = "rc" or kind = "ri" then
            m.recsBusy = false
            return
        end if
        if kind = "sinfo" or kind = "vinfo" then
            m.status.text = "Could not load details"
            return
        end if
        if kind = "rf" then
            m.status.text = "Refresh failed: " + Left(r.error, 16)
            return
        end if
        m.status.text = "Could not load: " + Left(r.error, 20)
        if kind = "cats" then m.cats.content = makeContent(["(failed)"])
        if kind = "srch" and m.srch <> invalid then
            m.srch.idx = m.srch.idx + 1
            runSearchStep()
        end if
        if kind = "gd" then
            m.gdBusy = false
            guideNext()
            return
        end if
        if kind = "acct" then
            acctNext(m.acctIdx + 1)
            return
        end if
        if kind = "gs" and m.gsRun then
            m.gsI = m.gsI + 1
            gsStep()
        end if
        if kind = "gscat" and m.gsRun then
            storeCats(m.gsCatT, invalid)
            gsPrepare()
        end if
        return
    end if
    data = ParseJson(r.body)
    if kind = "cats" then
        onCats(data, r)
    else if kind = "items" then
        onItems(data, r)
    else if kind = "sinfo" then
        onEpisodes(data, r)
    else if kind = "vinfo" then
        onVodInfo(data)
    else if kind = "srch" then
        onSearchData(data)
    else if kind = "gd" then
        onGdData(data)
    else if kind = "gs" then
        onGsData(data)
    else if kind = "gscat" then
        storeCats(m.gsCatT, data)
        gsPrepare()
    else if kind = "acct" then
        onAccount(data)
    else if kind = "rf" then
        onRefreshData(data)
    else if kind = "rc" then
        onRecCats(data)
    else if kind = "ri" then
        onRecItems(data)
    else if kind = "epg" then
        onEpg(data, false)
    else if kind = "epgp" then
        onEpg(data, true)
    end if
end sub

' ---------- browse tabs ----------
sub onNavTimer()
    if m.area <> "nav" then return
    openTab(true)
end sub

sub openTab(auto as boolean)
    m.navTimer.control = "stop"
    m.loadedTab = m.tab
    m.catInfo = ""
    m.status.text = ""
    m.video.control = "stop"
    previewReset()
    m.mode = ""
    if m.tab = -1 then
        showHome(not auto)
        return
    end if
    m.gsRun = false
    if m.tab = 3 then
        showSources(not auto)
        return
    end if
    if m.tab = 4 then
        showSettings(not auto)
        return
    end if
    src = activeSource()
    if src = invalid then
        setPane("browse")
        m.status.text = "No playlist yet: open Settings, then Playlists"
        return
    end if
    setPane("browse")
    if m.tab = 0 then
        m.grid.itemSize = [104, 134]
        m.grid.itemSpacing = [14, 10]
        m.grid.numColumns = 6
        m.grid.numRows = 3
    else
        m.grid.itemSize = [128, 208]
        m.grid.itemSpacing = [14, 12]
        m.grid.numColumns = 5
        m.grid.numRows = 2
    end if
    m.grid.content = invalid
    m.header.text = m.tabNames[m.tab + 1] + " - " + src.name
    cache = m.catCache[m.tab.toStr()]
    if cache <> invalid then
        m.catIds = cache.ids
        m.cats.content = catContent(cache.names)
        m.cats.jumpToItem = catPos(cache.last)
        m.header.text = m.tabNames[m.tab + 1] + " - " + (cache.names.count() - 1).toStr() + " categories"
        m.catInfo = (cache.names.count() - 1).toStr() + " categories"
        setInfo("")
        m.catTimer.control = "start"
    else
        actions = ["get_live_categories", "get_vod_categories", "get_series_categories"]
        m.catIds = []
        m.cats.content = makeContent(["Loading..."])
        request(apiUrl(src, "&action=" + actions[m.tab]), "cats")
    end if
    if not auto then
        if m.tab = 0 then
            setArea("modes")
        else
            setArea("cats")
        end if
    end if
end sub

sub onCats(data as dynamic, r as object)
    if type(data) <> "roArray" then
        m.cats.content = makeContent(["(no categories)"])
        m.status.text = "Server error (HTTP " + r.code.toStr() + ")"
        return
    end if
    cache = storeCats(m.tab, data)
    names = cache.names
    m.catIds = cache.ids
    m.cats.content = catContent(names)
    last = cache.last
    m.cats.jumpToItem = catPos(last)
    m.header.text = m.tabNames[m.tab + 1] + " - " + (names.count() - 1).toStr() + " categories"
    m.catInfo = (names.count() - 1).toStr() + " categories"
    setInfo("")
    m.catTimer.control = "start"
end sub

sub onCatFocus()
    m.srch = invalid
    if m.tab < 0 or m.tab > 2 then return
    if m.tab <= 2 then
        cache = m.catCache[m.tab.toStr()]
        if cache <> invalid and m.cats.itemFocused >= 0 then cache.last = m.cats.itemFocused + 1
    end if
    m.catTimer.control = "stop"
    m.catTimer.control = "start"
end sub

sub onCatTimer()
    if m.tab < 0 or m.tab > 2 or m.pane <> "browse" then return
    if m.cats.itemFocused < 0 then return
    i = m.cats.itemFocused + 1
    if i >= m.catIds.count() then return
    if m.tab = 4 then
        v = m.catIds[i]
        if m.gsRes <> invalid and (v = "all" or v = "live" or v = "movie" or v = "series") then
            m.gsView = v
            gsShowView(v)
        end if
        return
    end if
    if m.catIds[i] = "__search" then
        m.grid.content = invalid
        m.status.text = "Press OK to search"
        return
    end if
    src = activeSource()
    if src = invalid then return
    actions = ["get_live_streams", "get_vod_streams", "get_series"]
    setInfo("Loading...")
    request(apiUrl(src, "&action=" + actions[m.tab] + "&category_id=" + m.catIds[i]), "items")
end sub

sub onItems(data as dynamic, r as object)
    if type(data) <> "roArray" then
        m.grid.content = invalid
        m.status.text = "No items (HTTP " + r.code.toStr() + ")"
        return
    end if
    c = CreateObject("roSGNode", "ContentNode")
    m.items = []
    total = data.count()
    for each it in data
        if m.items.count() >= m.maxItems then exit for
        n = c.createChild("ContentNode")
        pic = pickPic(it)
        if m.tab = 2 then
            rec = { kind: "series", name: s(it.name), id: s(it.series_id), ext: "", pic: pic, added: num(it.last_modified), rating: num(it.rating) }
        else if m.tab = 0 then
            rec = { kind: "live", name: s(it.name), id: s(it.stream_id), ext: "", pic: pic, added: num(it.added), rating: 0 }
        else
            rec = { kind: "movie", name: s(it.name), id: s(it.stream_id), ext: s(it.container_extension), pic: pic, added: num(it.added), rating: num(it.rating) }
        end if
        n.hdPosterUrl = posterFor(rec)
        n.sdPosterUrl = posterFor(rec)
        n.title = itemLabel(rec)
        if favIndex(rec) >= 0 then n.rating = "fav"
        m.items.push(rec)
    end for
    m.grid.content = c
    m.grid.jumpToItem = 0
    m.sortMode = 0
    m.itemsOrig = []
    for each rr in m.items
        m.itemsOrig.push(rr)
    end for
    if m.set.sort > 0 and m.items.count() > 1 then
        m.sortMode = m.set.sort - 1
        cycleSort()
    end if
    if total > m.maxItems then
        setInfo("Showing " + m.maxItems.toStr() + " of " + total.toStr())
    else
        setInfo(total.toStr() + " items")
    end if
    if m.tab = 0 then buildLiveViews()
end sub

sub onChSelect()
    playIndex(m.chlist.itemSelected)
end sub

sub onGridSelect()
    playIndex(m.grid.itemSelected)
end sub

sub playIndex(i as integer)
    if i < 0 or i >= m.items.count() then return
    it = m.items[i]
    m.playIdx = -1
    m.fromHome = false
    if it.kind = "live" then
        m.playIdx = i
        startPlayback(it, "grid")
    else if it.kind = "episode" then
        startPlayback(it, "grid")
    else
        openDetail(it)
    end if
end sub

sub cycleSort()
    if m.items.count() < 2 then return
    m.sortMode = (m.sortMode + 1) mod 4
    names = ["provider order", "A-Z", "newest first", "highest rated"]
    if m.sortMode = 0 then
        m.items = []
        for each rr in m.itemsOrig
            m.items.push(rr)
        end for
    else if m.sortMode = 1 then
        m.items.sortBy("name", "i")
    else if m.sortMode = 2 then
        m.items.sortBy("added", "r")
    else
        m.items.sortBy("rating", "r")
    end if
    m.grid.content = gridContent(m.items)
    m.grid.jumpToItem = 0
    m.status.text = "Sorted: " + names[m.sortMode]
    if m.tab = 0 then buildLiveViews()
end sub

' ---------- detail page ----------
sub openDetail(rec as object)
    src = activeSource()
    if src = invalid then return
    if rec.kind = "series" then
        openSeriesDetail(rec)
        return
    end if
    m.detailRec = rec
    m.dIdx = 0
    m.epItems = []
    m.curSeries = rec.name
    m.curPic = ""
    if rec.pic <> invalid then m.curPic = rec.pic
    m.dposter.uri = posterFor(rec)
    m.dtitle.text = rec.name
    m.dmeta.text = ""
    m.dplot.text = ""
    m.header.text = ""
    m.status.text = "Loading details..."
    refreshDetailButtons()
    setPane("detail")
    setArea("detail")
    if rec.kind = "series" then
        request(apiUrl(src, "&action=get_series_info&series_id=" + rec.id), "sinfo")
    else
        request(apiUrl(src, "&action=get_vod_info&vod_id=" + rec.id), "vinfo")
    end if
end sub

sub fillInfo(info as object)
    if type(info) <> "roAssociativeArray" then return
    parts = []
    y = firstOf(info, ["releasedate", "releaseDate", "release_date", "year"])
    if Len(y) >= 4 then parts.push(Left(y, 4))
    rt = firstOf(info, ["rating", "rating_5based"])
    if rt <> "" and rt <> "0" then parts.push("Rating " + rt)
    g = firstOf(info, ["genre"])
    if g <> "" then parts.push(g)
    du = firstOf(info, ["duration", "episode_run_time"])
    if du <> "" then parts.push(du)
    txt = ""
    for i = 0 to parts.count() - 1
        if i > 0 then txt = txt + "   |   "
        txt = txt + parts[i]
    end for
    m.dmeta.text = txt
    plot = firstOf(info, ["plot", "description"])
    ct = firstOf(info, ["cast", "actors"])
    dr = firstOf(info, ["director"])
    if Len(plot) > 480 then plot = Left(plot, 477) + "..."
    if plot = "" then plot = "No description from the provider."
    if ct <> "" then plot = plot + chr(10) + chr(10) + "Cast: " + Left(ct, 160)
    if dr <> "" then plot = plot + chr(10) + "Director: " + Left(dr, 80)
    m.dplot.text = plot
    pu = goodUrl(firstOf(info, ["movie_image", "cover_big", "cover"]))
    if pu <> "" then m.dposter.uri = pu
end sub

sub onVodInfo(data as dynamic)
    m.status.text = ""
    if type(data) <> "roAssociativeArray" then
        m.dplot.text = "No details available."
        return
    end if
    if data.info <> invalid then fillInfo(data.info)
end sub

sub refreshDetailButtons()
    rec = m.detailRec
    if rec = invalid then return
    labels = []
    m.dacts = []
    if rec.kind = "series" then
        if m.epItems.count() > 0 then
            labels.push("Episodes (" + m.epItems.count().toStr() + ")")
            m.dacts.push("eps")
        else
            labels.push("Loading episodes...")
            m.dacts.push("none")
        end if
    else
        r = findRecent(rec)
        if r >= 0 and m.recent[r].pos <> invalid and m.recent[r].pos > 20 then
            p = Int(m.recent[r].pos)
            labels.push("Resume at " + Int(p / 60).toStr() + ":" + Right("0" + (p mod 60).toStr(), 2))
            m.dacts.push("play")
            labels.push("Play from start")
            m.dacts.push("restart")
        else
            labels.push("Play")
            m.dacts.push("play")
        end if
    end if
    if favIndex(rec) >= 0 then
        labels.push("In favourites")
    else
        labels.push("Add to favourites")
    end if
    m.dacts.push("fav")
    m.dfav.visible = (favIndex(rec) >= 0)
    m.dfavbg.visible = m.dfav.visible
    icons = []
    for each a in m.dacts
        if a = "play" then
            icons.push("play")
        else if a = "restart" then
            icons.push("rotate-ccw")
        else if a = "fav" then
            if favIndex(rec) >= 0 then
                icons.push("heart-fill")
            else
                icons.push("heart")
            end if
        else
            icons.push("tv-minimal-play")
        end if
    end for
    m.dLabels = labels
    m.dIcons = icons
    if m.dIdx >= labels.count() then m.dIdx = 0
    if m.area = "detail" then renderDetailChips()
end sub

sub detailAction(i as integer)
    if i < 0 or i >= m.dacts.count() then return
    act = m.dacts[i]
    rec = m.detailRec
    if rec = invalid then return
    if act = "play" then
        startPlayback(rec, "detail")
    else if act = "restart" then
        m.noResume = true
        startPlayback(rec, "detail")
    else if act = "fav" then
        toggleFav(rec)
        refreshDetailButtons()
    else if act = "eps" then
        setPane("eps")
        setArea("eps")
        m.status.text = "OK plays an episode"
    end if
end sub

sub closeDetail()
    m.detailRec = invalid
    m.status.text = ""
    if m.fromHome then
        showHome(true)
    else
        setPane("browse")
        setArea("grid")
        m.header.text = m.tabNames[m.tab + 1]
    end if
end sub



sub openSeriesDetail(rec as object)
    src = activeSource()
    m.detailRec = rec
    m.curSeries = rec.name
    m.curPic = ""
    if rec.pic <> invalid then m.curPic = rec.pic
    m.seasonKeys = []
    m.epSeason = {}
    m.sdposter.uri = posterFor(rec)
    m.sdtitle.text = rec.name
    m.sdmeta.text = ""
    m.sdplot.text = ""
    m.header.text = ""
    m.status.text = "Loading episodes..."
    m.seasonLabels = []
    m.sdBtnIdx = 0
    m.curSeasonIdx = 0
    m.sdeps.visible = false
    m.sdeps.content = invalid
    refreshSdButtons()
    setPane("sdetail")
    setArea("sdbtn")
    request(apiUrl(src, "&action=get_series_info&series_id=" + rec.id), "sinfo")
end sub

function chipWidth(label as string, icon as string) as integer
    if icon = "" then return Len(label) * 11 + 44
    return Len(label) * 11 + 78
end function

sub addChip(group as object, x as integer, label as string, mode as integer, icon as string, y = 0 as integer, fixedW = 0 as integer)
    w = chipWidth(label, icon)
    if fixedW > 0 then w = fixedW
    if mode = 2 then
        r = CreateObject("roSGNode", "Rectangle")
        r.color = "0xF5C400"
        r.width = w + 6
        r.height = 46
        r.translation = [x - 3, y - 3]
        group.appendChild(r)
    end if
    bg = CreateObject("roSGNode", "Rectangle")
    bg.width = w
    bg.height = 40
    bg.translation = [x, y]
    bg.color = "0x101A1D"
    tc = "0xB8C4C5"
    iv = "m"
    if mode = 1 then
        bg.color = "0x294D53"
        tc = "0xF5C400"
        iv = "g"
    else if mode = 2 then
        bg.color = "0x294D53"
        tc = "0xFFFFFF"
        iv = "w"
    end if
    group.appendChild(bg)
    lb = CreateObject("roSGNode", "Label")
    lb.text = label
    lb.height = 40
    lb.vertAlign = "center"
    lb.color = tc
    lb.font = mkFont(19, true)
    if icon <> "" then
        pic = CreateObject("roSGNode", "Poster")
        pic.width = 22
        pic.height = 22
        pic.loadDisplayMode = "scaleToFit"
        pic.translation = [x + 16, y + 9]
        pic.uri = iconUri(icon, iv)
        group.appendChild(pic)
        lb.width = w - 54
        lb.translation = [x + 46, y]
        lb.horizAlign = "left"
    else
        lb.width = w
        lb.translation = [x, y]
        lb.horizAlign = "center"
    end if
    group.appendChild(lb)
end sub

sub renderChipRow(group as object, labels as object, icons as object, sel as integer, foc as integer)
    group.removeChildrenIndex(group.getChildCount(), 0)
    x = 6
    for i = 0 to labels.count() - 1
        mode = 0
        if i = sel then mode = 1
        if i = foc then mode = 2
        ic = ""
        if i < icons.count() then ic = icons[i]
        addChip(group, x, labels[i], mode, ic, 0, 0)
        x = x + chipWidth(labels[i], ic) + 14
    end for
end sub

sub renderDetailChips()
    m.dbtns.removeChildrenIndex(m.dbtns.getChildCount(), 0)
    for i = 0 to m.dLabels.count() - 1
        mode = 0
        if m.area = "detail" and i = m.dIdx then mode = 2
        addChip(m.dbtns, 6, m.dLabels[i], mode, m.dIcons[i], i * 56 + 3, 380)
    end for
end sub

sub renderSdChips()
    fb = -1
    if m.area = "sdbtn" then fb = m.sdBtnIdx
    renderChipRow(m.sdbtns, m.sdBtnLabels, m.sdBtnIcons, -1, fb)
    fs = -1
    if m.area = "sdseason" then fs = m.curSeasonIdx
    renderChipRow(m.sdseasons, m.seasonLabels, [], m.curSeasonIdx, fs)
end sub

function seriesStarted() as boolean
    for each r in m.recent
        if r.kind = "episode" and r.series = m.curSeries then return true
    end for
    for each k in m.seasonKeys
        for each ep in m.epSeason[k]
            if isWatched(ep) then return true
        end for
    end for
    return false
end function

sub refreshSdButtons()
    rec = m.detailRec
    if rec = invalid then return
    lab = "Add to favourites"
    if favIndex(rec) >= 0 then lab = "In favourites"
    m.sdfav.visible = (favIndex(rec) >= 0)
    m.sdfavbg.visible = m.sdfav.visible
    first = "Play"
    tgt = continueTarget()
    if tgt <> invalid and seriesStarted() then first = "Continue S" + tgt.season + " E" + tgt.num
    m.sdBtnLabels = [first, lab]
    favIcon = "heart"
    if favIndex(rec) >= 0 then favIcon = "heart-fill"
    m.sdBtnIcons = ["play", favIcon]
    if m.sdBtnIdx > 1 then m.sdBtnIdx = 0
    if m.area = "sdbtn" or m.area = "sdseason" then renderSdChips()
end sub

function durText(secs as dynamic) as string
    if secs = invalid or secs <= 0 then return ""
    return "   " + Int(secs / 60).toStr() + " min"
end function

sub onEpisodes(data as dynamic, r as object)
    if type(data) <> "roAssociativeArray" or data.episodes = invalid then
        m.status.text = "No episodes (HTTP " + r.code.toStr() + ")"
        return
    end if
    ' providers send episodes keyed by season, or as a list: accept both
    eps = {}
    if type(data.episodes) = "roAssociativeArray" then
        eps = data.episodes
    else if type(data.episodes) = "roArray" then
        n = 0
        for each item in data.episodes
            n = n + 1
            if type(item) = "roArray" then
                eps[n.toStr()] = item
            else if type(item) = "roAssociativeArray" then
                sk = s(item.season)
                if sk = "" then sk = "1"
                if eps[sk] = invalid then eps[sk] = []
                eps[sk].push(item)
            end if
        end for
    end if
    keys = []
    for each k in eps
        keys.push(k)
    end for
    if keys.count() = 0 then
        m.status.text = "No episodes from provider"
        return
    end if
    for a = 1 to keys.count() - 1
        j = a
        while j > 0 and val(keys[j]) < val(keys[j - 1])
            tmp = keys[j]
            keys[j] = keys[j - 1]
            keys[j - 1] = tmp
            j = j - 1
        end while
    end for
    m.seasonKeys = keys
    m.epSeason = {}
    labels = []
    total = 0
    for each k in keys
        list = []
        for each ep in eps[k]
            nm = s(ep.title)
            ext = s(ep.container_extension)
            if ext = "" then ext = "mp4"
            epPic = ""
            dur = 0
            einfo = ep.info
            if type(einfo) = "roAssociativeArray" then
                epPic = goodUrl(einfo.movie_image)
                dur = num(einfo.duration_secs)
            end if
            if epPic = "" then epPic = m.curPic
            en = s(ep.episode_num)
            list.push({ kind: "episode", id: s(ep.id), ext: ext, title: nm, num: en, season: k, name: "S" + k + " E" + en + "  " + nm, series: m.curSeries, pic: epPic, spic: m.curPic, dur: dur })
            total = total + 1
        end for
        m.epSeason[k] = list
        labels.push("Season " + k)
    end for
    if data.info <> invalid then fillSeriesInfo(data.info, keys.count(), total)
    m.seasonLabels = labels
    idx = 0
    tgt = continueTarget()
    if tgt <> invalid then
        for i = 0 to keys.count() - 1
            if keys[i] = tgt.season then idx = i
        end for
    end if
    showSeason(idx)
    m.status.text = ""
    refreshSdButtons()
end sub

sub fillSeriesInfo(info as object, seasons as integer, total as integer)
    if type(info) <> "roAssociativeArray" then return
    parts = []
    y = firstOf(info, ["releaseDate", "releasedate", "release_date", "year"])
    if Len(y) >= 4 then parts.push(Left(y, 4))
    rt = firstOf(info, ["rating", "rating_5based"])
    if rt <> "" and rt <> "0" then parts.push("Rating " + rt)
    g = firstOf(info, ["genre"])
    if g <> "" then parts.push(g)
    parts.push(seasons.toStr() + " seasons, " + total.toStr() + " episodes")
    txt = ""
    for i = 0 to parts.count() - 1
        if i > 0 then txt = txt + "   |   "
        txt = txt + parts[i]
    end for
    m.sdmeta.text = txt
    plot = firstOf(info, ["plot", "description"])
    if Len(plot) > 230 then plot = Left(plot, 227) + "..."
    m.sdplot.text = plot
    pu = goodUrl(firstOf(info, ["cover", "cover_big", "movie_image"]))
    if pu <> "" then m.sdposter.uri = pu
end sub

sub showSeason(i as integer)
    if i < 0 or i >= m.seasonKeys.count() then return
    k = m.seasonKeys[i]
    list = m.epSeason[k]
    if list = invalid then return
    c = CreateObject("roSGNode", "ContentNode")
    row = c.createChild("ContentNode")
    for each ep in list
        n = row.createChild("ContentNode")
        n.title = ep.title
        n.shortdescriptionline1 = "S" + k + " E" + ep.num + durText(ep.dur)
        n.shortdescriptionline2 = "E" + ep.num
        n.hdPosterUrl = posterFor(ep)
        if isWatched(ep) then n.rating = "watched"
        rr = findRecent(ep)
        if rr >= 0 and m.recent[rr].pos <> invalid and m.recent[rr].dur <> invalid then
            n.playStart = Int(m.recent[rr].pos)
            n.length = Int(m.recent[rr].dur)
        end if
    end for
    m.sdeps.content = c
    m.sdeps.visible = true
    m.curSeasonIdx = i
    if m.area = "sdbtn" or m.area = "sdseason" then renderSdChips()
end sub



sub sdAction(i as integer)
    if i = 0 then
        tgt = continueTarget()
        if tgt = invalid then
            m.status.text = "No episodes to play yet"
        else
            startPlayback(tgt, "sdeps")
        end if
    else
        toggleFav(m.detailRec)
        refreshSdButtons()
    end if
end sub

sub toggleWatchedFocused()
    rc = m.sdeps.rowItemFocused
    if m.curSeasonIdx < 0 or m.curSeasonIdx >= m.seasonKeys.count() then return
    list = m.epSeason[m.seasonKeys[m.curSeasonIdx]]
    if list = invalid then return
    c = rc[1]
    if c < 0 or c >= list.count() then return
    ep = list[c]
    key = ep.kind + ":" + ep.id
    if m.watched[key] <> invalid then
        m.watched.delete(key)
        m.status.text = "Marked unwatched"
    else
        m.watched[key] = 1
        removeRecent(ep)
        m.status.text = "Marked watched"
    end if
    saveWatched()
    showSeason(m.curSeasonIdx)
    m.sdeps.jumpToRowItem = [0, c]
    refreshSdButtons()
end sub

sub onSdEpSelect()
    rc = m.sdeps.rowItemSelected
    if m.curSeasonIdx < 0 or m.curSeasonIdx >= m.seasonKeys.count() then return
    list = m.epSeason[m.seasonKeys[m.curSeasonIdx]]
    if list = invalid then return
    c = rc[1]
    if c < 0 or c >= list.count() then return
    startPlayback(list[c], "sdeps")
end sub


function continueTarget() as dynamic
    for each r in m.recent
        if r.kind = "episode" and r.series = m.curSeries then
            for each k in m.seasonKeys
                for each ep in m.epSeason[k]
                    if ep.id = r.id then return ep
                end for
            end for
        end if
    end for
    for each k in m.seasonKeys
        for each ep in m.epSeason[k]
            if not isWatched(ep) then return ep
        end for
    end for
    if m.seasonKeys.count() > 0 then
        l = m.epSeason[m.seasonKeys[0]]
        if l.count() > 0 then return l[0]
    end if
    return invalid
end function

function nextEpisode(rec as object) as dynamic
    if rec.series <> m.curSeries then return invalid
    for si = 0 to m.seasonKeys.count() - 1
        list = m.epSeason[m.seasonKeys[si]]
        for j = 0 to list.count() - 1
            if list[j].id = rec.id then
                if j + 1 < list.count() then return list[j + 1]
                if si + 1 < m.seasonKeys.count() then
                    nl = m.epSeason[m.seasonKeys[si + 1]]
                    if nl.count() > 0 then return nl[0]
                end if
                return invalid
            end if
        end for
    end for
    return invalid
end function


sub onEpSelect()
    i = m.eps.itemSelected
    if i < 0 or i >= m.epItems.count() then return
    startPlayback(m.epItems[i], "eps")
end sub


' ---------- home recommendations ----------
sub loadRecs()
    if m.recsBusy or m.recsLoaded then return
    if activeSource() = invalid then return
    m.recsBusy = true
    m.rc = { i: 0, cat: "" }
    recStep(0)
end sub

sub recStep(phase as integer)
    src = activeSource()
    if src = invalid then
        m.recsBusy = false
        return
    end if
    cats = ["get_vod_categories", "get_series_categories", "get_live_categories"]
    items = ["get_vod_streams", "get_series", "get_live_streams"]
    if phase = 0 then
        request(apiUrl(src, "&action=" + cats[m.rc.i]), "rc")
    else
        request(apiUrl(src, "&action=" + items[m.rc.i] + "&category_id=" + m.rc.cat), "ri")
    end if
end sub

sub onRecCats(data as dynamic)
    best = ""
    first = ""
    if type(data) = "roArray" then
        re = CreateObject("roRegex", "new|latest|recent|fresh|2026|2025|release", "i")
        for each c in data
            id = s(c.category_id)
            if id <> "" then
                if first = "" then first = id
                if best = "" and re.isMatch(s(c.category_name)) then best = id
            end if
        end for
    end if
    if best = "" then best = first
    m.rc.cat = best
    if best = "" then
        nextRec()
    else
        recStep(1)
    end if
end sub

sub onRecItems(data as dynamic)
    keys = ["movies", "series", "live"]
    kinds = ["movie", "series", "live"]
    list = []
    if type(data) = "roArray" then
        n = 0
        for each it in data
            n = n + 1
            if n > 300 then exit for
            pic = pickPic(it)
            nm = s(it.name)
            if nm <> "" then
                if m.rc.i = 1 then
                    list.push({ kind: "series", name: nm, id: s(it.series_id), ext: "", pic: pic, added: num(it.last_modified) })
                else if m.rc.i = 2 then
                    list.push({ kind: "live", name: nm, id: s(it.stream_id), ext: "", pic: pic, added: 0 })
                else
                    list.push({ kind: "movie", name: nm, id: s(it.stream_id), ext: s(it.container_extension), pic: pic, added: num(it.added) })
                end if
            end if
        end for
    end if
    if m.rc.i < 2 then list.sortBy("added", "r")
    out = []
    for each r in list
        if out.count() >= 12 then exit for
        out.push(r)
    end for
    m.recs[keys[m.rc.i]] = out
    nextRec()
end sub

sub nextRec()
    m.rc.i = m.rc.i + 1
    if m.tab = -1 and m.pane = "home" and m.area = "nav" then showHome(false)
    if m.rc.i >= 3 then
        m.recsBusy = false
        m.recsLoaded = true
    else
        recStep(0)
    end if
end sub

' ---------- refresh playlist ----------
sub doRefresh()
    src = activeSource()
    if src = invalid then
        m.status.text = "No playlist yet: open Settings, then Playlists"
        return
    end if
    m.video.control = "stop"
    m.video.visible = false
    hideToastNow()
    m.srch = invalid
    m.catCache = {}
    m.items = []
    m.grid.content = invalid
    m.recs = { movies: [], series: [], live: [] }
    m.recsLoaded = false
    m.recsBusy = false
    m.rf = { step: 0, counts: [0, 0, 0] }
    updatePlaylistLabel()
    m.header.text = "Refreshing playlist"
    m.status.text = "Refreshing 1/4..."
    request(apiUrl(src, "&action=get_live_categories"), "rf")
end sub

sub onRefreshData(data as dynamic)
    rf = m.rf
    if rf = invalid then return
    src = activeSource()
    if src = invalid then return
    actions = ["get_live_categories", "get_vod_categories", "get_series_categories", ""]
    if rf.step <= 2 then
        cache = storeCats(rf.step, data)
        rf.counts[rf.step] = cache.allN.count() - 1
        rf.step = rf.step + 1
        m.status.text = "Refreshing " + (rf.step + 1).toStr() + "/4..."
        request(apiUrl(src, "&action=" + actions[rf.step]), "rf")
    else
        acct = ""
        if type(data) = "roAssociativeArray" and data.user_info <> invalid then
            acct = s(data.user_info.status)
            m.sources[m.active].exp = Int(val(s(data.user_info.exp_date)))
        end if
        m.sources[m.active].refreshed = CreateObject("roDateTime").asSeconds()
        saveSources()
        m.loadedTab = -1
        m.tab = 0
        updateNav()
        openTab(false)
        updatePlaylistLabel()
        m.status.text = "Updated " + rf.counts[0].toStr() + " live | " + rf.counts[1].toStr() + " movie | " + rf.counts[2].toStr() + " series"
        m.rf = invalid
    end if
end sub

' ---------- tv guide (now and next) ----------
sub onGridFocus()
    if m.tab <> 0 or m.srch <> invalid then return
    m.epg.text = ""
    m.epgTimer.control = "stop"
    m.epgTimer.control = "start"
end sub

sub onEpgTimer()
    if m.tab <> 0 or m.pane <> "browse" or m.area <> "grid" or m.liveMode = 1 then return
    i = rightNode().itemFocused
    if i < 0 or i >= m.items.count() then return
    src = activeSource()
    if src = invalid then return
    request(apiUrl(src, "&action=get_short_epg&stream_id=" + m.items[i].id + "&limit=2"), "epg")
end sub

function b64(v as dynamic) as string
    sv = s(v)
    if sv = "" then return ""
    ba = CreateObject("roByteArray")
    ba.fromBase64String(sv)
    out = ba.toAsciiString()
    if out = "" then return sv
    return out
end function

function fmtStamp(ts as dynamic) as string
    d = CreateObject("roDateTime")
    d.fromSeconds(Int(num(ts)))
    d.toLocalTime()
    return d.getMonth().toStr() + "/" + d.getDayOfMonth().toStr() + " " + fmtTime(ts)
end function

sub updatePlaylistLabel()
    src = activeSource()
    txt = "Playlists"
    if src <> invalid then
        nm = src.name
        if Len(nm) > 12 then nm = Left(nm, 11) + "..."
        txt = "Playlists: " + nm
    end if
    m.plname.text = txt
end sub

function fmtTime(ts as dynamic) as string
    d = CreateObject("roDateTime")
    d.fromSeconds(Int(num(ts)))
    d.toLocalTime()
    h = d.getHours()
    ap = "AM"
    if h >= 12 then ap = "PM"
    h = h mod 12
    if h = 0 then h = 12
    mi = d.getMinutes()
    ms = mi.toStr()
    if mi < 10 then ms = "0" + ms
    return h.toStr() + ":" + ms + " " + ap
end function

sub onEpg(data as dynamic, forPlay as boolean)
    txt = ""
    if type(data) = "roAssociativeArray" and type(data.epg_listings) = "roArray" and data.epg_listings.count() > 0 then
        l = data.epg_listings
        txt = "Now: " + b64(l[0].title) + "  (" + fmtTime(l[0].start_timestamp) + " - " + fmtTime(l[0].stop_timestamp) + ")"
        if l.count() > 1 then txt = txt + "     Next: " + b64(l[1].title)
    else if not forPlay then
        txt = "No guide data for this channel"
    end if
    if forPlay then
        m.pbEpg = txt
        if m.pbar.visible then renderPlayerBar()
    else
        m.epg.text = txt
    end if
end sub

' ---------- account and source removal ----------
sub onAccount(data as dynamic)
    i = m.acctIdx
    if type(data) = "roAssociativeArray" and data.user_info <> invalid and i >= 0 and i < m.sources.count() then
        ui = data.user_info
        src = m.sources[i]
        src.exp = Int(val(s(ui.exp_date)))
        src.acctStatus = s(ui.status)
        src.conns = s(ui.max_connections)
        if i = m.active and m.mode = "sources" then
            txt = s(ui.status)
            if s(ui.max_connections) <> "" then txt = txt + "   " + s(ui.active_cons) + "/" + s(ui.max_connections) + " connections"
            m.status.text = txt
        end if
        refreshSourceRows()
    end if
    acctNext(i + 1)
end sub

sub openSourceMenu(i as integer)
    m.removeIdx = i
    d = CreateObject("roSGNode", "StandardMessageDialog")
    d.title = m.sources[i].name
    ex = expText(m.sources[i]).trim()
    if ex = "" then ex = "Expiry not known yet"
    d.message = [ex, "Refresh reloads channels, movies and series. Edit changes the name or link. Remove deletes it from this Roku."]
    d.buttons = ["Use and refresh", "Edit", "Remove", "Cancel"]
    d.observeField("buttonSelected", "onSourceMenu")
    m.dlg = d
    m.top.dialog = d
end sub

sub onSourceMenu()
    pick = m.dlg.buttonSelected
    m.dlg.close = true
    i = m.removeIdx
    if i < 0 or i >= m.sources.count() then return
    if pick = 0 then
        m.active = i
        saveSources()
        doRefresh()
    else if pick = 1 then
        editSource(i)
    else if pick = 2 then
        confirmRemove(i)
    end if
end sub

sub editSource(i as integer)
    src = m.sources[i]
    kind = "m3u"
    if src.type = "xtream" then kind = "xtream"
    startForm(kind)
    m.editSrc = i
    m.form.vals.name = src.name
    if kind = "m3u" then
        if src.url <> invalid then m.form.vals.url = src.url
    else
        if src.server <> invalid then m.form.vals.server = src.server
        if src.username <> invalid then m.form.vals.username = src.username
        if src.password <> invalid then m.form.vals.password = src.password
    end if
    renderPForm()
end sub

sub confirmRemove(i as integer)
    m.removeIdx = i
    d = CreateObject("roSGNode", "StandardMessageDialog")
    d.title = "Remove this playlist?"
    d.message = [m.sources[i].name, "It will be deleted from this Roku. Your provider account is not affected."]
    d.buttons = ["Remove", "Cancel"]
    d.observeField("buttonSelected", "onRemoveDialog")
    m.dlg = d
    m.top.dialog = d
end sub

sub onRemoveDialog()
    ok = (m.dlg.buttonSelected = 0)
    m.dlg.close = true
    if not ok or m.mode <> "sources" then return
    i = m.removeIdx
    if i < 0 or i >= m.sources.count() then return
    nm = m.sources[i].name
    m.sources.delete(i)
    if i < m.active then m.active = m.active - 1
    if m.active >= m.sources.count() then m.active = m.sources.count() - 1
    if m.active < 0 then m.active = 0
    saveSources()
    m.catCache = {}
    m.loadedTab = -1
    updatePlaylistLabel()
    showSources(true)
    m.status.text = "Removed: " + Left(nm, 24)
end sub

' ---------- search ----------
sub onCatSelect()
    if m.cats.itemSelected < 0 then return
    i = m.cats.itemSelected + 1
    if i >= m.catIds.count() then return
    if m.tab = 4 then
        v = m.catIds[i]
        if v = "__new" then
            openGsKeyboard()
        else if Left(v, 2) = "q:" then
            startGlobalSearch(Mid(v, 3))
        else if m.grid.content <> invalid then
            setArea("grid")
        end if
    else if m.catIds[i] = "__search" then
        openSearchKeyboard()
    else if m.grid.content <> invalid then
        setArea("grid")
    end if
end sub

sub openSearchKeyboard()
    m.kbMode = "search"
    m.kb = CreateObject("roSGNode", "StandardKeyboardDialog")
    m.kb.title = "Search " + m.tabNames[m.tab + 1]
    m.kb.text = ""
    m.kb.buttons = ["Search", "Cancel"]
    m.kb.observeField("buttonSelected", "onKeyboard")
    m.top.dialog = m.kb
end sub

sub startSearch(q as string)
    q = LCase(q.trim())
    if q = "" then return
    m.srch = { q: q, idx: 1, hits: [] }
    m.items = []
    m.grid.content = invalid
    m.header.text = m.tabNames[m.tab + 1] + " - search: " + q
    runSearchStep()
end sub

sub runSearchStep()
    sr = m.srch
    if sr = invalid then return
    total = m.catIds.count() - 1
    if sr.idx >= m.catIds.count() or sr.hits.count() >= 60 then
        m.status.text = sr.hits.count().toStr() + " results for " + Left(sr.q, 16)
        m.srch = invalid
        return
    end if
    src = activeSource()
    actions = ["get_live_streams", "get_vod_streams", "get_series"]
    m.status.text = "Searching " + sr.idx.toStr() + "/" + total.toStr() + ", " + sr.hits.count().toStr() + " found"
    request(apiUrl(src, "&action=" + actions[m.tab] + "&category_id=" + m.catIds[sr.idx]), "srch")
end sub

sub onSearchData(data as dynamic)
    sr = m.srch
    if sr = invalid then return
    added = false
    if type(data) = "roArray" then
        for each it in data
            if sr.hits.count() >= 60 then exit for
            nm = s(it.name)
            if Instr(1, LCase(nm), sr.q) > 0 then
                pic = pickPic(it)
                if m.tab = 2 then
                    rec = { kind: "series", name: nm, id: s(it.series_id), ext: "", pic: pic, added: num(it.last_modified), rating: num(it.rating) }
                else if m.tab = 0 then
                    rec = { kind: "live", name: nm, id: s(it.stream_id), ext: "", pic: pic, added: num(it.added), rating: 0 }
                else
                    rec = { kind: "movie", name: nm, id: s(it.stream_id), ext: s(it.container_extension), pic: pic, added: num(it.added), rating: num(it.rating) }
                end if
                sr.hits.push(rec)
                added = true
            end if
        end for
    end if
    if added then
        m.items = sr.hits
        m.itemsOrig = []
        for each rr in sr.hits
            m.itemsOrig.push(rr)
        end for
        m.sortMode = 0
        m.grid.content = gridContent(sr.hits)
    end if
    sr.idx = sr.idx + 1
    runSearchStep()
end sub

' ---------- playback ----------
sub startPlayback(rec as object, backTo as string)
    src = activeSource()
    if src = invalid then return
    m.backTo = backTo
    m.pvOn = false
    m.pvTimer.control = "stop"
    m.video.translation = [0, 0]
    m.video.width = 1280
    m.video.height = 720
    if rec.kind = "live" and m.playRec <> invalid and m.playRec.kind = "live" and m.playRec.id <> rec.id then m.prevLive = m.playRec
    m.playRec = rec
    m.tryTs = false
    m.vodTry = 0
    fmt = rec.ext
    if rec.kind = "live" then
        url = src.server + "/live/" + src.username + "/" + src.password + "/" + rec.id + ".m3u8"
        fmt = "hls"
    else
        if fmt = "" then fmt = "mp4"
        folder = "movie"
        if rec.kind = "episode" then folder = "series"
        url = src.server + "/" + folder + "/" + src.username + "/" + src.password + "/" + rec.id + "." + fmt
    end if
    m.lastUrl = url
    c = CreateObject("roSGNode", "ContentNode")
    c.url = url
    c.streamFormat = fmt
    c.title = rec.name
    resume = 0
    r = findRecent(rec)
    if r >= 0 and m.recent[r].pos <> invalid and not m.noResume then resume = m.recent[r].pos
    m.noResume = false
    if resume > 0 then c.playStart = resume
    caps = ["Default", "On", "Off"]
    m.video.globalCaptionMode = caps[m.set.caps]
    m.video.content = c
    m.video.visible = true
    m.video.setFocus(true)
    m.video.control = "play"
    m.status.text = ""
    m.area = "video"
    m.saveTimer.control = "stop"
    if rec.kind <> "live" then m.saveTimer.control = "start"
    m.pbEpg = ""
    if rec.kind = "live" then
        touchRecent(rec, 0, 0)
        request(apiUrl(src, "&action=get_short_epg&stream_id=" + rec.id + "&limit=2"), "epgp")
    end if
    showPlayerBar(false)
end sub

sub onSaveTimer()
    rec = m.playRec
    if rec = invalid or rec.kind = "live" or m.video.state <> "playing" then return
    p = m.video.position
    d = m.video.duration
    if p > 15 and d > 0 and p < d * 0.95 then touchRecent(rec, p, d)
end sub

sub hideToastNow()
    m.toast.visible = false
    m.toastbg.visible = false
end sub

sub showToast(t as string)
    m.toast.text = t
    m.toast.visible = true
    m.toastbg.visible = true
    m.toastTimer.control = "stop"
    m.toastTimer.control = "start"
end sub

sub onToastTimer()
    hideToastNow()
end sub

sub stopVideo()
    rec = m.playRec
    if rec <> invalid and rec.kind <> "live" then
        curPos = m.video.position
        dur = m.video.duration
        if dur > 0 and curPos > dur * 0.95 then
            markWatched(rec)
            removeRecent(rec)
        else if curPos > 15 then
            touchRecent(rec, curPos, dur)
        end if
    end if
    m.saveTimer.control = "stop"
    m.video.control = "stop"
    m.video.visible = false
    hideToastNow()
    m.trk.visible = false
    m.trkbg.visible = false
    m.pbar.visible = false
    m.pbarTimer.control = "stop"
    setArea(m.backTo)
    if m.backTo = "home" then showHome(true)
    if m.tab = 0 and m.liveMode = 2 and m.pane = "browse" then m.pvTimer.control = "start"
end sub

sub onVideoState()
    st = m.video.state
    if m.pvOn and m.area <> "video" then
        onPreviewState(st)
        return
    end if
    rec = m.playRec
    if st = "error" then
        if rec <> invalid and rec.kind = "live" and not m.tryTs then
            m.tryTs = true
            u = m.lastUrl
            u = Left(u, Len(u) - 5) + ".ts"
            c = CreateObject("roSGNode", "ContentNode")
            c.url = u
            c.streamFormat = "ts"
            c.title = rec.name
            m.video.content = c
            m.video.control = "play"
            return
        end if
        print "PLAYFAIL code="; m.video.errorCode; " fmt="; m.video.content.streamFormat; " url="; m.lastUrl; " msg="; m.video.errorMsg
        if rec <> invalid and rec.kind <> "live" and m.vodTry < 2 then
            m.vodTry = m.vodTry + 1
            c = CreateObject("roSGNode", "ContentNode")
            c.title = rec.name
            u = m.lastUrl
            if m.vodTry = 2 then
                dot = Len(u)
                while dot > 1 and Mid(u, dot, 1) <> "."
                    dot = dot - 1
                end while
                alt = "mp4"
                if LCase(Mid(u, dot + 1)) = "mp4" then alt = "mkv"
                u = Left(u, dot) + alt
                c.streamFormat = alt
                m.lastUrl = u
            else
                c.streamFormat = m.video.content.streamFormat
            end if
            print "RETRY "; m.vodTry; " "; u
            c.url = u
            if m.video.position > 0 then c.playStart = m.video.position
            m.video.content = c
            m.video.control = "play"
            m.status.text = "Retrying..."
            return
        end if
        code = m.video.errorCode.toStr()
        txt = "Playback failed (code " + code + "). "
        if rec <> invalid and is4k(rec.name) then
            if m.canHevc then
                txt = txt + "This 4K / HEVC stream did not start. Try another version of this title, or one in HD."
            else
                txt = txt + "This looks like a 4K or HEVC title, which this Roku can't play. Try an HD version."
            end if
        else
            txt = txt + m.video.errorMsg
        end if
        m.video.control = "stop"
        m.video.visible = false
        hideToastNow()
        setArea(m.backTo)
        d = CreateObject("roSGNode", "StandardMessageDialog")
        d.title = "Playback failed"
        d.message = [txt]
        d.buttons = ["Try again", "Close"]
        d.observeField("buttonSelected", "onRetryDialog")
        m.retryDlg = d
        m.top.dialog = d
    else if st = "playing" then
        checkAudio()
    else if st = "finished" then
        if rec <> invalid and rec.kind <> "live" then
            markWatched(rec)
            removeRecent(rec)
        end if
        m.video.control = "stop"
        m.video.visible = false
        closeOverlays()
        nxt = invalid
        if rec <> invalid and rec.kind = "episode" then nxt = nextEpisode(rec)
        if nxt <> invalid then
            m.nextRec = nxt
            m.area = "autonext"
            m.top.setFocus(true)
            m.toast.text = "Up next: " + nxt.name + "     starting in 8 seconds. Back cancels."
            m.toast.visible = true
            m.toastbg.visible = true
            m.toastTimer.control = "stop"
            m.autoTimer.control = "start"
            m.hint.text = "Back: cancel auto-play"
        else
            m.playRec = invalid
            setArea(m.backTo)
            if m.backTo = "home" then showHome(true)
        end if
    end if
end sub

sub checkAudio()
    v = m.video
    af = LCase(v.audioFormat)
    print "AUDIO format="; af; " tracks="; v.availableAudioTracks.count(); " video="; v.videoFormat
    m.status.text = ""
    if af = "" or af = "none" then return
    codec = af
    if codec = "eac3" then codec = "eac3"
    di = CreateObject("roDeviceInfo")
    ok = true
    chk = di.CanDecodeAudio({ Codec: codec, ChCnt: 2 })
    if chk <> invalid and chk.result = false then ok = false
    if not ok then
        print "AUDIO unsupported "; af
        showToast("No sound: this Roku can't play " + UCase(af) + " audio. Press * for other tracks, or try another version of this title.")
    end if
end sub

sub onRetryDialog()
    again = (m.retryDlg.buttonSelected = 0)
    m.retryDlg.close = true
    if again and m.playRec <> invalid then startPlayback(m.playRec, m.backTo)
end sub

sub onAutoTimer()
    if m.area <> "autonext" or m.nextRec = invalid then return
    hideToastNow()
    startPlayback(m.nextRec, m.backTo)
end sub

sub cancelAuto()
    m.autoTimer.control = "stop"
    hideToastNow()
    setArea(m.backTo)
end sub

' ---------- audio and subtitle tracks ----------
function trackName(t as object) as string
    n = firstOf(t, ["Name", "Language", "Track"])
    if n = "" then n = "Track"
    return n
end function

sub openTracks()
    v = m.video
    labels = []
    m.trkActs = []
    aud = v.availableAudioTracks
    if type(aud) = "roArray" then
        for each t in aud
            labels.push("Audio: " + trackName(t))
            m.trkActs.push({ kind: "audio", id: firstOf(t, ["Track"]) })
        end for
    end if
    subs = v.availableSubtitleTracks
    if type(subs) = "roArray" and subs.count() > 0 then
        labels.push("Subtitles: Off")
        m.trkActs.push({ kind: "sub", id: "" })
        for each t in subs
            labels.push("Subtitles: " + trackName(t))
            m.trkActs.push({ kind: "sub", id: firstOf(t, ["TrackName", "Track"]) })
        end for
    end if
    if labels.count() = 0 then
        labels.push("Audio: only one track in this stream")
        m.trkActs.push({ kind: "none", id: "" })
    end if
    labels.push("Closed captions: On")
    m.trkActs.push({ kind: "cap", id: "On" })
    labels.push("Closed captions: Off")
    m.trkActs.push({ kind: "cap", id: "Off" })
    showPanel(labels, 0)
end sub

sub showPanel(labels as object, startAt as integer)
    m.pbar.visible = false
    m.pbarTimer.control = "stop"
    m.trk.numRows = labels.count()
    if m.trk.numRows > 9 then m.trk.numRows = 9
    m.trk.content = makeContent(labels)
    m.trk.jumpToItem = startAt
    m.trkbg.height = 20 + m.trk.numRows * 48
    m.trkbg.visible = true
    m.trk.visible = true
    m.area = "tracks"
    m.trk.setFocus(true)
    m.hint.text = "OK: choose     Back: close"
end sub

sub closeTracks()
    m.trk.visible = false
    m.trkbg.visible = false
    m.area = "video"
    m.video.setFocus(true)
end sub

sub onTrkSelect()
    i = m.trk.itemSelected
    if i < 0 or i >= m.trkActs.count() then return
    a = m.trkActs[i]
    if a.kind = "none" then
        closeTracks()
        return
    else if a.kind = "cap" then
        m.video.globalCaptionMode = a.id
        closeTracks()
        showToast("Closed captions: " + a.id + "   (if the stream carries them)")
        return
    end if
    if a.kind = "chan" then
        closeTracks()
        if a.id >= 0 and a.id < m.items.count() then
            m.playIdx = a.id
            m.video.control = "stop"
            startPlayback(m.items[a.id], m.backTo)
        end if
        return
    else if a.kind = "ep" then
        closeTracks()
        m.video.control = "stop"
        startPlayback(a.rec, m.backTo)
        return
    end if
    if a.kind = "audio" then
        m.video.audioTrack = a.id
    else if a.id = "" then
        m.video.globalCaptionMode = "Off"
    else
        m.video.subtitleTrack = a.id
        m.video.globalCaptionMode = "On"
    end if
    closeTracks()
end sub

function is4k(name as string) as boolean
    re = CreateObject("roRegex", "4k|uhd|2160|hevc|h\.?265", "i")
    return re.isMatch(name)
end function

function itemLabel(rec as object) as string
    t = rec.name
    if rec.label <> invalid then t = rec.label
    if is4k(t) then t = "[4K] " + t
    return t
end function

' ---------- favourites and history ----------
sub loadUser()
    sec = CreateObject("roRegistrySection", "tvone_user")
    if sec.exists("favs") then
        r = ParseJson(sec.read("favs"))
        if type(r) = "roArray" then m.favs = r
    end if
    w = CreateObject("roRegistrySection", "tvone_w")
    if w.exists("w") then
        wd = ParseJson(w.read("w"))
        if type(wd) = "roAssociativeArray" then m.watched = wd
    end if
    if sec.exists("recent") then
        r = ParseJson(sec.read("recent"))
        if type(r) = "roArray" then m.recent = r
    end if
    if sec.exists("hid") then
        r = ParseJson(sec.read("hid"))
        if type(r) = "roAssociativeArray" then m.hidden = r
    end if
    if sec.exists("sq") then
        r = ParseJson(sec.read("sq"))
        if type(r) = "roArray" then m.sq = r
    end if
    if sec.exists("set") then
        r = ParseJson(sec.read("set"))
        if type(r) = "roAssociativeArray" then
            if r.sort <> invalid then m.set.sort = r.sort
            if r.caps <> invalid then m.set.caps = r.caps
        end if
    end if
end sub

sub saveExtras()
    sec = CreateObject("roRegistrySection", "tvone_user")
    sec.write("hid", FormatJson(m.hidden))
    sec.write("sq", FormatJson(m.sq))
    sec.write("set", FormatJson(m.set))
    sec.flush()
end sub

sub saveWatched()
    sec = CreateObject("roRegistrySection", "tvone_w")
    sec.write("w", FormatJson(m.watched))
    sec.flush()
end sub

sub markWatched(rec as object)
    m.watched[rec.kind + ":" + rec.id] = 1
    saveWatched()
end sub

function isWatched(rec as object) as boolean
    return (m.watched[rec.kind + ":" + rec.id] <> invalid)
end function

sub saveUser()
    sec = CreateObject("roRegistrySection", "tvone_user")
    sec.write("favs", FormatJson(m.favs))
    sec.write("recent", FormatJson(m.recent))
    sec.flush()
end sub

function favIndex(rec as object) as integer
    for i = 0 to m.favs.count() - 1
        f = m.favs[i]
        if f.kind = rec.kind and f.id = rec.id then return i
    end for
    return -1
end function

function findRecent(rec as object) as integer
    for i = 0 to m.recent.count() - 1
        f = m.recent[i]
        if f.kind = rec.kind and f.id = rec.id then return i
    end for
    return -1
end function

sub touchRecent(rec as object, curPos as dynamic, dur as dynamic)
    i = findRecent(rec)
    if i >= 0 then m.recent.delete(i)
    e = { kind: rec.kind, id: rec.id, name: rec.name, ext: rec.ext, pos: curPos, dur: dur, pic: "" }
    if rec.pic <> invalid then e.pic = rec.pic
    if rec.series <> invalid then e.series = rec.series
    if rec.season <> invalid then e.season = rec.season
    if rec.num <> invalid then e.num = rec.num
    if rec.spic <> invalid then e.spic = rec.spic
    m.recent.unshift(e)
    while m.recent.count() > 15
        m.recent.pop()
    end while
    saveUser()
end sub

sub removeRecent(rec as object)
    i = findRecent(rec)
    if i >= 0 then
        m.recent.delete(i)
        saveUser()
    end if
end sub

sub toggleFav(rec as object)
    i = favIndex(rec)
    if i >= 0 then
        m.favs.delete(i)
        m.status.text = "Removed from favourites"
    else
        fv = { kind: rec.kind, id: rec.id, name: rec.name, ext: rec.ext, pic: "" }
        if rec.pic <> invalid then fv.pic = rec.pic
        m.favs.unshift(fv)
        while m.favs.count() > 40
            m.favs.pop()
        end while
        m.status.text = "Added to favourites"
    end if
    saveUser()
end sub

sub onOptionsKey()
    if m.area = "grid" then
        node = rightNode()
        i = node.itemFocused
        if i < 0 or i >= m.items.count() then return
        rec = m.items[i]
        toggleFav(rec)
        if m.tab = 0 and m.liveMode > 0 then
            m.status.text = m.status.text
            return
        end if
        node.content.getChild(i).title = itemLabel(rec)
        if favIndex(rec) >= 0 then
            node.content.getChild(i).rating = "fav"
        else
            node.content.getChild(i).rating = ""
        end if
    else if m.area = "detail" then
        if m.detailRec <> invalid then
            toggleFav(m.detailRec)
            refreshDetailButtons()
        end if
    else if m.area = "cats" then
        hideCategory()
    else if m.area = "list" and m.mode = "sources" then
        i = m.list.itemFocused
        if i >= 0 and i < m.sources.count() then confirmRemove(i)
    else if m.area = "home" then
        if not m.homeIsRow then return
        rc = m.homerow.rowItemFocused
        r = rc[0]
        c = rc[1]
        if r < 0 or r >= m.homeSecs.count() then return
        sec = m.homeSecs[r]
        if c < 0 or c >= sec.items.count() then return
        if sec.section = "fav" or sec.section = "rec" then
            toggleFav(sec.items[c])
        else
            removeRecent(sec.items[c])
            m.status.text = "Removed from Continue watching"
        end if
        showHome(true)
    end if
end sub

' ---------- home ----------
function cardPoster(rec as object) as string
    if rec.kind = "episode" and rec.pic <> invalid and rec.pic <> "" then return shrinkUrl(rec.pic)
    return homePoster(rec)
end function

function leftText(played as dynamic, dur as dynamic) as string
    if dur = invalid or dur <= 0 or played = invalid then return ""
    mins = Int((dur - played) / 60)
    if mins < 1 then mins = 1
    if mins >= 60 then
        mm = mins mod 60
        pad = ""
        if mm < 10 then pad = "0"
        return Int(mins / 60).toStr() + " h " + pad + mm.toStr() + " left"
    end if
    return mins.toStr() + " min left"
end function

sub showHome(focus as boolean)
    m.header.text = "Home"
    m.homeSecs = []
    root = CreateObject("roSGNode", "ContentNode")
    sizes = []
    heights = []
    spacings = []
    labelOff = []
    showLab = []
    fx = []
    if m.recent.count() > 0 then
        row = root.createChild("ContentNode")
        row.title = "Continue watching"
        sec = { section: "recent", items: [] }
        for each r in m.recent
            n = row.createChild("ContentNode")
            if r.series <> invalid then
                n.title = r.series
                sb = "Episode"
                if r.season <> invalid and r.num <> invalid then sb = "S" + r.season + " E" + r.num
                lt = leftText(r.pos, r.dur)
                if lt <> "" then sb = sb + ", " + lt
                n.shortDescriptionLine2 = sb
            else if r.kind = "live" then
                n.title = r.name
                n.shortDescriptionLine2 = "Live"
            else
                n.title = r.name
                n.shortDescriptionLine2 = leftText(r.pos, r.dur)
            end if
            if r.kind <> "live" and r.dur <> invalid and r.dur > 0 then
                n.playStart = r.pos
                n.length = r.dur
            end if
            if favIndex(r) >= 0 then n.rating = "fav"
            n.hdPosterUrl = cardPoster(r)
            sec.items.push(r)
        end for
        m.homeSecs.push(sec)
        sizes.push([232, 130])
        heights.push(206)
        spacings.push(18)
        labelOff.push([0, 0])
        showLab.push(true)
        fx.push(0)
    end if
    kinds = ["live", "movie", "series"]
    titles = ["Favourite channels", "Favourite movies", "Favourite TV shows"]
    for k = 0 to 2
        sec = { section: "fav", items: [] }
        for each f in m.favs
            if f.kind = kinds[k] then sec.items.push(f)
        end for
        if sec.items.count() > 0 then
            row = root.createChild("ContentNode")
            row.title = titles[k]
            for each f in sec.items
                n = row.createChild("ContentNode")
                n.title = f.name
                n.rating = "fav"
                n.hdPosterUrl = homePoster(f)
            end for
            m.homeSecs.push(sec)
            if k = 0 then
                sizes.push([104, 78])
                heights.push(134)
                spacings.push(16)
            else
                sizes.push([112, 150])
                heights.push(212)
                spacings.push(16)
            end if
            labelOff.push([0, 0])
            showLab.push(true)
            fx.push(0)
        end if
    end for
    m.homeIsRow = (m.homeSecs.count() > 0)
    if m.homeIsRow then
        nr = m.homeSecs.count()
        if nr > 3 then nr = 3
        m.homerow.numRows = nr
        m.homerow.rowHeights = heights
        m.homerow.rowItemSize = sizes
        m.homerow.rowItemSpacing = spacingPairs(spacings)
        m.homerow.rowLabelOffset = labelOff
        m.homerow.showRowLabel = showLab
        m.homerow.focusXOffset = fx
        m.homerow.content = root
    else
        m.homelist.content = makeContent(["Nothing here yet.", "Press * on a channel, movie or series to add a favourite.", "What you watch will appear under Continue watching."])
    end if
    setPane("home")
    if focus then setArea("home")
end sub

function spacingPairs(sp as object) as object
    out = []
    for each v in sp
        out.push([v, 0])
    end for
    return out
end function

sub onHomeRowSelect()
    rc = m.homerow.rowItemSelected
    playHomeItem(rc[0], rc[1])
end sub

sub playHomeItem(r as integer, c as integer)
    if r < 0 or r >= m.homeSecs.count() then return
    items = m.homeSecs[r].items
    if c < 0 or c >= items.count() then return
    rec = items[c]
    m.playIdx = -1
    m.fromHome = true
    if (m.homeSecs[r].section = "fav" or m.homeSecs[r].section = "rec") and (rec.kind = "series" or rec.kind = "movie") then
        openDetail(rec)
    else
        startPlayback(rec, "home")
    end if
end sub

sub onHomeSelect()
end sub


' ---------- sources ----------
sub showList(header as string, items as object, mode as string, focus = true as boolean)
    m.mode = mode
    m.header.text = header
    m.list.content = makeContent(items)
    m.list.jumpToItem = 0
    setPane("list")
    if focus then setArea("list")
end sub

function fmtDay(ts as dynamic) as string
    d = CreateObject("roDateTime")
    d.fromSeconds(Int(num(ts)))
    d.toLocalTime()
    mn = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    return mn[d.getMonth() - 1] + " " + d.getDayOfMonth().toStr() + ", " + d.getYear().toStr()
end function

function expText(src as object) as string
    if src.exp = invalid then return ""
    ex = Int(num(src.exp))
    if ex <= 0 then return "   never expires"
    nowTs = CreateObject("roDateTime").asSeconds()
    if ex < nowTs then return "   EXPIRED " + fmtDay(ex)
    days = Int((ex - nowTs) / 86400)
    txt = "   expires " + fmtDay(ex)
    if days <= 60 then txt = txt + " (" + days.toStr() + " days)"
    return txt
end function

function sourceRows() as object
    items = []
    for i = 0 to m.sources.count() - 1
        src = m.sources[i]
        mark = "   "
        if i = m.active then mark = "> "
        kind = "Xtream"
        if src.type = "m3u" then kind = "M3U"
        ex = expText(src)
        if ex = "" and src.refreshed <> invalid then ex = "   refreshed " + fmtStamp(src.refreshed)
        items.push(mark + src.name + "  (" + kind + ")" + ex)
    end for
    items.push("+ Add playlist")
    return items
end function

sub showSources(focus = true as boolean)
    m.editSrc = -1
    hdr = "Playlists  (OK: refresh, edit or remove)"
    if m.phoneUrl <> "" then hdr = "Playlists - phone: " + m.phoneUrl
    showList(hdr, sourceRows(), "sources", focus)
    acctNext(0)
end sub

sub acctNext(i as integer)
    if m.mode <> "sources" then return
    while i < m.sources.count()
        src = m.sources[i]
        if src.server <> invalid and src.server <> "" then
            m.acctIdx = i
            request(apiUrl(src, ""), "acct")
            return
        end if
        i = i + 1
    end while
    saveSources()
end sub

sub refreshSourceRows()
    if m.mode <> "sources" or m.pane <> "list" then return
    idx = m.list.itemFocused
    if idx < 0 then idx = 0
    m.list.content = makeContent(sourceRows())
    m.list.jumpToItem = idx
end sub

sub showAddType()
    startForm("m3u")
    m.editSrc = -1
end sub

sub startForm(kind as string)
    nm = "My IPTV"
    if m.form <> invalid and m.form.vals.name <> invalid and m.form.vals.name <> "" then nm = m.form.vals.name
    if kind = "m3u" then
        m.form = { type: "m3u", keys: ["name", "url"], labels: ["Playlist name", "Playlist link (M3U or M3U8)"], holders: ["My IPTV", "Press OK to type or paste the link"], vals: { name: nm, url: "" } }
    else
        m.form = { type: "xtream", keys: ["name", "server", "username", "password"], labels: ["Playlist name", "Server address", "Username", "Password"], holders: ["My IPTV", "http://host:port", "Press OK to type", "Press OK to type"], vals: { name: nm, server: "", username: "", password: "" } }
    end if
    m.mode = "form"
    m.pfMsg = ""
    if m.area <> "pform" then
        m.pfIdx = 0
        m.pfBtn = 0
    end if
    setPane("form")
    setArea("pform")
end sub

sub pfLabel(g as object, txt as string, x as integer, y as integer, w as integer, h as integer, size as integer, bold as boolean, col as string, al = "left" as string)
    lb = CreateObject("roSGNode", "Label")
    lb.text = txt
    lb.translation = [x, y]
    lb.width = w
    lb.height = h
    lb.vertAlign = "center"
    lb.horizAlign = al
    lb.color = col
    lb.font = mkFont(size, bold)
    g.appendChild(lb)
end sub

sub pfRect(g as object, x as integer, y as integer, w as integer, h as integer, col as string)
    r = CreateObject("roSGNode", "Rectangle")
    r.translation = [x, y]
    r.width = w
    r.height = h
    r.color = col
    g.appendChild(r)
end sub

sub renderPForm()
    g = m.pform
    g.removeChildrenIndex(g.getChildCount(), 0)
    f = m.form
    n = f.keys.count()
    last = n + 1
    pfLabel(g, "Add a playlist", 0, 0, 700, 40, 34, true, "0xFFFFFF")

    ' row 0: type
    pfLabel(g, "Type", 0, 46, 80, 40, 20, true, "0xB8C4C5")
    types = ["M3U / M3U8 link", "Xtream Codes"]
    x = 90
    for i = 0 to 1
        kind = "m3u"
        if i = 1 then kind = "xtream"
        mode = 0
        if kind = f.type then mode = 1
        if m.pfIdx = 0 and kind = f.type then mode = 2
        addChip(g, x, types[i], mode, "", 46, 0)
        x = x + chipWidth(types[i], "") + 14
    end for

    ' rows 1..n: fields
    bw = 760
    for i = 0 to n - 1
        fy = 108 + i * 80
        foc = (m.pfIdx = i + 1)
        pfLabel(g, f.labels[i], 0, fy, bw, 24, 20, true, "0xB8C4C5")
        if foc then pfRect(g, -3, fy + 21, bw + 6, 50, "0xF5C400")
        bg = "0x20383D"
        if foc then bg = "0x294D53"
        pfRect(g, 0, fy + 24, bw, 44, bg)
        v = f.vals[f.keys[i]]
        if f.keys[i] = "password" and v <> "" then v = String(Len(v), "*")
        col = "0xFFFFFF"
        right = ""
        if v = "" then
            v = f.holders[i]
            col = "0x8A9A9C"
        else if Len(v) > 40 then
            right = Len(v).toStr() + " characters"
            v = Left(v, 26) + "..." + Right(v, 10)
        end if
        if foc then right = "OK: edit"
        pfLabel(g, v, 16, fy + 24, bw - 190, 44, 22, false, col)
        if right <> "" then pfLabel(g, right, bw - 170, fy + 24, 154, 44, 20, false, "0xF5C400", "right")
    end for

    ' tip for long links
    if m.phoneUrl <> "" then
        pfRect(g, 800, 108, 280, 168, "0x101A1D")
        pfLabel(g, "Long link?", 818, 116, 244, 28, 22, true, "0xF5C400")
        tip = CreateObject("roSGNode", "Label")
        tip.translation = [818, 148]
        tip.width = 244
        tip.height = 120
        tip.wrap = true
        tip.lineSpacing = 4
        tip.color = "0xB8C4C5"
        tip.font = mkFont(20, false)
        tip.text = "Typing is slow. On your phone, open" + chr(10) + m.phoneUrl + chr(10) + "and paste the link there."
        g.appendChild(tip)
    end if

    ' last row: buttons
    by = 108 + n * 80 + 4
    foc = (m.pfIdx = last)
    sx = 0
    labs = ["Save", "Cancel"]
    for i = 0 to 1
        bf = foc and (m.pfBtn = i)
        if bf then pfRect(g, sx - 3, by - 3, 166, 50, "0xF5C400")
        col = "0x20383D"
        tc = "0xB8C4C5"
        if i = 0 then
            col = "0x294D53"
            tc = "0xF5C400"
        end if
        if bf then
            col = "0x294D53"
            tc = "0xFFFFFF"
            if i = 0 then
                col = "0xF5C400"
                tc = "0x080D0F"
            end if
        end if
        pfRect(g, sx, by, 160, 44, col)
        pfLabel(g, labs[i], sx, by, 160, 44, 22, true, tc, "center")
        sx = sx + 180
    end for
    if m.pfMsg <> "" then pfLabel(g, m.pfMsg, 380, by, 600, 44, 22, true, "0xFFB547")

    if m.pfIdx = 0 then
        m.hint.text = "Left/Right: choose type    Down: next    Back: cancel"
    else if foc then
        m.hint.text = "OK: choose    Left/Right: Save or Cancel    Up: fields    Back: cancel"
    else
        m.hint.text = "OK: type or paste    Up/Down: move    Back: cancel"
    end if
end sub

sub pfKey(key as string)
    n = m.form.keys.count()
    last = n + 1
    m.pfMsg = ""
    if key = "up" then
        if m.pfIdx > 0 then m.pfIdx = m.pfIdx - 1
    else if key = "down" then
        if m.pfIdx < last then m.pfIdx = m.pfIdx + 1
    else if key = "left" or key = "right" then
        if m.pfIdx = 0 then
            if key = "left" then startForm("m3u") else startForm("xtream")
            return
        else if m.pfIdx = last then
            if key = "left" then m.pfBtn = 0 else m.pfBtn = 1
        end if
    else if key = "OK" then
        if m.pfIdx >= 1 and m.pfIdx <= n then
            openKeyboard(m.pfIdx - 1)
            return
        else if m.pfIdx = last then
            if m.pfBtn = 0 then saveForm() else showSources()
            return
        end if
    end if
    renderPForm()
end sub

sub onListSelect()
    i = m.list.itemSelected
    if m.area <> "list" then return
    if m.mode = "settings" then
        settingsAction(i)
    else if m.mode = "sources" then
        if i = m.sources.count() then
            showAddType()
        else
            openSourceMenu(i)
        end if
    end if
end sub

sub openKeyboard(i as integer)
    m.kbMode = "form"
    m.editIdx = i
    m.kb = CreateObject("roSGNode", "StandardKeyboardDialog")
    m.kb.title = m.form.labels[i]
    m.kb.text = m.form.vals[m.form.keys[i]]
    m.kb.buttons = ["OK", "Cancel"]
    if m.form.keys[i] = "password" then m.kb.textEditBox.secureMode = true
    m.kb.observeField("buttonSelected", "onKeyboard")
    m.top.dialog = m.kb
end sub

sub onKeyboard()
    if m.kbMode = "gsearch" then
        q = m.kb.text
        ok = (m.kb.buttonSelected = 0)
        m.kb.close = true
        m.kbMode = ""
        if ok then startGlobalSearch(q)
        return
    end if
    if m.kbMode = "search" then
        q = m.kb.text
        ok = (m.kb.buttonSelected = 0)
        m.kb.close = true
        m.kbMode = ""
        if ok then startSearch(q)
        return
    end if
    if m.kb.buttonSelected = 0 then
        m.form.vals[m.form.keys[m.editIdx]] = m.kb.text
    end if
    m.kb.close = true
    if m.area <> "pform" then return
    renderPForm()
end sub

sub saveForm()
    v = m.form.vals
    if v.name = "" then v.name = "My IPTV"
    need = "url"
    if m.form.type = "xtream" then need = "server"
    if v[need] = "" or (m.form.type = "xtream" and (v.username = "" or v.password = "")) then
        m.pfMsg = "Fill in every field first"
        for i = 0 to m.form.keys.count() - 1
            if v[m.form.keys[i]] = "" then
                m.pfIdx = i + 1
                exit for
            end if
        end for
        renderPForm()
        return
    end if
    src = { name: v.name, type: m.form.type }
    if m.form.type = "m3u" then
        src.url = v.url
    else
        src.server = v.server
        src.username = v.username
        src.password = v.password
    end if
    addSource(src)
    saved = m.sources[m.sources.count() - 1]
    if saved.server = invalid or saved.server = "" then
        m.sources.pop()
        m.pfMsg = "That link was not recognised"
        renderPForm()
        return
    end if
    if m.editSrc >= 0 and m.editSrc < m.sources.count() - 1 then
        m.sources.pop()
        m.sources[m.editSrc] = saved
        m.active = m.editSrc
    else
        m.active = m.sources.count() - 1
    end if
    m.editSrc = -1
    saveSources()
    doRefresh()
end sub

' ---------- category cache, hidden categories ----------
function cloneRec(r as object) as object
    o = {}
    for each k in r.keys()
        o[k] = r[k]
    end for
    return o
end function

function hidKey(t as integer) as string
    nm = "x"
    src = activeSource()
    if src <> invalid then nm = src.name
    return nm + "|" + t.toStr()
end function

function hiddenList(t as integer) as object
    v = m.hidden[hidKey(t)]
    if v = invalid then return []
    return v
end function

function listHas(arr as object, v as string) as boolean
    for each x in arr
        if x = v then return true
    end for
    return false
end function

sub applyHidden(cache as object, t as integer)
    hid = hiddenList(t)
    names = ["Search..."]
    ids = ["__search"]
    for i = 1 to cache.allI.count() - 1
        if not listHas(hid, cache.allI[i]) then
            names.push(cache.allN[i])
            ids.push(cache.allI[i])
        end if
    end for
    cache.names = names
    cache.ids = ids
end sub

function storeCats(t as integer, data as dynamic) as object
    allN = ["Search..."]
    allI = ["__search"]
    if type(data) = "roArray" then
        for each c in data
            allN.push(s(c.category_name))
            allI.push(s(c.category_id))
        end for
    end if
    cache = { names: [], ids: [], last: 0, allN: allN, allI: allI }
    applyHidden(cache, t)
    if cache.names.count() > 1 then cache.last = 1
    m.catCache[t.toStr()] = cache
    return cache
end function

function catContent(names as object) as object
    c = CreateObject("roSGNode", "ContentNode")
    for i = 1 to names.count() - 1
        n = c.createChild("ContentNode")
        n.title = names[i]
    end for
    if names.count() <= 1 then
        n = c.createChild("ContentNode")
        n.title = "(no categories)"
    end if
    return c
end function

function catPos(i as integer) as integer
    if i < 1 then return 0
    return i - 1
end function

sub buildSearchBtn()
    m.sbBg = CreateObject("roSGNode", "Rectangle")
    m.sbBg.width = 270
    m.sbBg.height = 44
    m.sbIc = CreateObject("roSGNode", "Poster")
    m.sbIc.width = 22
    m.sbIc.height = 22
    m.sbIc.translation = [14, 11]
    m.sbIc.loadDisplayMode = "scaleToFit"
    m.sbLb = CreateObject("roSGNode", "Label")
    m.sbLb.translation = [48, 0]
    m.sbLb.width = 214
    m.sbLb.height = 44
    m.sbLb.vertAlign = "center"
    m.sbLb.font = mkFont(18, true)
    m.sbtn.appendChild(m.sbBg)
    m.sbtn.appendChild(m.sbIc)
    m.sbtn.appendChild(m.sbLb)
    renderSearchBtn()
end sub

sub renderSearchBtn()
    if m.sbBg = invalid then return
    nm = "Search"
    if m.tab >= 0 and m.tab <= 2 then nm = "Search " + m.tabNames[m.tab + 1]
    m.sbLb.text = nm
    if m.area = "search" then
        m.sbBg.color = "0xF5C400"
        m.sbLb.color = "0x080D0F"
        m.sbIc.uri = iconUri("search", "d")
    else
        m.sbBg.color = "0x20383D"
        m.sbLb.color = "0xF5C400"
        m.sbIc.uri = iconUri("search", "g")
    end if
end sub

sub hideCategory()
    t = m.tab
    if t < 0 or t > 2 then return
    i = m.cats.itemFocused + 1
    if i < 1 then return
    cache = m.catCache[t.toStr()]
    if cache = invalid or i >= cache.ids.count() then return
    id = cache.ids[i]
    nm = cache.names[i]
    hid = hiddenList(t)
    hid.push(id)
    m.hidden[hidKey(t)] = hid
    applyHidden(cache, t)
    m.catIds = cache.ids
    m.cats.content = catContent(cache.names)
    j = i
    if j >= cache.names.count() then j = cache.names.count() - 1
    cache.last = j
    m.cats.jumpToItem = catPos(j)
    saveExtras()
    m.catTimer.control = "stop"
    m.catTimer.control = "start"
    m.status.text = "Hidden: " + Left(nm, 24) + "   (undo in Settings)"
end sub

function hiddenCount() as integer
    src = activeSource()
    if src = invalid then return 0
    pre = src.name + "|"
    n = 0
    for each k in m.hidden.keys()
        if Left(k, Len(pre)) = pre then n = n + m.hidden[k].count()
    end for
    return n
end function

sub clearHidden()
    src = activeSource()
    if src = invalid then return
    pre = src.name + "|"
    drop = []
    for each k in m.hidden.keys()
        if Left(k, Len(pre)) = pre then drop.push(k)
    end for
    for each k in drop
        m.hidden.delete(k)
    end for
    for t = 0 to 2
        cache = m.catCache[t.toStr()]
        if cache <> invalid then applyHidden(cache, t)
    end for
    saveExtras()
end sub

' ---------- favourites tab ----------
sub setGridBig()
    m.grid.itemSize = [128, 208]
    m.grid.itemSpacing = [14, 12]
    m.grid.numColumns = 5
    m.grid.numRows = 2
end sub

sub showFavorites(focus as boolean)
    setPane("browse")
    setGridBig()
    m.grid.content = invalid
    nl = 0
    nm = 0
    ns = 0
    for each f in m.favs
        if f.kind = "live" then nl = nl + 1
        if f.kind = "movie" then nm = nm + 1
        if f.kind = "series" then ns = ns + 1
    end for
    names = ["All favourites (" + m.favs.count().toStr() + ")", "Live TV (" + nl.toStr() + ")", "Movies (" + nm.toStr() + ")", "Series (" + ns.toStr() + ")", "Continue watching (" + m.recent.count().toStr() + ")"]
    m.catIds = ["all", "live", "movie", "series", "recent"]
    m.cats.content = makeContent(names)
    m.cats.jumpToItem = 0
    m.catInfo = ""
    showFavCat(0)
    if focus then setArea("cats")
end sub

sub showFavCat(i as integer)
    if i < 0 or i >= m.catIds.count() then return
    id = m.catIds[i]
    recs = []
    if id = "recent" then
        for each r in m.recent
            c = cloneRec(r)
            c.added = 0
            c.rating = 0
            if r.series <> invalid then
                lb = r.series
                if r.season <> invalid and r.num <> invalid then lb = lb + " S" + r.season + "E" + r.num
                c.label = lb
            end if
            recs.push(c)
        end for
    else
        for each f in m.favs
            if id = "all" or f.kind = id then
                c = cloneRec(f)
                c.added = 0
                c.rating = 0
                recs.push(c)
            end if
        end for
    end if
    m.items = recs
    m.itemsOrig = []
    for each rr in recs
        m.itemsOrig.push(rr)
    end for
    m.sortMode = 0
    if recs.count() > 0 then
        m.grid.content = gridContent(recs)
        m.grid.jumpToItem = 0
        m.status.text = recs.count().toStr() + " items"
    else
        m.grid.content = invalid
        if id = "recent" then
            m.status.text = "Nothing in progress yet"
        else
            m.status.text = "Nothing here yet. Press * on any title to add it."
        end if
    end if
end sub

' ---------- search tab (movies, series and channels in one go) ----------
sub showSearchTab(focus as boolean)
    setPane("browse")
    setGridBig()
    m.catInfo = ""
    if m.gsRes = invalid then
        m.grid.content = invalid
        m.items = []
        m.status.text = "Press OK on New search to find movies, series and channels"
    end if
    gsBuildCats(0)
    if m.gsRes <> invalid then gsShowView(m.gsView)
    if focus then setArea("cats")
end sub

sub gsBuildCats(sel as integer)
    names = ["New search..."]
    ids = ["__new"]
    g = m.gsRes
    if g <> invalid then
        tot = g.live.count() + g.movie.count() + g.series.count()
        names.push("All results (" + tot.toStr() + ")")
        ids.push("all")
        names.push("Live TV (" + g.live.count().toStr() + ")")
        ids.push("live")
        names.push("Movies (" + g.movie.count().toStr() + ")")
        ids.push("movie")
        names.push("Series (" + g.series.count().toStr() + ")")
        ids.push("series")
    end if
    for each q in m.sq
        names.push("Recent: " + q)
        ids.push("q:" + q)
    end for
    m.catIds = ids
    m.cats.content = makeContent(names)
    if sel >= names.count() then sel = 0
    m.cats.jumpToItem = sel
end sub

sub openGsKeyboard()
    m.kbMode = "gsearch"
    m.kb = CreateObject("roSGNode", "StandardKeyboardDialog")
    m.kb.title = "Search movies, series and channels"
    m.kb.text = ""
    m.kb.buttons = ["Search", "Cancel"]
    m.kb.observeField("buttonSelected", "onKeyboard")
    m.top.dialog = m.kb
end sub

sub startGlobalSearch(q as string)
    q = LCase(q.trim())
    if q = "" then return
    if activeSource() = invalid then
        m.status.text = "Add a playlist first (Settings > Playlists)"
        return
    end if
    nq = [q]
    for each o in m.sq
        if o <> q and nq.count() < 6 then nq.push(o)
    end for
    m.sq = nq
    saveExtras()
    m.gsRes = { q: q, live: [], movie: [], series: [] }
    m.gsRun = true
    m.gsT = 0
    m.gsI = 1
    m.gsView = "all"
    m.items = []
    m.grid.content = invalid
    gsBuildCats(1)
    gsPrepare()
end sub

sub gsPrepare()
    if not m.gsRun then return
    src = activeSource()
    if src = invalid then
        m.gsRun = false
        return
    end if
    acts = ["get_live_categories", "get_vod_categories", "get_series_categories"]
    for t = 0 to 2
        if m.catCache[t.toStr()] = invalid then
            m.gsCatT = t
            m.status.text = "Preparing search..."
            request(apiUrl(src, "&action=" + acts[t]), "gscat")
            return
        end if
    end for
    gsStep()
end sub

sub gsStep()
    if not m.gsRun then return
    g = m.gsRes
    keys = ["live", "movie", "series"]
    if m.gsT > 2 then
        gsDone()
        return
    end if
    if g[keys[m.gsT]].count() >= 30 then
        m.gsT = m.gsT + 1
        m.gsI = 1
        gsStep()
        return
    end if
    cache = m.catCache[m.gsT.toStr()]
    if m.gsI >= cache.ids.count() then
        m.gsT = m.gsT + 1
        m.gsI = 1
        gsStep()
        return
    end if
    src = activeSource()
    if src = invalid then
        m.gsRun = false
        return
    end if
    tot = g.live.count() + g.movie.count() + g.series.count()
    nms = ["Live TV", "Movies", "Series"]
    acts = ["get_live_streams", "get_vod_streams", "get_series"]
    m.status.text = "Searching " + nms[m.gsT] + " " + m.gsI.toStr() + "/" + (cache.ids.count() - 1).toStr() + "   " + tot.toStr() + " found"
    request(apiUrl(src, "&action=" + acts[m.gsT] + "&category_id=" + cache.ids[m.gsI]), "gs")
end sub

sub onGsData(data as dynamic)
    if not m.gsRun then return
    g = m.gsRes
    keys = ["live", "movie", "series"]
    key = keys[m.gsT]
    added = false
    if type(data) = "roArray" then
        for each it in data
            if g[key].count() >= 30 then exit for
            nm = s(it.name)
            if nm <> "" and Instr(1, LCase(nm), g.q) > 0 then
                pic = pickPic(it)
                if m.gsT = 2 then
                    rec = { kind: "series", name: nm, id: s(it.series_id), ext: "", pic: pic, added: num(it.last_modified), rating: num(it.rating) }
                else if m.gsT = 0 then
                    rec = { kind: "live", name: nm, id: s(it.stream_id), ext: "", pic: pic, added: num(it.added), rating: 0 }
                else
                    rec = { kind: "movie", name: nm, id: s(it.stream_id), ext: s(it.container_extension), pic: pic, added: num(it.added), rating: num(it.rating) }
                end if
                g[key].push(rec)
                added = true
            end if
        end for
    end if
    m.gsI = m.gsI + 1
    if added and m.area <> "grid" and m.tab = 4 then gsShowView(m.gsView)
    gsStep()
end sub

sub gsDone()
    m.gsRun = false
    g = m.gsRes
    if g = invalid then return
    tot = g.live.count() + g.movie.count() + g.series.count()
    if tot = 0 then
        m.status.text = "No results for " + Left(g.q, 20)
    else
        m.status.text = tot.toStr() + " results for " + Left(g.q, 20)
    end if
    if m.tab <> 4 or m.pane <> "browse" then return
    sel = m.cats.itemFocused
    if sel < 0 then sel = 1
    gsBuildCats(sel)
    if m.area <> "grid" then gsShowView(m.gsView)
end sub

sub gsShowView(v as string)
    g = m.gsRes
    if g = invalid then return
    recs = []
    if v = "all" or v = "movie" then
        for each r in g.movie
            recs.push(r)
        end for
    end if
    if v = "all" or v = "series" then
        for each r in g.series
            recs.push(r)
        end for
    end if
    if v = "all" or v = "live" then
        for each r in g.live
            recs.push(r)
        end for
    end if
    m.items = recs
    m.itemsOrig = []
    for each rr in recs
        m.itemsOrig.push(rr)
    end for
    m.sortMode = 0
    if recs.count() > 0 then
        m.grid.content = gridContent(recs)
    else
        m.grid.content = invalid
    end if
end sub

' ---------- settings tab ----------
sub showSettings(focus as boolean)
    sortNames = ["Provider order", "A-Z", "Newest first", "Highest rated"]
    capNames = ["Roku setting", "On", "Off"]
    idx = 0
    if m.mode = "settings" and m.pane = "list" then idx = m.list.itemFocused
    if idx < 0 then idx = 0
    items = []
    items.push("Default sort:   " + sortNames[m.set.sort])
    items.push("Captions when playing:   " + capNames[m.set.caps])
    items.push("Show hidden categories again   (" + hiddenCount().toStr() + " hidden)")
    items.push("Clear Continue watching   (" + m.recent.count().toStr() + ")")
    items.push("Clear all favourites   (" + m.favs.count().toStr() + ")")
    items.push("About TVflow")
    showList("Settings", items, "settings", focus)
    m.list.jumpToItem = idx
end sub

sub settingsAction(i as integer)
    if i = 0 then
        m.set.sort = (m.set.sort + 1) mod 4
        saveExtras()
        showSettings(true)
    else if i = 1 then
        m.set.caps = (m.set.caps + 1) mod 3
        saveExtras()
        showSettings(true)
    else if i = 2 then
        clearHidden()
        showSettings(true)
        m.status.text = "All categories are visible again"
    else if i = 3 then
        confirmAsk("Clear Continue watching?", "This only clears the list on this Roku.", "recent")
    else if i = 4 then
        confirmAsk("Clear all favourites?", "This removes every favourite on this Roku.", "favs")
    else if i = 5 then
        hv = "No"
        if m.canHevc then hv = "Yes"
        d = CreateObject("roSGNode", "StandardMessageDialog")
        d.title = "TVflow for Roku  1.2"
        d.message = ["Device: " + m.model, "4K / HEVC playback: " + hv, "Long lists show up to " + m.maxItems.toStr() + " titles."]
        d.buttons = ["OK"]
        d.observeField("buttonSelected", "onAboutDialog")
        m.dlg = d
        m.top.dialog = d
    end if
end sub

sub onAboutDialog()
    m.dlg.close = true
end sub

sub confirmAsk(title as string, msg as string, act as string)
    m.confirmAct = act
    d = CreateObject("roSGNode", "StandardMessageDialog")
    d.title = title
    d.message = [msg]
    d.buttons = ["Clear", "Cancel"]
    d.observeField("buttonSelected", "onConfirmDialog")
    m.dlg = d
    m.top.dialog = d
end sub

sub onConfirmDialog()
    ok = (m.dlg.buttonSelected = 0)
    m.dlg.close = true
    if not ok then return
    if m.confirmAct = "recent" then
        m.recent = []
    else if m.confirmAct = "favs" then
        m.favs = []
    end if
    saveUser()
    showSettings(true)
    m.status.text = "Cleared"
end sub

' ---------- live TV views: channels, tv guide, preview ----------
sub buildModeChips()
    names = ["Channels", "TV guide", "Preview"]
    m.modeBg = []
    m.modeLb = []
    for i = 0 to 2
        r = CreateObject("roSGNode", "Rectangle")
        r.translation = [400 + i * 158, 112]
        r.width = 150
        r.height = 36
        r.color = "0x17272B"
        m.lmodes.appendChild(r)
        m.modeBg.push(r)
        l = CreateObject("roSGNode", "Label")
        l.translation = [400 + i * 158, 112]
        l.width = 150
        l.height = 36
        l.text = names[i]
        l.horizAlign = "center"
        l.vertAlign = "center"
        l.font = mkFont(18, true)
        m.lmodes.appendChild(l)
        m.modeLb.push(l)
    end for
    renderModes()
end sub

sub renderModes()
    if m.modeBg = invalid then return
    for i = 0 to 2
        if i = m.liveMode and m.area = "modes" then
            m.modeBg[i].color = "0xF5C400"
            m.modeLb[i].color = "0x080D0F"
        else if i = m.liveMode then
            m.modeBg[i].color = "0x20383D"
            m.modeLb[i].color = "0xF5C400"
        else
            m.modeBg[i].color = "0x17272B"
            m.modeLb[i].color = "0xB8C4C5"
        end if
    end for
end sub

sub setLiveMode(i as integer)
    m.liveMode = i
    applyLiveVisibility()
    renderModes()
    m.epg.text = ""
    buildLiveViews()
end sub

sub buildLiveViews()
    if m.tab <> 0 then return
    if m.liveMode = 1 then
        buildGuide()
    else if m.liveMode = 2 then
        buildChList()
    end if
end sub

sub buildChList()
    c = CreateObject("roSGNode", "ContentNode")
    n = 0
    for each rec in m.items
        if n >= 400 then exit for
        ch = c.createChild("ContentNode")
        ch.title = itemLabel(rec)
        n = n + 1
    end for
    m.chlist.content = c
    m.chlist.jumpToItem = 0
    if m.area = "grid" then m.pvTimer.control = "start"
end sub

sub onChFocus()
    if m.tab <> 0 or m.liveMode <> 2 then return
    m.epg.text = ""
    m.epgTimer.control = "stop"
    m.epgTimer.control = "start"
    if m.area = "grid" then
        m.pvTimer.control = "stop"
        m.pvTimer.control = "start"
    end if
end sub

sub onPvTimer()
    if m.tab <> 0 or m.liveMode <> 2 or m.pane <> "browse" or m.area = "video" then return
    i = m.chlist.itemFocused
    if i < 0 or i >= m.items.count() then return
    previewPlay(m.items[i])
end sub

sub previewPlay(rec as object)
    src = activeSource()
    if src = invalid or rec.kind <> "live" then return
    m.pvOn = true
    m.pvTs = false
    m.pvRec = rec
    m.pvUrl = src.server + "/live/" + src.username + "/" + src.password + "/" + rec.id + ".m3u8"
    c = CreateObject("roSGNode", "ContentNode")
    c.url = m.pvUrl
    c.streamFormat = "hls"
    c.title = rec.name
    m.video.translation = [760, 160]
    m.video.width = 420
    m.video.height = 236
    m.video.content = c
    m.video.visible = true
    m.video.control = "play"
end sub

sub previewReset()
    m.pvTimer.control = "stop"
    if m.pvOn then
        m.pvOn = false
        m.video.control = "stop"
        m.video.visible = false
        m.video.translation = [0, 0]
        m.video.width = 1280
        m.video.height = 720
    end if
end sub

sub onPreviewState(st as string)
    if st <> "error" then return
    if not m.pvTs and m.pvRec <> invalid then
        m.pvTs = true
        c = CreateObject("roSGNode", "ContentNode")
        c.url = Left(m.pvUrl, Len(m.pvUrl) - 5) + ".ts"
        c.streamFormat = "ts"
        c.title = m.pvRec.name
        m.video.content = c
        m.video.control = "play"
        return
    end if
    m.video.control = "stop"
    m.epg.text = "Preview is not available for this channel"
end sub

sub onGuideSelect()
    playIndex(m.guide.itemSelected)
end sub

sub onGuideFocus()
    m.gdTimer.control = "stop"
    m.gdTimer.control = "start"
end sub

sub onGdTimer()
    if m.tab = 0 and m.liveMode = 1 and not m.gdBusy then guideNext()
end sub

sub buildGuide()
    c = CreateObject("roSGNode", "ContentNode")
    n = 0
    for each rec in m.items
        if n >= 300 then exit for
        ch = c.createChild("ContentNode")
        ch.title = itemLabel(rec)
        ch.hdPosterUrl = posterFor(rec)
        ch.shortDescriptionLine1 = ""
        n = n + 1
    end for
    m.guide.content = c
    m.guide.jumpToItem = 0
    m.gd = { done: {} }
    m.gdBusy = false
    if n = 0 then
        m.status.text = "Pick a category with channels"
        return
    end if
    guideNext()
end sub

sub guideNext()
    if m.tab <> 0 or m.liveMode <> 1 or m.pane <> "browse" then return
    src = activeSource()
    cnt = m.guide.content
    if src = invalid or cnt = invalid then return
    n = cnt.getChildCount()
    idx = m.guide.itemFocused
    if idx < 0 then idx = 0
    pick = -1
    for k = 0 to 39
        j = idx + k
        if j >= n or j >= m.items.count() then exit for
        if m.gd.done[j.toStr()] = invalid then
            pick = j
            exit for
        end if
    end for
    if pick < 0 then
        m.gdBusy = false
        return
    end if
    m.gd.done[pick.toStr()] = true
    m.gdIdx = pick
    m.gdBusy = true
    request(apiUrl(src, "&action=get_short_epg&stream_id=" + m.items[pick].id + "&limit=2"), "gd")
end sub

sub onGdData(data as dynamic)
    cnt = m.guide.content
    if cnt <> invalid and m.gdIdx >= 0 and m.gdIdx < cnt.getChildCount() then
        node = cnt.getChild(m.gdIdx)
        if type(data) = "roAssociativeArray" and type(data.epg_listings) = "roArray" and data.epg_listings.count() > 0 then
            l = data.epg_listings
            st = Int(num(l[0].start_timestamp))
            en = Int(num(l[0].stop_timestamp))
            if l.count() > 1 then node.shortDescriptionLine2 = b64(l[1].title)
            nowTs = CreateObject("roDateTime").asSeconds()
            if en > st and nowTs >= st then
                node.length = en - st
                el = nowTs - st
                if el > en - st then el = en - st
                node.playStart = el
            end if
            node.shortDescriptionLine1 = b64(l[0].title) + "   " + fmtTime(st)
        else
            node.shortDescriptionLine1 = "No guide data"
        end if
    end if
    guideNext()
end sub

' ---------- player bar (audio, subtitles, channels, episodes) ----------
function episodeListFor(rec as object) as dynamic
    if m.epSeason = invalid or rec.season = invalid or rec.series = invalid then return invalid
    lst = m.epSeason[rec.season]
    if lst = invalid or lst.count() = 0 then return invalid
    if lst[0].series <> rec.series then return invalid
    return lst
end function

sub showPlayerBar(focus as boolean)
    rec = m.playRec
    if rec = invalid then return
    m.pbActs = [{ lab: "Audio & Subtitles", act: "tracks" }]
    if rec.kind = "live" and liveCount() > 1 then m.pbActs.push({ lab: "Channels", act: "chan" })
    if rec.kind = "episode" and episodeListFor(rec) <> invalid then m.pbActs.push({ lab: "Episodes", act: "eps" })
    if m.pbIdx >= m.pbActs.count() then m.pbIdx = 0
    hideToastNow()
    m.pbar.visible = true
    if focus then
        m.area = "pbar"
        focusScene()
        m.pbarTimer.duration = 9
    else
        m.pbarTimer.duration = 5
    end if
    renderPlayerBar()
    m.pbarTimer.control = "stop"
    m.pbarTimer.control = "start"
end sub

function liveCount() as integer
    n = 0
    for each it in m.items
        if it.kind = "live" then n = n + 1
    end for
    return n
end function

sub renderPlayerBar()
    rec = m.playRec
    if rec = invalid then return
    title = rec.name
    sub1 = ""
    if rec.kind = "live" then
        if m.playIdx >= 0 then sub1 = "Channel " + (m.playIdx + 1).toStr() + " of " + m.items.count().toStr()
        if m.pbEpg <> "" then
            if sub1 <> "" then sub1 = sub1 + "     "
            sub1 = sub1 + m.pbEpg
        end if
    else if rec.kind = "episode" then
        if rec.series <> invalid then
            title = rec.series
            sub1 = rec.name
        end if
    end if
    m.top.findNode("ptitle").text = title
    m.top.findNode("ptitle").font = mkFont(28, true)
    ps = m.top.findNode("psub")
    ps.translation = [60, 640]
    ps.width = 1160
    ps.font = mkFont(20, false)
    ps.text = sub1
    while m.pbtns.getChildCount() > 0
        m.pbtns.removeChildIndex(0)
    end while
    x = 1220
    for i = m.pbActs.count() - 1 to 0 step -1
        lab = m.pbActs[i].lab
        w = 40 + Len(lab) * 10
        x = x - w
        r = CreateObject("roSGNode", "Rectangle")
        r.translation = [x, 596]
        r.width = w
        r.height = 40
        l = CreateObject("roSGNode", "Label")
        l.translation = [x, 596]
        l.width = w
        l.height = 40
        l.text = lab
        l.horizAlign = "center"
        l.vertAlign = "center"
        l.font = mkFont(18, true)
        if m.area = "pbar" and i = m.pbIdx then
            r.color = "0xF5C400"
            l.color = "0x080D0F"
        else
            r.color = "0x20383D"
            l.color = "0xFFFFFF"
        end if
        m.pbtns.appendChild(r)
        m.pbtns.appendChild(l)
        x = x - 12
    end for
    if m.area = "pbar" then
        h = "Left/Right: choose     OK: open     Back: hide"
    else if rec.kind = "live" then
        h = "Left/Right: change channel     Replay: last channel     Up, Down or OK: audio, subtitles and channels     Back: stop"
    else
        h = "OK: pause     Left/Right: skip     Down: audio, subtitles and episodes     Back: stop"
    end if
    m.top.findNode("phint").text = h
end sub

sub pbarKey(key as string)
    m.pbarTimer.control = "stop"
    m.pbarTimer.control = "start"
    if key = "left" then
        if m.pbIdx > 0 then m.pbIdx = m.pbIdx - 1
        renderPlayerBar()
    else if key = "right" then
        if m.pbIdx < m.pbActs.count() - 1 then m.pbIdx = m.pbIdx + 1
        renderPlayerBar()
    else if key = "OK" then
        act = m.pbActs[m.pbIdx].act
        hidePlayerBar()
        if act = "tracks" then
            openTracks()
        else if act = "chan" then
            openChannelsPanel()
        else if act = "eps" then
            openEpisodesPanel()
        end if
    else if key = "back" or key = "up" or key = "down" then
        hidePlayerBar()
    end if
end sub

sub hidePlayerBar()
    m.pbar.visible = false
    m.pbarTimer.control = "stop"
    if m.area = "pbar" then
        m.area = "video"
        m.video.setFocus(true)
    end if
end sub

sub onPbarTimer()
    if m.area = "video" or m.area = "pbar" then hidePlayerBar()
end sub

sub openChannelsPanel()
    labels = []
    m.trkActs = []
    cur = 0
    for i = 0 to m.items.count() - 1
        if labels.count() >= 400 then exit for
        it = m.items[i]
        if it.kind = "live" then
            if m.playRec <> invalid and it.id = m.playRec.id then cur = labels.count()
            labels.push(itemLabel(it))
            m.trkActs.push({ kind: "chan", id: i })
        end if
    end for
    if labels.count() < 2 then
        showToast("No other channels in this list")
        return
    end if
    showPanel(labels, cur)
end sub

sub openEpisodesPanel()
    rec = m.playRec
    if rec = invalid then return
    lst = episodeListFor(rec)
    if lst = invalid then
        showToast("Open the series page to pick another episode")
        return
    end if
    labels = []
    m.trkActs = []
    cur = 0
    for i = 0 to lst.count() - 1
        e = lst[i]
        if e.id = rec.id then cur = i
        lb = "E" + e.num + "  " + e.title
        if isWatched(e) then lb = lb + "   (seen)"
        labels.push(lb)
        m.trkActs.push({ kind: "ep", rec: e })
    end for
    showPanel(labels, cur)
end sub

' ---------- remote keys ----------
function onKeyEvent(key as string, press as boolean) as boolean
    print "KEY "; key; " press="; press; " area="; m.area
    if not press then return false
    a = m.area
    if a = "video" then
        if key = "back" then
            stopVideo()
            return true
        else if key = "options" then
            showPlayerBar(true)
            return true
        else if key = "OK" and m.playRec <> invalid and m.playRec.kind = "live" then
            showPlayerBar(true)
            return true
        else if key = "replay" and m.playRec <> invalid and m.playRec.kind = "live" and m.prevLive <> invalid then
            pv = m.prevLive
            m.playIdx = -1
            for pi = 0 to m.items.count() - 1
                if m.items[pi].id = pv.id and m.items[pi].kind = "live" then m.playIdx = pi
            end for
            m.video.control = "stop"
            startPlayback(pv, m.backTo)
            return true
        else if (key = "down" or key = "up") and m.playRec <> invalid and m.playRec.kind <> "live" and key = "down" then
            showPlayerBar(true)
            return true
        else if (key = "down" or key = "up") and m.playRec <> invalid and m.playRec.kind = "live" then
            showPlayerBar(true)
            return true
        else if (key = "left" or key = "right") and m.playRec <> invalid and m.playRec.kind = "live" and m.playIdx >= 0 then
            stp = 1
            if key = "left" then stp = -1
            ni = m.playIdx + stp
            while ni >= 0 and ni < m.items.count() and m.items[ni].kind <> "live"
                ni = ni + stp
            end while
            if ni >= 0 and ni < m.items.count() then
                m.playIdx = ni
                m.video.control = "stop"
                startPlayback(m.items[ni], m.backTo)
            end if
            return true
        end if
        return false
    end if
    if a = "nav" then
        if key = "left" and m.tab > -1 then
            m.tab = m.tab - 1
            updateNav()
            m.navTimer.control = "stop"
            m.navTimer.control = "start"
        else if key = "right" and m.tab < 4 then
            m.tab = m.tab + 1
            updateNav()
            m.navTimer.control = "stop"
            m.navTimer.control = "start"
        else if key = "OK" or key = "down" then
            if m.loadedTab <> m.tab then
                openTab(false)
            else if m.tab = -1 then
                setArea("home")
            else if m.tab = 3 or m.tab = 4 then
                setArea("list")
            else if m.tab = 0 then
                setArea("modes")
            else if m.catIds.count() > 0 then
                setArea("cats")
            end if
        end if
        return true
    end if
    if a = "search" then
        if key = "OK" then
            openSearchKeyboard()
        else if key = "down" then
            setArea("cats")
        else if key = "right" then
            if rightNode().content <> invalid then setArea("grid")
        else if key = "up" or key = "back" then
            if m.tab = 0 then
                setArea("modes")
            else
                setArea("nav")
            end if
        end if
        return true
    end if
    if a = "modes" then
        if key = "left" and m.liveMode > 0 then
            setLiveMode(m.liveMode - 1)
        else if key = "right" and m.liveMode < 2 then
            setLiveMode(m.liveMode + 1)
        else if key = "up" or key = "back" then
            setArea("nav")
        else if key = "down" or key = "OK" then
            setArea("search")
        end if
        return true
    end if
    if a = "pbar" then
        pbarKey(key)
        return true
    end if
    if a = "tracks" then
        if key = "back" then
            closeTracks()
            return true
        end if
        return false
    end if
    if a = "autonext" then
        if key = "back" then cancelAuto()
        return true
    end if
    if a = "detail" then
        if key = "up" and m.dIdx > 0 then
            m.dIdx = m.dIdx - 1
            renderDetailChips()
        else if key = "down" and m.dIdx < m.dLabels.count() - 1 then
            m.dIdx = m.dIdx + 1
            renderDetailChips()
        else if key = "OK" then
            detailAction(m.dIdx)
        else if key = "back" then
            closeDetail()
        else if key = "options" then
            toggleFav(m.detailRec)
            refreshDetailButtons()
        end if
        return true
    end if
    if a = "sdbtn" then
        if key = "left" and m.sdBtnIdx > 0 then
            m.sdBtnIdx = m.sdBtnIdx - 1
            renderSdChips()
        else if key = "right" and m.sdBtnIdx < m.sdBtnLabels.count() - 1 then
            m.sdBtnIdx = m.sdBtnIdx + 1
            renderSdChips()
        else if key = "OK" then
            sdAction(m.sdBtnIdx)
        else if key = "down" then
            if m.seasonLabels.count() > 0 then
                setArea("sdseason")
            else
                m.status.text = "Episodes still loading"
            end if
        else if key = "back" then
            closeDetail()
        else if key = "options" then
            toggleFav(m.detailRec)
            refreshSdButtons()
        end if
        return true
    end if
    if a = "sdseason" then
        if key = "left" and m.curSeasonIdx > 0 then
            showSeason(m.curSeasonIdx - 1)
        else if key = "right" and m.curSeasonIdx < m.seasonKeys.count() - 1 then
            showSeason(m.curSeasonIdx + 1)
        else if key = "OK" or key = "down" then
            setArea("sdeps")
        else if key = "up" then
            setArea("sdbtn")
        else if key = "back" then
            closeDetail()
        end if
        return true
    end if
    if a = "pform" then
        if key = "back" then
            showSources()
        else
            pfKey(key)
        end if
        return true
    end if
    if a = "sdeps" then
        if key = "up" then
            setArea("sdseason")
            return true
        else if key = "back" then
            closeDetail()
            return true
        else if key = "options" then
            toggleWatchedFocused()
            return true
        end if
        return false
    end if
    if key = "back" then
        if a = "list" and (m.mode = "form" or m.mode = "addtype") then
            showSources()
        else if a = "grid" then
            setArea("cats")
        else if a = "cats" and m.tab = 0 then
            setArea("modes")
        else if a = "detail" then
            closeDetail()
        else if a = "eps" then
            setPane("detail")
            setArea("detail")
        else
            setArea("nav")
        end if
        return true
    else if key = "options" and (a = "grid" or a = "home" or a = "list" or a = "detail" or a = "cats") then
        onOptionsKey()
        return true
    else if key = "up" and a = "cats" and m.tab >= 0 and m.tab <= 2 then
        setArea("search")
        return true
    else if key = "up" and (a = "cats" or a = "list" or a = "home") then
        setArea("nav")
        return true
    else if key = "right" and a = "cats" then
        if rightNode().content <> invalid then setArea("grid")
        return true
    else if key = "left" and a = "grid" then
        setArea("cats")
        return true
    else if key = "up" and a = "grid" then
        cols = m.grid.numColumns
        if m.tab = 0 and m.liveMode > 0 then cols = 1
        if rightNode().itemFocused < cols then
            if m.tab = 0 then
                setArea("modes")
            else
                setArea("nav")
            end if
        end if
        return true
    else if key = "left" and a = "eps" then
        setPane("detail")
        setArea("detail")
        return true
    else if key = "play" and a = "grid" then
        cycleSort()
        return true
    end if
    return false
end function

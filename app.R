# ============================================================
#  DIMANAKAH...? — Game Geografi Kabupaten/Kota Pulau Jawa
#  + Zoom In/Out & Pan pada peta
#  + Identitas Kelompok 5 di splash screen
# ============================================================
library(shiny)

setwd("C:/Users/HP/Documents/2 Sistem Informasi Manajemen/membuat aplikasi sederhana rshiny/apayak")
source("map_data.R")

n_total <- length(map_features)

# ── UI ────────────────────────────────────────────────────────
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Press+Start+2P&family=VT323:wght@400&display=swap');
      * { box-sizing: border-box; }
      body {
        background: #1a1a2e;
        margin: 0; padding: 16px;
        font-family: 'VT323', monospace;
        display: flex; justify-content: center;
        min-height: 100vh;
      }
      #game-window {
        width: 980px;
        background: #c0d8e8;
        border: 4px solid #7aa0b8;
        box-shadow: 6px 6px 0 #2c4a5e, inset 2px 2px 0 #fff;
      }
      #title-bar {
        background: linear-gradient(90deg,#2a6496 0%,#4a90c4 45%,#2a6496 100%);
        padding: 5px 10px;
        display: flex; align-items: center; justify-content: space-between;
        border-bottom: 3px solid #1a4060;
      }
      .title-text {
        font-family: 'Press Start 2P', monospace;
        font-size: 9px; color: #fff;
        text-shadow: 2px 2px 0 #000; letter-spacing: 1px;
      }
      .win-btns { display:flex; gap:4px; }
      .win-btn {
        width:18px; height:18px; border: 2px solid;
        display:flex; align-items:center; justify-content:center;
        font-size:10px; font-weight:bold; cursor:pointer;
      }
      .win-btn-r { background:#e05050; border-color:#ff8888 #882020 #882020 #ff8888; color:#fff; }
      #question-bar {
        background: #d4eaf7;
        border-bottom: 3px solid #7aa0b8;
        border-top: 2px solid #fff;
        padding: 9px 20px;
        display: flex; align-items: center; justify-content: center; gap: 14px;
        flex-wrap: wrap;
      }
      .q-label { font-family:'VT323',monospace; font-size:24px; color:#2c4a5e; }
      .q-name {
        font-family:'Press Start 2P',monospace; font-size:13px; color:#1a1a2e;
        background:#fff; padding:7px 22px;
        border: 3px solid #2a6496;
        border-bottom-color:#1a3050; border-right-color:#1a3050;
        min-width:240px; text-align:center; letter-spacing:2px;
        animation: blink-border 1.2s step-end infinite;
      }
      @keyframes blink-border {
        0%,100%{border-color:#2a6496 #1a3050 #1a3050 #2a6496}
        50%{border-color:#c84040 #601010 #601010 #c84040}
      }
      #map-area {
        background: #5ba4cf;
        position: relative; overflow: hidden; cursor: grab;
        border-bottom: 3px solid #7aa0b8;
        user-select: none;
      }
      #map-area:active { cursor: grabbing; }
      #map-area svg { display:block; width:100%; }
      .kab-path {
        cursor: pointer;
        stroke: rgba(0,0,0,0.30); stroke-width: 0.7px;
        transition: filter 0.08s;
      }
      .kab-path:hover { filter: brightness(1.22) drop-shadow(0 0 3px rgba(255,255,255,0.6)); stroke-width:1.4px; stroke:rgba(0,0,0,0.7); }
      .kab-path.correct { fill: #00dd44 !important; stroke:#005522 !important; stroke-width:2px !important; }
      .kab-path.wrong   { fill: #ff3333 !important; stroke:#880000 !important; stroke-width:2px !important; }
      .kab-path.target  { stroke:#ffff00 !important; stroke-width:2.5px !important; animation: glow-target 0.7s step-end infinite; }
      @keyframes glow-target { 0%,100%{stroke:#ffff00} 50%{stroke:#ff8800} }

      /* ── ZOOM CONTROLS ── */
      #zoom-controls {
        position: absolute; top: 10px; right: 10px;
        display: flex; flex-direction: column; gap: 4px; z-index: 50;
      }
      .zoom-btn {
        font-family:'Press Start 2P',monospace; font-size:14px;
        width:32px; height:32px;
        background:#1a1a2e; color:#ffff44;
        border:2px solid #4a4a6e; cursor:pointer;
        display:flex; align-items:center; justify-content:center;
      }
      .zoom-btn:hover { background:#2a2a4e; }
      .zoom-reset {
        font-size:9px; width:32px; height:24px;
        background:#2c4a5e; color:#aaddff;
        border:2px solid #4a7a9a;
      }

      #toolbar {
        background: #b8d0e4;
        border-top: 3px solid #fff;
        border-bottom: 3px solid #7aa0b8;
        padding: 8px 16px;
        display:flex; align-items:center; justify-content:space-between; gap:10px;
      }
      .px-btn {
        font-family:'Press Start 2P',monospace; font-size:9px;
        padding: 8px 14px; border:3px solid; cursor:pointer;
        letter-spacing:1px; position:relative; top:0; user-select:none;
      }
      .px-btn:active { top:2px; }
      .px-btn-blue { background:#4a90c4; color:#fff; border-color:#7ab8e8 #1a5080 #1a5080 #7ab8e8; text-shadow:1px 1px 0 #000; }
      .px-btn-blue:hover { background:#5aa0d4; }
      .px-btn-gray { background:#9ab8c8; color:#1a1a2e; border-color:#cce0ee #5a8099 #5a8099 #cce0ee; }
      .px-btn-gray:hover { background:#aac8d8; }
      .px-btn-red  { background:#e05050; color:#fff; border-color:#ff8888 #882020 #882020 #ff8888; text-shadow:1px 1px 0 #000; }
      .px-btn-red:hover  { background:#f06060; }
      .stat-box {
        font-family:'Press Start 2P',monospace; font-size:10px;
        padding: 7px 13px; border:3px solid;
        min-width:80px; text-align:center; letter-spacing:1px;
      }
      #timer-box { background:#1a1a2e; color:#ffff44; border-color:#4a4a6e; }
      #timer-box.urgent { color:#ff4444; animation:blink-r 0.5s step-end infinite; }
      @keyframes blink-r { 0%,100%{color:#ff4444}50%{color:#ff9999} }
      #score-box  { background:#1a1a2e; color:#44ff88; border-color:#2a5a3a; }
      #counter-box{ background:#2c4a5e; color:#aaddff; border-color:#4a7a9a #0a1a2e #0a1a2e #4a7a9a; }
      #feedback-toast {
        position:absolute; top:50%; left:50%;
        transform:translate(-50%,-50%);
        font-family:'Press Start 2P',monospace; font-size:22px;
        padding:18px 36px; border:4px solid;
        text-align:center; pointer-events:none; z-index:999; display:none;
        text-shadow: 2px 2px 0 #000;
      }
      .toast-ok  { background:#009933; color:#ccffdd; border-color:#44ff88 #004411 #004411 #44ff88; }
      .toast-err { background:#cc2222; color:#ffcccc; border-color:#ff8888 #660000 #660000 #ff8888; }
      @keyframes popIn {
        from{transform:translate(-50%,-50%) scale(0.4);opacity:0}
        to{transform:translate(-50%,-50%) scale(1);opacity:1}
      }
      .toast-pop { animation: popIn 0.25s cubic-bezier(0.34,1.56,0.64,1); }
      #hint-popup {
        position:absolute; top:10px; left:50%; transform:translateX(-50%);
        font-family:'Press Start 2P',monospace; font-size:8px; color:#fff;
        background:#1a3a5a; border:3px solid #aaddff;
        border-bottom-color:#0a1a2a; border-right-color:#0a1a2a;
        padding:10px 18px; z-index:998; display:none;
        text-align:center; line-height:2; letter-spacing:1px; white-space:nowrap;
      }
      #prog-wrap { background:#7aa0b8; border-top:2px solid #5a8099; height:10px; }
      #prog-fill  { height:100%; background:linear-gradient(90deg,#44ff88,#00aa55); transition:width .4s; }
      #legend {
        background:#b8d0e4; padding:5px 16px;
        display:flex; align-items:center; gap:10px; flex-wrap:wrap;
      }
      .leg-lbl { font-family:'Press Start 2P',monospace; font-size:7px; color:#2c4a5e; }
      .leg-item { display:flex; align-items:center; gap:4px; font-family:'VT323',monospace; font-size:14px; color:#1a3050; }
      .leg-swatch { width:14px; height:14px; border:2px solid rgba(0,0,0,0.3); flex-shrink:0; }

      /* ── OVERLAY ── */
      #overlay {
        position:absolute; inset:0;
        background:rgba(8,14,30,0.92);
        display:flex; flex-direction:column;
        align-items:center; justify-content:center; gap:12px; z-index:1000;
        padding: 20px;
      }
      #overlay.hidden { display:none; }
      .ov-title {
        font-family:'Press Start 2P',monospace; font-size:22px; color:#ffff44;
        text-shadow:3px 3px 0 #884400, 5px 5px 0 #000;
        letter-spacing:3px; text-align:center; line-height:1.6;
      }
      .ov-sub   { font-family:'VT323',monospace; font-size:24px; color:#aaddff; text-align:center; }
      .ov-score { font-family:'Press Start 2P',monospace; font-size:16px; color:#44ff88; text-shadow:2px 2px 0 #005522; }
      .ov-grade { font-family:'Press Start 2P',monospace; font-size:18px; color:#ffff44; }

      /* ── IDENTITY CARD ── */
      .id-card {
        background: #0d1b2e;
        border: 2px solid #2a6496;
        border-bottom-color: #0a1a2e; border-right-color: #0a1a2e;
        padding: 12px 24px;
        text-align: center;
        width: 100%;
        max-width: 480px;
      }
      .id-card-title {
        font-family:'Press Start 2P',monospace; font-size:8px;
        color:#ffff44; letter-spacing:2px; margin-bottom:8px;
        border-bottom: 1px solid #2a6496; padding-bottom:6px;
      }
      .id-card-group {
        font-family:'Press Start 2P',monospace; font-size:10px;
        color:#44ff88; margin-bottom:10px; letter-spacing:1px;
      }
      .id-member-row {
        display:flex; justify-content:space-between; align-items:center;
        padding: 3px 0;
        border-bottom: 1px solid #1a3a5a;
        gap: 12px;
      }
      .id-member-row:last-child { border-bottom: none; }
      .id-nim  { font-family:'VT323',monospace; font-size:16px; color:#aaddff; white-space:nowrap; }
      .id-name { font-family:'VT323',monospace; font-size:16px; color:#ffffff; text-align:right; }
    "))
  ),
  
  tags$div(id="game-window",
           tags$div(id="title-bar",
                    tags$span(class="title-text", "DIMANAKAH...?  Kabupaten & Kota Pulau Jawa")
           ),
           tags$div(id="question-bar",
                    tags$span(class="q-label", "DIMANAKAH..."),
                    uiOutput("q_name_ui"),
                    tags$span(class="q-label", "...?")
           ),
           tags$div(id="map-area", style="position:relative;",
                    uiOutput("map_ui"),
                    # Zoom buttons
                    tags$div(id="zoom-controls",
                             tags$div(class="zoom-btn", id="zoom-in-btn",  "+"),
                             tags$div(class="zoom-btn", id="zoom-out-btn", "−"),
                             tags$div(class="zoom-btn zoom-reset", id="zoom-reset-btn", "↺")
                    ),
                    tags$div(id="feedback-toast"),
                    tags$div(id="hint-popup"),
                    uiOutput("overlay_ui")
           ),
           tags$div(id="prog-wrap", tags$div(id="prog-fill", style="width:0%")),
           tags$div(id="toolbar",
                    tags$div(style="display:flex;gap:8px;align-items:center;",
                             tags$div(id="timer-box", class="stat-box", uiOutput("timer_ui")),
                             tags$div(id="score-box", class="stat-box", uiOutput("score_ui"))
                    ),
                    tags$div(style="display:flex;gap:8px;align-items:center;",
                             uiOutput("prov_hint_ui")
                    ),
                    tags$div(style="display:flex;gap:8px;align-items:center;",
                             tags$div(id="counter-box", class="stat-box", uiOutput("counter_ui")),
                             actionButton("skip_btn", "SKIP", class="px-btn px-btn-gray")
                    )
           ),
           tags$div(id="legend",
                    tags$span(class="leg-lbl", "PROVINSI:"),
                    lapply(list(
                      list("Banten",       "#F4A261"),
                      list("DKI Jakarta",  "#E76F51"),
                      list("Jawa Barat",   "#52B788"),
                      list("Jawa Tengah",  "#4895EF"),
                      list("DI Yogyakarta","#FFD700"),
                      list("Jawa Timur",   "#C77DFF")
                    ), function(x) {
                      tags$div(class="leg-item",
                               tags$div(class="leg-swatch", style=paste0("background:",x[[2]],";")),
                               x[[1]])
                    })
           )
  ),
  
  tags$script(HTML("
  // ── TIMER ──
  var timerInterval = null, timeLeft = 60;
  Shiny.addCustomMessageHandler('start_timer', function(s){
    clearInterval(timerInterval); timeLeft=s; renderTimer();
    timerInterval = setInterval(function(){
      timeLeft--; renderTimer();
      if(timeLeft<=0){ clearInterval(timerInterval); Shiny.setInputValue('timer_done',Math.random()); }
    },1000);
  });
  Shiny.addCustomMessageHandler('stop_timer',  function(){ clearInterval(timerInterval); });
  Shiny.addCustomMessageHandler('set_prog',    function(p){ var e=document.getElementById('prog-fill'); if(e) e.style.width=p+'%'; });
  Shiny.addCustomMessageHandler('set_hint_n',  function(n){ var e=document.getElementById('hint-n'); if(e) e.innerHTML='×'+n; });
  Shiny.addCustomMessageHandler('show_toast',  function(m){
    var e=document.getElementById('feedback-toast');
    e.textContent=m.text; e.className=m.ok?'toast-ok toast-pop':'toast-err toast-pop';
    e.style.display='block';
    setTimeout(function(){ e.style.display='none'; e.className=''; },900);
  });
  Shiny.addCustomMessageHandler('show_hint_popup', function(m){
    var e=document.getElementById('hint-popup');
    e.innerHTML=m; e.style.display='block';
    setTimeout(function(){ e.style.display='none'; },3200);
  });
  function renderTimer(){
    var e=document.getElementById('timer-box'); if(!e) return;
    var s=timeLeft<10?'0'+timeLeft:''+timeLeft;
    e.textContent=s;
    if(timeLeft<=5) e.classList.add('urgent'); else e.classList.remove('urgent');
  }

  // ── ZOOM & PAN — transform pada div#map-wrapper ──
  var scale = 1, panX = 0, panY = 0;
  var MIN_SCALE = 1, MAX_SCALE = 8;
  var isPanning = false, startMX = 0, startMY = 0, startPX = 0, startPY = 0;

  function getWrapper() {
    return document.getElementById('map-wrapper');
  }

  function applyTransform() {
    var w = getWrapper(); if (!w) return;
    w.style.transformOrigin = '0 0';
    w.style.transform = 'translate(' + panX + 'px, ' + panY + 'px) scale(' + scale + ')';
  }

  function clampPan() {
    var area = document.getElementById('map-area'); if (!area) return;
    var W = area.clientWidth, H = area.clientHeight;
    var maxPanX =  W * 0.9;
    var minPanX = -W * (scale - 0.1);
    var maxPanY =  H * 0.9;
    var minPanY = -H * (scale - 0.1);
    panX = Math.max(minPanX, Math.min(maxPanX, panX));
    panY = Math.max(minPanY, Math.min(maxPanY, panY));
  }

  function zoomAt(clientX, clientY, factor) {
    var area = document.getElementById('map-area'); if (!area) return;
    var rect = area.getBoundingClientRect();
    var mx = clientX - rect.left;
    var my = clientY - rect.top;
    var newScale = Math.min(MAX_SCALE, Math.max(MIN_SCALE, scale * factor));
    var ratio = newScale / scale;
    panX = mx - ratio * (mx - panX);
    panY = my - ratio * (my - panY);
    scale = newScale;
    clampPan();
    applyTransform();
  }

  // ── Scroll wheel ──
  document.addEventListener('wheel', function(e){
    var area = document.getElementById('map-area');
    if (!area || !area.contains(e.target)) return;
    e.preventDefault();
    zoomAt(e.clientX, e.clientY, e.deltaY < 0 ? 1.2 : 1/1.2);
  }, {passive: false});

  // ── Tombol zoom ──
  document.addEventListener('click', function(e){
    var area = document.getElementById('map-area'); if (!area) return;
    var rect = area.getBoundingClientRect();
    var cx = rect.left + rect.width / 2;
    var cy = rect.top  + rect.height / 2;
    if (e.target.id === 'zoom-in-btn')    { zoomAt(cx, cy, 1.4); }
    if (e.target.id === 'zoom-out-btn')   { zoomAt(cx, cy, 1/1.4); }
    if (e.target.id === 'zoom-reset-btn') { scale=1; panX=0; panY=0; applyTransform(); }
  });

  // ── Drag to pan ──
  document.addEventListener('mousedown', function(e){
    var area = document.getElementById('map-area');
    if (!area || !area.contains(e.target)) return;
    if (e.target.classList.contains('kab-path')) return;
    isPanning = true;
    startMX = e.clientX; startMY = e.clientY;
    startPX = panX;      startPY = panY;
    e.preventDefault();
  });
  document.addEventListener('mousemove', function(e){
    if (!isPanning) return;
    panX = startPX + (e.clientX - startMX);
    panY = startPY + (e.clientY - startMY);
    clampPan();
    applyTransform();
  });
  document.addEventListener('mouseup',    function(){ isPanning = false; });
  document.addEventListener('mouseleave', function(){ isPanning = false; });

  // ── Re-apply transform setelah Shiny re-render ──
  var observer = new MutationObserver(function(mutations){
    var w = getWrapper();
    if (w) applyTransform();
  });
  function attachObserver(){
    var area = document.getElementById('map-area');
    if (area) observer.observe(area, {childList:true, subtree:false});
  }
  if (document.readyState === 'loading'){
    document.addEventListener('DOMContentLoaded', attachObserver);
  } else {
    attachObserver();
  }
"))
)

# ── SERVER ────────────────────────────────────────────────────
server <- function(input, output, session) {
  
  rv <- reactiveValues(
    queue       = sample(seq_len(n_total)),
    cur         = 1,
    correct_ids = character(0),
    wrong_ids   = character(0),
    score       = 0,
    state       = "start"
  )
  
  cur_feat <- reactive({
    if (rv$cur > n_total) return(NULL)
    map_features[[ rv$queue[rv$cur] ]]
  })
  
  reset_game <- function() {
    rv$queue       <- sample(seq_len(n_total))
    rv$cur         <- 1
    rv$correct_ids <- character(0)
    rv$wrong_ids   <- character(0)
    rv$score       <- 0
    rv$state       <- "playing"
    session$sendCustomMessage("set_prog", 0)
    session$sendCustomMessage("start_timer", 60)
  }
  
  advance <- function() {
    rv$cur <- rv$cur + 1
    if (rv$cur > 10) {
      rv$state <- "gameover"
      session$sendCustomMessage("stop_timer", 1)
    } else {
      pct <- round((rv$cur - 1) / 10 * 100)
      session$sendCustomMessage("set_prog", pct)
    }
  }
  
  observeEvent(input$start_btn, reset_game())
  
  observeEvent(input$home_btn, {
    session$sendCustomMessage("stop_timer", 1)
    rv$state <- "start"
  })
  
  observeEvent(input$timer_done, {
    if (rv$state != "playing") return()
    rv$state <- "gameover"
    session$sendCustomMessage("show_toast", list(text="TIME'S UP!", ok=FALSE))
  })
  
  observeEvent(input$kab_click, {
    if (rv$state != "playing") return()
    f <- cur_feat(); if (is.null(f)) return()
    clicked <- input$kab_click
    if (clicked == f$id) {
      rv$score       <- rv$score + 10L
      rv$correct_ids <- c(rv$correct_ids, f$id)
      session$sendCustomMessage("show_toast", list(text="BENAR! ✓", ok=TRUE))
    } else {
      rv$wrong_ids <- c(rv$wrong_ids, clicked)
      session$sendCustomMessage("show_toast", list(text="SALAH! ✕", ok=FALSE))
    }
    advance()
  })
  
  observeEvent(input$skip_btn, {
    if (rv$state != "playing") return()
    session$sendCustomMessage("show_toast", list(text="SKIP...", ok=FALSE))
    advance()
  })
  
  output$q_name_ui <- renderUI({
    f <- cur_feat()
    lbl <- if (!is.null(f) && rv$state == "playing") toupper(f$name) else "—"
    tags$span(class="q-name", lbl)
  })
  
  output$timer_ui   <- renderUI(tags$span("60"))
  output$score_ui   <- renderUI(tags$span(paste0(rv$score, " PT")))
  output$counter_ui <- renderUI(tags$span(paste0(rv$cur, "/10")))
  
  output$prov_hint_ui <- renderUI({
    f <- cur_feat()
    if (is.null(f) || rv$state != "playing") return(NULL)
    prov_label <- switch(f$prov,
                         "Jakarta Raya" = "DKI Jakarta",
                         "Yogyakarta"   = "DI Yogyakarta",
                         f$prov)
    tags$div(style="font-family:'VT323',monospace;font-size:16px;color:#2c4a5e;
                    background:#d4eaf7;padding:5px 12px;border:2px solid #7aa0b8;",
             paste0("🎯 ", prov_label))
  })
  
  # ── SVG MAP ──
  output$map_ui <- renderUI({
    correct_ids <- rv$correct_ids
    wrong_ids   <- rv$wrong_ids
    f_cur       <- cur_feat()
    target_id   <- if (!is.null(f_cur) && rv$state == "playing") f_cur$id else ""
    
    paths <- lapply(map_features, function(f) {
      cls <- paste(
        "kab-path",
        if (f$id %in% correct_ids) "correct" else "",
        if (f$id %in% wrong_ids)   "wrong"   else "",
        if (f$id == target_id && target_id %in% wrong_ids) "target" else ""
      )
      fill <- if (f$id %in% correct_ids) "#00dd44" else
        if (f$id %in% wrong_ids)   "#ff3333" else f$color
      tags$path(
        d=f$path, class=cls, fill=fill, title=f$name,
        onclick=sprintf("Shiny.setInputValue('kab_click','%s',{priority:'event'})", f$id)
      )
    })
    
    labels <- if (!is.null(f_cur) && rv$state == "playing") {
      lapply(map_features, function(f) {
        if (!(f$id %in% correct_ids) && !(f$id %in% wrong_ids)) return(NULL)
        short <- gsub("^Kab\\. |^Kota ", "", f$name)
        if (nchar(short) > 10) short <- paste0(substr(short,1,9),".")
        tags$text(x=f$cx, y=f$cy+4, `text-anchor`="middle",
                  style="font-family:'VT323',monospace;font-size:9px;fill:#fff;pointer-events:none;",
                  short)
      })
    } else list()
    
    tags$div(
      id    = "map-wrapper",
      style = "width:100%; height:100%; transform-origin:0 0; cursor:inherit;",
      tags$svg(
        xmlns="http://www.w3.org/2000/svg", viewBox="0 0 960 420",
        style="width:100%; display:block;",
        tags$rect(width="960", height="420", fill="#5ba4cf"),
        tags$defs(
          tags$pattern(id="dots", width="20", height="20",
                       patternUnits="userSpaceOnUse",
                       tags$circle(cx="1",cy="1",r="1",fill="rgba(255,255,255,0.05)"))
        ),
        tags$rect(width="960", height="420", fill="url(#dots)"),
        tags$g(id="map-g",
               do.call(tags$g, paths),
               do.call(tags$g, Filter(Negate(is.null), labels))
        )
      )
    )
  })
  
  # ── OVERLAY (splash / gameover) ──
  output$overlay_ui <- renderUI({
    if (rv$state == "start") {
      # ── SPLASH SCREEN dengan identitas kelompok ──
      tags$div(id="overlay",
               tags$div(class="ov-title", "DIMANAKAH...?"),
               tags$div(class="ov-sub", HTML(
                 "Temukan 10 Kabupaten/Kota<br>di Pulau Jawa dalam waktu 60 detik"
               )),
               
               tags$div(style="display:flex; gap:12px; margin-top:6px;",
                        
                        # Tombol MULAI GAME
                        actionButton("start_btn", "▶  MULAI GAME",
                                     class="px-btn px-btn-blue",
                                     style="font-size:13px; padding:14px 36px;"),
                        
                        # Tombol CREDITS
                        tags$button(
                          id="credits-btn",
                          class="px-btn px-btn-gray",
                          style="font-size:13px; padding:14px 36px;",
                          onclick="
          var card = document.getElementById('credits-card');
          if(card.style.display === 'none' || card.style.display === ''){
            card.style.display = 'block';
            this.textContent = '✕  TUTUP';
          } else {
            card.style.display = 'none';
            this.textContent = '★  DEVELOPER';
          }
        ",
                          "★  DEVELOPER"
                        )
               ),
               
               # ID Card — tersembunyi dulu, muncul saat klik DEVELOPER
               tags$div(
                 id="credits-card",
                 class="id-card",
                 style="display:none; margin-top:14px;",
                 
                 tags$div(class="id-card-title",
                          "✦  SISTEM INFORMASI MANAJEMEN  ✦"),
                 tags$div(class="id-card-group", "KELOMPOK 5"),
                 tags$div(class="id-member-row",
                          tags$span(class="id-nim",  "M0725022"),
                          tags$span(class="id-name", "Yaffa Zafirah Aswinda")),
                 tags$div(class="id-member-row",
                          tags$span(class="id-nim",  "M0725028"),
                          tags$span(class="id-name", "Nabilah Aulia Farhah")),
                 tags$div(class="id-member-row",
                          tags$span(class="id-nim",  "M0725077"),
                          tags$span(class="id-name", "Zahra Binta Azhari")),
                 tags$div(class="id-member-row",
                          tags$span(class="id-nim",  "M0725097"),
                          tags$span(class="id-name", "Naila Faza Rahma"))
               )
      )
      
    } else if (rv$state == "gameover") {
      nb   <- length(rv$correct_ids)
      pct  <- round(nb / 10 * 100)
      grade <- if(pct>=90) "S — SEMPURNA!" else if(pct>=70) "A — BAGUS!" else
        if(pct>=50) "B — LUMAYAN" else "C — BELAJAR LAGI!"
      
      tags$div(id="overlay",
               tags$div(class="ov-title", "GAME OVER"),
               tags$div(class="ov-score", paste0("SKOR: ", rv$score, " PT")),
               tags$div(class="ov-sub",   paste0("Benar: ", nb, " / 10  (", pct, "%)")),
               tags$div(class="ov-grade", grade),
               
               tags$div(style="display:flex; flex-direction:column; gap:10px; margin-top:10px;",
                        
                        # Tombol MAIN LAGI
                        actionButton("start_btn", "↺  MAIN LAGI",
                                     class="px-btn px-btn-red",
                                     style="font-size:13px; padding:14px 36px;"),
                        
                        # Tombol HOME
                        actionButton("home_btn", "⌂  HOME",
                                     class="px-btn px-btn-gray",
                                     style="font-size:13px; padding:14px 36px;")
               )
      )
    } else {
      tags$div(id="overlay", class="hidden")
    }
  })
}

`%||%` <- function(a, b) if (!is.null(a)) a else b
shinyApp(ui=ui, server=server)
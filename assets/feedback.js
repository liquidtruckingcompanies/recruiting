// Feedback button + form, shared by every page. Include after the Supabase script and set window.ltSb to the page's client.
// Signed-in users see a button in the header; submissions go to submit_feedback() and files to the private "feedback" bucket.
// A page can add its own details (e.g. selected county) by defining window.ltFeedbackContext = () => ({...}).
(function(){
  const MAX_FILES=5, MAX_BYTES=50*1024*1024;
  const KINDS=[["idea","💡 Idea"],["bug","🐞 Something's broken"],["other","💬 Other"]];
  const esc=s=>String(s??"").replace(/[&<>"]/g,c=>({"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;"}[c]));

  const css=`
.fbbtn{background:var(--brand-gold,#ecc01c);color:#1b2633;border:none;border-radius:999px;padding:7px 14px;font-family:var(--display,inherit);font-weight:700;font-size:.92rem;cursor:pointer;box-shadow:0 1px 3px rgba(0,0,0,.12);white-space:nowrap}
.fbbtn:hover{filter:brightness(.96)}
.fbdlg{position:fixed;inset:0;background:rgba(16,30,48,.5);display:grid;place-items:center;z-index:100;padding:16px}
.fbcard{background:#fff;color:#1b2633;border-radius:10px;border-top:6px solid var(--brand-gold,#ecc01c);padding:20px;width:min(560px,100%);max-height:calc(100vh - 32px);overflow:auto;display:grid;gap:12px;font-family:var(--body,system-ui,sans-serif);font-size:15px}
.fbcard h3{margin:0;font-family:var(--display,inherit);font-size:1.35rem;color:var(--heading,#105486)}
.fbcard p{margin:0}
.fbkinds{display:flex;gap:8px;flex-wrap:wrap}
.fbkinds label{border:1px solid #d1dae2;border-radius:999px;padding:6px 12px;cursor:pointer;font-weight:600;font-size:.9rem}
.fbkinds input{position:absolute;opacity:0;pointer-events:none}
.fbkinds label:has(input:checked){background:#105486;border-color:#105486;color:#fff}
.fbkinds label:has(input:focus-visible){outline:2px solid #105486;outline-offset:2px}
.fbcard textarea{width:100%;min-height:130px;border:1px solid #d1dae2;border-radius:6px;padding:9px;font:inherit;resize:vertical;box-sizing:border-box}
.fbdrop{border:2px dashed #b9c6d2;border-radius:8px;padding:12px;text-align:center;font-size:.88rem;color:#5a6878;cursor:pointer}
.fbdrop.over{border-color:#105486;background:#eef4f9}
.fbfiles{display:flex;gap:8px;flex-wrap:wrap}
.fbfile{position:relative;width:86px;height:70px;border-radius:6px;overflow:hidden;border:1px solid #d1dae2;background:#f4f7fa;display:grid;place-items:center;font-size:.7rem;text-align:center;padding:2px;box-sizing:border-box}
.fbfile img,.fbfile video{width:100%;height:100%;object-fit:cover}
.fbfile button{position:absolute;top:2px;right:2px;border:none;background:rgba(0,0,0,.6);color:#fff;border-radius:50%;width:20px;height:20px;line-height:18px;padding:0;cursor:pointer;font-size:.8rem}
.fbrow{display:flex;gap:8px;justify-content:space-between;align-items:center;flex-wrap:wrap}
.fbrow .btns{display:flex;gap:8px}
.fbcard .b{border-radius:5px;border:1px solid #346d98;background:#fff;color:#105486;padding:7px 14px;font-weight:600;cursor:pointer;font:inherit;font-weight:600}
.fbcard .b.primary{background:#105486;border-color:#105486;color:#fff}
.fbcard .b:disabled{opacity:.5;cursor:not-allowed}
.fbmsg{font-size:.85rem;color:#5a6878;min-height:1.2em}
.fbmsg.err{color:#b3261e}
.fbsmall{font-size:.8rem;color:#5a6878}
.fbcard a{color:#105486}
@media (max-width:700px){.fbbtn .fbfull{display:none}}`;

  let files=[], sending=false;
  function client(){ return window.ltSb||null; }
  function addStyles(){ const s=document.createElement("style"); s.textContent=css; document.head.appendChild(s); }

  function addButton(){
    if(document.getElementById("fbOpen")) return;
    const host=document.querySelector(".sitebar-in"); if(!host) return;
    const b=document.createElement("button"); b.type="button"; b.id="fbOpen"; b.className="fbbtn";
    b.innerHTML=`💡 <span class="fbfull">Got an idea or spot a problem?</span><span class="fbshort" aria-hidden="true"></span>`;
    b.setAttribute("aria-label","Send an idea, feedback or report a problem");
    b.onclick=open;
    const nav=host.querySelector(".sitenav");
    if(nav) nav.appendChild(b); else host.appendChild(b);
  }

  function renderFiles(){
    const box=document.getElementById("fbFiles"); if(!box) return;
    box.innerHTML="";
    files.forEach((f,i)=>{
      const d=document.createElement("div"); d.className="fbfile"; d.title=f.name;
      if(f.type.startsWith("image/")){ const im=document.createElement("img"); im.src=URL.createObjectURL(f); im.alt=f.name; d.appendChild(im); }
      else if(f.type.startsWith("video/")){ const v=document.createElement("video"); v.src=URL.createObjectURL(f); v.muted=true; d.appendChild(v); }
      else d.textContent=f.name;
      const x=document.createElement("button"); x.type="button"; x.textContent="×"; x.setAttribute("aria-label","Remove "+f.name);
      x.onclick=()=>{ files.splice(i,1); renderFiles(); }; d.appendChild(x);
      box.appendChild(d);
    });
  }
  function addFiles(list){
    const msg=document.getElementById("fbMsg"); let skipped=[];
    for(const f of list){
      if(!/^(image|video)\//.test(f.type)){ skipped.push(`${f.name} (only images and videos)`); continue; }
      if(f.size>MAX_BYTES){ skipped.push(`${f.name} (over 50 MB)`); continue; }
      if(files.length>=MAX_FILES){ skipped.push(`${f.name} (5 files max)`); continue; }
      files.push(f.name?f:new File([f],`pasted-${Date.now()}.png`,{type:f.type}));
    }
    renderFiles();
    msg.className="fbmsg"+(skipped.length?" err":""); msg.textContent=skipped.length?"Skipped: "+skipped.join(", "):"";
  }

  function gatherContext(){
    const c={page_title:document.title, path:location.pathname, url:location.href, screen:`${window.innerWidth}x${window.innerHeight}`, browser:navigator.userAgent};
    try{ if(typeof window.ltFeedbackContext==="function") Object.assign(c,window.ltFeedbackContext()||{}); }catch(e){}
    return c;
  }
  function pageId(){ const p=location.pathname.split("/").pop()||"index.html"; return p.replace(/\.html$/,"")||"index"; }

  function open(){
    files=[]; sending=false;
    const dlg=document.createElement("div"); dlg.className="fbdlg"; dlg.id="fbDlg"; dlg.setAttribute("role","dialog"); dlg.setAttribute("aria-modal","true"); dlg.setAttribute("aria-labelledby","fbTitle");
    dlg.innerHTML=`<form class="fbcard" id="fbForm">
      <h3 id="fbTitle">Got an idea or spot a problem?</h3>
      <p class="fbsmall">Tell us what you'd love to have, or what didn't work. Screenshots and short videos help a lot.</p>
      <div class="fbkinds" role="radiogroup" aria-label="Type of feedback">${KINDS.map(([v,l],i)=>`<label><input type="radio" name="fbkind" value="${v}" ${i===0?"checked":""}>${l}</label>`).join("")}</div>
      <label for="fbText" class="fbsmall"><b>What's on your mind?</b></label>
      <textarea id="fbText" maxlength="5000" placeholder="e.g. When I search a ZIP on the map, I'd like it to also show... / The Save button didn't work when I..." required></textarea>
      <div class="fbdrop" id="fbDrop" tabindex="0" role="button" aria-label="Add screenshots or videos">📎 Drop screenshots or videos here, <u>browse</u>, or paste with Ctrl+V<br><span class="fbsmall">Up to 5 files, 50 MB each</span></div>
      <input type="file" id="fbInput" accept="image/*,video/*" multiple hidden>
      <div class="fbfiles" id="fbFiles"></div>
      <p class="fbsmall">We'll include the page you're on and your screen size automatically.</p>
      <div class="fbmsg" id="fbMsg" role="status"></div>
      <div class="fbrow"><a href="feedback.html" class="fbsmall">See my feedback</a><div class="btns"><button type="button" class="b" id="fbCancel">Cancel</button><button type="submit" class="b primary" id="fbSend">Send</button></div></div>
    </form>`;
    document.body.appendChild(dlg);
    const close=()=>{ if(sending) return; dlg.remove(); document.removeEventListener("keydown",onKey,true); document.removeEventListener("paste",onPaste); };
    const onKey=e=>{ if(e.key==="Escape"){ e.stopPropagation(); e.preventDefault(); close(); } };
    const onPaste=e=>{ const items=[...(e.clipboardData?.files||[])]; if(items.length){ e.preventDefault(); addFiles(items); } };
    document.addEventListener("keydown",onKey,true); document.addEventListener("paste",onPaste);
    dlg.addEventListener("click",e=>{ if(e.target===dlg) close(); });
    document.getElementById("fbCancel").onclick=close;
    const drop=document.getElementById("fbDrop"), inp=document.getElementById("fbInput");
    drop.onclick=()=>inp.click(); drop.onkeydown=e=>{ if(e.key==="Enter"||e.key===" "){ e.preventDefault(); inp.click(); } };
    inp.onchange=()=>{ addFiles([...inp.files]); inp.value=""; };
    drop.addEventListener("dragover",e=>{ e.preventDefault(); drop.classList.add("over"); });
    drop.addEventListener("dragleave",()=>drop.classList.remove("over"));
    drop.addEventListener("drop",e=>{ e.preventDefault(); drop.classList.remove("over"); addFiles([...e.dataTransfer.files]); });
    document.getElementById("fbForm").addEventListener("submit",async e=>{
      e.preventDefault(); if(sending) return;
      const sb=client(), msg=document.getElementById("fbMsg"), send=document.getElementById("fbSend");
      const text=document.getElementById("fbText").value.trim(), kind=dlg.querySelector("input[name=fbkind]:checked").value;
      if(!text){ msg.className="fbmsg err"; msg.textContent="Please write a few words first."; return; }
      sending=true; send.disabled=true; msg.className="fbmsg";
      try{
        const {data:{user}}=await sb.auth.getUser(); if(!user) throw new Error("Please sign in again.");
        const atts=[];
        for(let i=0;i<files.length;i++){
          const f=files[i]; msg.textContent=`Uploading ${i+1} of ${files.length}: ${f.name}…`;
          const safe=f.name.replace(/[^\w.\-]+/g,"_").slice(-80)||"file";
          const path=`${user.id}/${Date.now()}-${Math.random().toString(36).slice(2,8)}-${safe}`;
          const {error}=await sb.storage.from("feedback").upload(path,f,{contentType:f.type,upsert:false});
          if(error) throw new Error(`Couldn't upload ${f.name}: ${error.message}`);
          atts.push({path,name:f.name,type:f.type,size:f.size});
        }
        msg.textContent="Sending…";
        const {error}=await sb.rpc("submit_feedback",{p_kind:kind,p_message:text,p_page:pageId(),p_context:gatherContext(),p_attachments:atts});
        if(error) throw new Error(/submit_feedback|function/i.test(error.message)&&!/active/i.test(error.message)?"Feedback isn't switched on yet (run supabase/05-feedback.sql).":error.message);
        sending=false;
        try{ window.dispatchEvent(new CustomEvent("lt-feedback-sent")); }catch(e){}
        dlg.querySelector(".fbcard").innerHTML=`<h3>Thanks, we got it! 🙌</h3><p>Your ${kind==="bug"?"report":"idea"} is in. You can check its status any time under <a href="feedback.html">My feedback</a>.</p><div class="fbrow" style="justify-content:flex-end"><button type="button" class="b primary" id="fbDone">Close</button></div>`;
        document.getElementById("fbDone").onclick=close; document.getElementById("fbDone").focus();
      }catch(err){ sending=false; send.disabled=false; msg.className="fbmsg err"; msg.textContent=err.message||String(err); }
    });
    document.getElementById("fbText").focus();
  }

  // Show the button once we know someone is signed in (and hide it after sign-out).
  async function refresh(){
    const sb=client(); if(!sb) return;
    let session=null; try{ ({data:{session}}=await sb.auth.getSession()); }catch(e){}
    const b=document.getElementById("fbOpen");
    if(session&&!b) addButton(); else if(!session&&b) b.remove();
  }
  function start(){
    addStyles();
    let tries=0; const wait=setInterval(()=>{ tries++;
      const sb=client(); if(sb||tries>50){ clearInterval(wait); if(!sb) return; refresh(); try{ sb.auth.onAuthStateChange(()=>setTimeout(refresh,0)); }catch(e){} }
    },100);
  }
  window.ltFeedbackRefresh=refresh;
  if(document.readyState==="loading") document.addEventListener("DOMContentLoaded",start); else start();
})();

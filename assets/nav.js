// Liquid Trucking Operations Center: the site map, the shared header/footer and the "who can see what" rules.
// Every page loads this file right after <div id="ltTop"> so the header is drawn before the page shows.
//
// ADDING A PAGE: add it under LT_SITE.pages (id = its row in Supabase public.site_pages), list its id in its
// department's pages, and give the HTML file the same header placeholder as the others.
// ADDING A DEPARTMENT: add it to LT_SITE.departments with a folder (e.g. /safety/index.html). It appears on the
// dashboard and in the menu as soon as someone can see one of its pages.
window.LT_SITE = {
  name: "Liquid Trucking Operations Center",
  departments: [
    { id: "recruiting", name: "Recruiting", short: "Recruiting", href: "/recruiting/",
      blurb: "Where we're hiring, driver home time, and the tools for bringing new drivers on.",
      pages: ["hiring-map", "faq"] }
  ],
  pages: {
    "hiring-map": { name: "Hiring Map", href: "/recruiting/hiring-map", dept: "recruiting",
      blurb: "County-by-county hiring areas and how often drivers get home." },
    "faq": { name: "Driver FAQ", href: "/recruiting/faq", dept: "recruiting",
      blurb: "Answers on hiring, pay, benefits and life on the road, with a full change history." },
    // Site-wide page, not in a department. viewOnly: the Admin page offers No access / View only (nobody edits it on the
    // site; Claude adds an entry to data/whats-new.json with every update). privateByDefault: admins only until
    // supabase/11-whats-new.sql adds its row, and that row starts as sign-in with access only. How It Works is the same
    // (supabase/12-how-it-works.sql), but its content is written into how-it-works.html itself.
    "whats-new": { name: "What's New", href: "/whats-new", dept: null, viewOnly: true, privateByDefault: true,
      blurb: "Every new feature and change to the Operations Center, newest first." },
    "how-it-works": { name: "How It Works", href: "/how-it-works", dept: null, viewOnly: true, privateByDefault: true,
      blurb: "How the site is built and run, in plain English. For anyone joining the work on it." }
  }
};

// Who can see what. Before sign-in nothing but the sign-in page. After sign-in a page shows when the account is
// active and is an admin, has view/edit access to that page, or the page is public. Admin = active admins only.
// Feedback and the dashboard = every active user.
window.ltCanSee = function (acct, pages, id) {
  const active = !!acct && acct.active !== false, admin = active && acct.role === "admin";
  if (id === "admin") return admin;
  if (!active) return false;
  if (id === "feedback" || id === "dashboard") return true;
  const acc = acct.pages && acct.pages[id], pg = (pages || []).find(p => p.id === id);
  if (admin || acc === "view" || acc === "edit") return true;
  if (!pages || !pg) return !(LT_SITE.pages[id] || {}).privateByDefault;
  return !!pg.public_view;
};
window.ltDeptPages = function (acct, pages, deptId) {
  const d = LT_SITE.departments.find(x => x.id === deptId);
  return d ? d.pages.filter(id => window.ltCanSee(acct, pages, id)) : [];
};

const ltEsc = s => String(s ?? "").replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

// Header + breadcrumb bar. <div id="ltTop" data-current="hiring-map" data-crumbs="Recruiting|/recruiting/;Hiring Map">
window.ltDrawShell = function () {
  if (!document.getElementById("ltShellCss")) {
  const st = document.createElement("style");
  st.textContent = `.crumbs{display:flex;flex-wrap:wrap;align-items:center;gap:2px 8px;min-width:0}
.crumbs a{color:#fff;text-decoration:none;opacity:.85}.crumbs a:hover{opacity:1;text-decoration:underline}
.crumbs .sep{opacity:.6}
.whobox{display:flex;align-items:center;gap:10px;font-family:var(--body);font-weight:600;text-transform:none;letter-spacing:0;font-size:.9rem}
.whobox .linkbtn{background:none;border:1px solid rgba(255,255,255,.6);color:#fff;padding:2px 10px;border-radius:5px;font-weight:600;font-size:.85rem}
.whobox .linkbtn:hover{background:rgba(255,255,255,.12)}
.subbar-in{display:flex;flex-wrap:wrap;align-items:center;gap:6px 16px}
@media (max-width:600px){.subbar-in{font-size:.9rem!important}}`;
  st.id = "ltShellCss"; document.head.appendChild(st);
  }
  const top = document.getElementById("ltTop");
  if (top) {
    const cur = top.dataset.current || "";
    const crumbs = (top.dataset.crumbs || "").split(";").filter(Boolean).map(c => c.split("|"));
    const link = (href, label, attrs, isCur) => `<a href="${href}" ${attrs}${isCur ? ' aria-current="page"' : ""} hidden>${label}</a>`;
    const depts = LT_SITE.departments.map(d => link(d.href, ltEsc(d.short || d.name), `data-dept="${d.id}"`, cur === d.id || (LT_SITE.pages[cur] || {}).dept === d.id)).join("");
    const trail = [`<a href="/">Operations Center</a>`].concat(crumbs.map(([label, href], i) =>
      href && i < crumbs.length - 1 ? `<a href="${href}">${ltEsc(label)}</a>` : `<span aria-current="page">${ltEsc(label)}</span>`)).join('<span class="sep" aria-hidden="true">›</span>');
    top.outerHTML = `<div class="sitebar"><div class="sitebar-in">
  <a class="brand" href="/" aria-label="Operations Dashboard"><img src="https://liquidtrucking.com/wp-content/uploads/2021/03/LiquidTrucking-Logo-transparent-1.png" alt="Liquid Trucking" height="56"></a>
  <nav class="sitenav" aria-label="Site">
    ${link("/", "Sign in", 'data-page="signin"', cur === "signin")}
    ${link("/dashboard", "Dashboard", 'data-page="dashboard"', cur === "dashboard")}
    ${depts}
    ${link("/whats-new", "What's New", 'data-page="whats-new"', cur === "whats-new")}
    ${link("/admin", "Admin", 'data-page="admin"', cur === "admin")}
    ${link("/feedback", "Feedback", 'data-page="feedback"', cur === "feedback")}
  </nav>
</div></div>
<div class="subbar"><div class="sitebar-in subbar-in">
  <nav class="crumbs" aria-label="Breadcrumb">${trail}</nav>
  <span class="whobox" id="whoBox"></span>
</div></div>`;
  }
  const foot = document.getElementById("ltFoot");
  if (foot) foot.outerHTML = `<footer class="sitefoot"><div class="sitefoot-in">
  <div><b>Liquid Trucking</b> · 108 East Bay Rd, Plattsmouth, NE 68048</div>
  <div>844-GO-TANKS · <a href="/">${LT_SITE.name}</a></div>
</div></footer>`;
};
window.ltDrawShell();

// Show the menu items this account can see, plus the signed-in name and Sign out.
window.ltNav = function (acct, pages) {
  document.querySelectorAll(".sitenav a[data-page]").forEach(a => {
    a.hidden = a.dataset.page === "signin" ? !!acct : !window.ltCanSee(acct, pages, a.dataset.page);
  });
  document.querySelectorAll(".sitenav a[data-dept]").forEach(a => { a.hidden = !window.ltDeptPages(acct, pages, a.dataset.dept).length; });
  const who = document.getElementById("whoBox");
  if (who) {
    who.innerHTML = acct ? `<span>${ltEsc(acct.name || "")}</span><button type="button" class="linkbtn" id="ltSignOut">Sign out</button>` : "";
    const so = document.getElementById("ltSignOut");
    if (so) so.onclick = async () => { if (window.ltViewAs) { await window.ltExitViewAs(); return; } try { await window.ltSb?.auth.signOut(); } catch (e) {} location.href = "/"; };
    if (so && window.ltViewAs) { so.textContent = "Exit View as"; so.title = "Go back to your own account"; }
  }
  ltVaBanner();
};

// Send signed-out visitors to the sign-in page and bring them back here afterwards.
window.ltSignInUrl = function () { return "/?next=" + encodeURIComponent(location.pathname + location.search + location.hash); };

// ---------- View as (admins only, read-only) ----------
// An admin picks "View as" on the Admin page. Every page then loads with that user's level and page access, so the admin
// sees what they see. While viewing as someone, every change is blocked in the browser, a gold banner sits under the
// header with an Exit button, and Supabase (10-view-as.sql) checks the admin's rights and logs each start and end.
// The database still runs as the admin, so this tests what each user is shown, not the database rules themselves.
// Pages call ltApplyViewAs(sb, realAccountRow) right after loading the signed-in account, and use what it returns.
const LT_VA_KEY = "ltViewAs";
window.ltViewAs = null; // { real, target } while viewing as someone
const ltVaRead = () => { try { return JSON.parse(sessionStorage.getItem(LT_VA_KEY) || "null"); } catch (e) { return null; } };
const ltVaClear = () => { try { sessionStorage.removeItem(LT_VA_KEY); } catch (e) {} };
// Reads that are allowed while viewing as someone; every other database function is a change and is blocked.
const LT_VA_READ_RPC = ["can_view", "page_access", "is_admin", "is_owner", "faq_as_of", "faq_can_read", "faq_can_edit", "admin_view_as"];

window.ltApplyViewAs = async function (sb, real) {
  const want = ltVaRead();
  if (!want || !want.email) return real;
  if (!sb || !real || real.role !== "admin" || real.active === false || (want.by && real.email && want.by !== real.email)) { ltVaClear(); return real; }
  const { data, error } = await sb.rpc("admin_view_as", { p_email: want.email, p_action: "check" });
  if (error || !data) { ltVaClear(); console.warn("View as ended", error); return real; }
  window.ltViewAs = { real, target: data };
  ltVaGuard(sb);
  return data;
};

window.ltStartViewAs = async function (sb, real, email) {
  const { data, error } = await sb.rpc("admin_view_as", { p_email: email, p_action: "start" });
  if (error) return /admin_view_as|function/i.test(error.message) && !/admin|yourself|email/i.test(error.message)
    ? "View as isn't switched on yet. Run supabase/10-view-as.sql in Supabase." : error.message;
  try { sessionStorage.setItem(LT_VA_KEY, JSON.stringify({ email: data.email, by: real.email })); } catch (e) { return "Your browser blocked View as (site storage is off)."; }
  location.href = "/dashboard";
  return null;
};

window.ltExitViewAs = async function () {
  const want = ltVaRead(); ltVaClear();
  const sb = window.ltSb;
  if (sb && want?.email) { try { await sb.rpc("admin_view_as", { p_email: want.email, p_action: "stop" }); } catch (e) {} }
  location.href = "/admin";
};

const ltVaMsg = () => `You're viewing as ${window.ltViewAs?.target?.name || "another user"}, which is read-only. Exit View as to make changes.`;
function ltVaToast() {
  const t = document.createElement("div"); t.textContent = ltVaMsg(); t.setAttribute("role", "alert");
  t.style.cssText = "position:fixed;left:50%;bottom:18px;transform:translateX(-50%);background:#b3261e;color:#fff;padding:9px 16px;border-radius:6px;font-size:.9rem;box-shadow:0 4px 14px rgba(16,30,48,.25);z-index:1000;max-width:calc(100% - 32px)";
  document.body.appendChild(t); setTimeout(() => t.remove(), 4500);
}
// A stand-in for a blocked query: any chained call (.eq, .select, ...) returns it again, and awaiting it gives an error.
function ltVaBlocked() {
  const res = { data: null, error: { message: ltVaMsg(), code: "view_as_read_only" }, count: null, status: 403, statusText: "Read-only" };
  ltVaToast();
  const p = new Proxy(function () {}, {
    get: (_t, k) => k === "then" ? (ok, bad) => Promise.resolve(res).then(ok, bad) : k === "catch" || k === "finally" ? f => Promise.resolve(res)[k](f) : () => p,
    apply: () => p
  });
  return p;
}
function ltVaGuard(sb) {
  if (sb.__ltVaGuard) return; sb.__ltVaGuard = true;
  const rpc = sb.rpc.bind(sb), from = sb.from.bind(sb);
  sb.rpc = (fn, ...rest) => LT_VA_READ_RPC.includes(fn) ? rpc(fn, ...rest) : ltVaBlocked();
  sb.from = (t) => { const q = from(t); for (const m of ["insert", "update", "upsert", "delete"]) q[m] = () => ltVaBlocked(); return q; };
  const proto = Object.getPrototypeOf(sb), desc = Object.getOwnPropertyDescriptor(proto, "storage");
  const getStorage = desc && desc.get ? () => desc.get.call(sb) : (() => { const s = sb.storage; return () => s; })();
  Object.defineProperty(sb, "storage", { configurable: true, get() {
    const st = getStorage(), sfrom = st.from.bind(st);
    return new Proxy(st, { get: (o, k) => k !== "from" ? (typeof o[k] === "function" ? o[k].bind(o) : o[k]) : (b) => {
      const api = sfrom(b);
      for (const m of ["upload", "update", "remove", "move", "copy", "uploadToSignedUrl", "createSignedUploadUrl"]) api[m] = () => ltVaBlocked();
      return api;
    } });
  } });
}

// The gold banner, drawn by ltNav while viewing as someone.
function ltVaBanner() {
  const va = window.ltViewAs; let bar = document.getElementById("ltViewAsBar");
  if (!va) { if (bar) bar.remove(); return; }
  if (!bar) {
    bar = document.createElement("div"); bar.id = "ltViewAsBar"; bar.setAttribute("role", "status");
    bar.style.cssText = "background:var(--brand-gold,#ecc01c);color:#1b2633;font-size:.92rem;position:sticky;top:0;z-index:50;box-shadow:0 2px 6px rgba(16,30,48,.18)";
    const sub = document.querySelector(".subbar"); if (sub) sub.after(bar); else document.body.prepend(bar);
  }
  const t = va.target, lvl = t.role === "admin" ? "Admin" : "User", off = t.active === false ? " · inactive account" : "";
  bar.innerHTML = `<div class="sitebar-in" style="display:flex;flex-wrap:wrap;align-items:center;justify-content:space-between;gap:6px 14px;padding-block:7px">
  <span><b>Viewing as ${ltEsc(t.name)}</b> <span style="opacity:.8">(${ltEsc(t.email)} · ${lvl}${off})</span> · read-only. You're seeing what they see; changes are turned off.</span>
  <button type="button" id="ltViewAsExit" style="background:#1b2633;color:#fff;border:none;font-weight:700;padding:5px 14px">Exit View as</button></div>`;
  document.getElementById("ltViewAsExit").onclick = () => window.ltExitViewAs();
}

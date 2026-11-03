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
    { id: "recruiting", name: "Recruiting & Onboarding", short: "Recruiting", href: "/recruiting/",
      blurb: "Where we're hiring, driver home time, and the tools for bringing new drivers on.",
      pages: ["hiring-map"] }
  ],
  pages: {
    "hiring-map": { name: "Hiring Map", href: "/recruiting/hiring-map", dept: "recruiting",
      blurb: "County-by-county hiring areas and how often drivers get home." }
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
  return admin || acc === "view" || acc === "edit" || !pages || !pg || !!pg.public_view;
};
window.ltDeptPages = function (acct, pages, deptId) {
  const d = LT_SITE.departments.find(x => x.id === deptId);
  return d ? d.pages.filter(id => window.ltCanSee(acct, pages, id)) : [];
};

const ltEsc = s => String(s ?? "").replace(/[&<>"]/g, c => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

// Header + breadcrumb bar. <div id="ltTop" data-current="hiring-map" data-crumbs="Recruiting & Onboarding|/recruiting/;Hiring Map">
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
    if (so) so.onclick = async () => { try { await window.ltSb?.auth.signOut(); } catch (e) {} location.href = "/"; };
  }
};

// Send signed-out visitors to the sign-in page and bring them back here afterwards.
window.ltSignInUrl = function () { return "/?next=" + encodeURIComponent(location.pathname + location.search + location.hash); };

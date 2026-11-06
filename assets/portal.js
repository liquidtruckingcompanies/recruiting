// Shared sign-in helpers for the sign-in page, the Operations Dashboard and department pages.
// Same Supabase project and public key as every other page, so one sign-in covers the whole site.
const LT_SUPABASE_URL = "https://bunskxkyzmabbhybbubg.supabase.co";
const LT_SUPABASE_KEY = "sb_publishable_YPlmQVx-G_A97WaiTSLFqg_xIyl3PC_";

window.ltClient = function () {
  if (window.ltSb) return window.ltSb;
  if (!window.supabase) return null;
  window.ltSb = window.supabase.createClient(LT_SUPABASE_URL, LT_SUPABASE_KEY,
    { auth: { flowType: "implicit", detectSessionInUrl: true, persistSession: true } });
  return window.ltSb;
};

// -> { email, acct, pages } ; acct = the editors row (null when this email isn't a user yet).
window.ltLoadAccount = async function () {
  const sb = window.ltClient();
  if (!sb) return { email: null, acct: null, pages: null, offline: true };
  let email = null, acct = null, pages = null;
  try { const { data } = await sb.auth.getSession(); email = data.session?.user?.email?.toLowerCase() || null; } catch (e) {}
  if (email) {
    try { const r = await sb.from("editors").select("name,role,active,pages,owner").eq("email", email).maybeSingle(); acct = r.data || null; } catch (e) {}
    try { acct = await window.ltApplyViewAs(sb, acct); } catch (e) {}
    try { const r = await sb.from("site_pages").select("id,name,public_view"); if (!r.error) pages = r.data; } catch (e) {}
  }
  window.ltNav(acct, pages);
  return { email, acct, pages };
};

// Pages that need a signed-in, active account: send everyone else to the sign-in page.
window.ltRequireAccount = async function () {
  const a = await window.ltLoadAccount();
  if (!a.offline && (!a.email || !a.acct || a.acct.active === false)) { location.replace(window.ltSignInUrl()); return null; }
  return a;
};

// A tile: name, one line, arrow.
window.ltTile = (href, name, blurb) =>
  `<a class="tile" href="${href}"><div><h2>${ltEsc(name)}</h2>${blurb ? `<p>${ltEsc(blurb)}</p>` : ""}</div></a>`;

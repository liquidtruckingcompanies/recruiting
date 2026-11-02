// Shared menu rule: before sign-in only Home shows. After sign-in, a page link shows when the account is active and
// is an admin, has view/edit access to that page, or the page is public. The Admin link shows for active admins only.
window.ltCanSee=function(acct,pages,id){
  const active=!!acct&&acct.active!==false, admin=active&&acct.role==="admin";
  if(id==="admin") return admin;
  if(!active) return false;
  const acc=acct.pages&&acct.pages[id], pg=(pages||[]).find(p=>p.id===id);
  return admin||acc==="view"||acc==="edit"||!pages||!pg||!!pg.public_view;
};
window.ltNav=function(acct,pages){
  document.querySelectorAll(".sitenav a[data-page]").forEach(a=>{a.hidden=!window.ltCanSee(acct,pages,a.dataset.page);});
};

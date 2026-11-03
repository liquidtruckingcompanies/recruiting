-- Liquid Trucking recruiting site: email the site owner when new feedback comes in (sent through Resend).
-- Before running: save the Resend API key in Supabase Vault ONCE with this line (your real key in place of re_xxx):
--   select vault.create_secret('re_xxx', 'resend_api_key');
-- Then: SQL Editor -> New query -> paste all of this -> Run. Safe to run again.
-- If the key is missing or Resend is down, feedback still saves; only the email is skipped.

create extension if not exists pg_net;

-- pg_net can cut off request bodies that contain emoji or accented letters, so the email body is kept
-- plain ASCII: anything else becomes an HTML code (&#...;) that email programs display normally.
create or replace function public.ascii_html(t text)
returns text language sql immutable as $$
  select coalesce(string_agg(case when ascii(c) < 128 then c else '&#' || ascii(c) || ';' end, '' order by i), '')
  from unnest(string_to_array(coalesce(t, ''), null)) with ordinality as x(c, i)
$$;

create or replace function public.feedback_notify_owner()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_key   text;
  v_to    text;
  v_kind  text;
  v_page  text;
  v_msg   text;
  v_atts  int;
  v_link  text;
  v_html  text;
begin
  begin
    select decrypted_secret into v_key from vault.decrypted_secrets where name = 'resend_api_key' limit 1;
    select email into v_to from public.editors where owner limit 1;
    if v_key is null or v_to is null then return new; end if;

    v_kind := case new.kind when 'idea' then 'Idea' when 'bug' then 'Problem' else 'Other' end;
    v_page := case new.page when 'hiring-map' then 'Hiring Map' when 'index' then 'Home' when 'admin' then 'Admin'
                            when 'feedback' then 'Feedback' when '' then '-' else new.page end;
    v_msg  := replace(replace(replace(new.message, '&', '&amp;'), '<', '&lt;'), '>', '&gt;');
    v_atts := jsonb_array_length(coalesce(new.attachments, '[]'::jsonb));
    v_link := 'https://recruiting.liquidtrucking.io/feedback.html#id=' || new.id;

    v_html := '<div style="font-family:Arial,sans-serif;max-width:560px;color:#1d2b3a">'
      || '<h2 style="color:#105486;margin:0 0 4px">New feedback #' || new.id || '</h2>'
      || '<p style="margin:0 0 14px;color:#5a6b7d">' || v_kind || ' from <b>'
      || replace(replace(new.submitted_name, '<', '&lt;'), '>', '&gt;') || '</b> (' || new.submitted_email || ') on ' || v_page || '</p>'
      || '<div style="white-space:pre-wrap;background:#f3f6f9;border-left:4px solid #ecc01c;padding:12px 14px;margin:0 0 14px">' || v_msg || '</div>'
      || case when v_atts > 0 then '<p style="margin:0 0 14px">' || v_atts || ' attachment' || case when v_atts > 1 then 's' else '' end || ' (view them in the Feedback Center)</p>' else '' end
      || '<p><a href="' || v_link || '" style="background:#105486;color:#fff;text-decoration:none;padding:10px 18px;border-radius:6px;display:inline-block">Open in Feedback Center</a></p>'
      || '<p style="color:#8a97a6;font-size:12px">Reply to this email to answer ' || replace(replace(new.submitted_name, '<', '&lt;'), '>', '&gt;') || ' directly.</p></div>';

    perform net.http_post(
      url     := 'https://api.resend.com/emails',
      headers := jsonb_build_object('Authorization', 'Bearer ' || v_key, 'Content-Type', 'application/json'),
      body    := jsonb_build_object(
        'from',     'Liquid Trucking Recruiting <no-reply@liquidtrucking.io>',
        'to',       jsonb_build_array(v_to),
        'reply_to', new.submitted_email,
        'subject',  regexp_replace('New feedback #' || new.id || ': ' || v_kind || ' from ' || new.submitted_name, '[^ -~]', '', 'g'),
        'html',     public.ascii_html(v_html))
    );
  exception when others then
    raise warning 'feedback email skipped: %', sqlerrm;
  end;
  return new;
end $$;

revoke all on function public.feedback_notify_owner() from public, anon, authenticated;
revoke all on function public.ascii_html(text) from public, anon, authenticated;

drop trigger if exists feedback_notify_owner on public.feedback;
create trigger feedback_notify_owner after insert on public.feedback
  for each row execute function public.feedback_notify_owner();

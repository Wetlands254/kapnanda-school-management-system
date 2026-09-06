import { withSupabase } from "npm:@supabase/server";
import { createClient } from "npm:@supabase/supabase-js@2";

function randomString(n=12){const chars="ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";let s="";for(let i=0;i<n;i++)s+=chars[Math.floor(Math.random()*chars.length)];return s}

Deno.serve(withSupabase({ auth: "user" }, async (_req, ctx) => {
  if (ctx.userClaims?.role && ctx.userClaims.role !== 'authenticated') return Response.json({error:'Unauthorized'},{status:403});
  const {data: me, error: meErr}=await ctx.supabase.from('profiles').select('role,school_id').eq('id',ctx.userClaims?.sub).single();
  if(meErr || me?.role !== 'admin') return Response.json({error:'Administrator access required.'},{status:403});
  const body=await _req.json();
  const full_name=String(body.full_name||'Staff User').trim();
  const role=['admin','staff','teacher'].includes(body.role)?body.role:'staff';
  const email=`staff.${Date.now()}.${Math.floor(Math.random()*1000)}@kapnanda.local`;
  const password=randomString(14)+'!9';
  const admin=createClient(Deno.env.get('SUPABASE_URL')!,Deno.env.get('SUPABASE_SECRET_KEY')!);
  const {data:userData,error:userErr}=await admin.auth.admin.createUser({email,password,email_confirm:true,user_metadata:{full_name,role}});
  if(userErr)return Response.json({error:userErr.message},{status:400});
  const {error:pErr}=await admin.from('profiles').insert({id:userData.user.id,school_id:me.school_id,email,full_name,role});
  if(pErr){await admin.auth.admin.deleteUser(userData.user.id);return Response.json({error:pErr.message},{status:400})}
  return Response.json({email,password,full_name,role});
}));

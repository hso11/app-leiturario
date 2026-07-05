-- Configuração de acesso das tabelas de sincronização do Leiturário.
--
-- Sintoma sem este script: pull/push falham com
--   42501 "permission denied for table books"
-- porque as tabelas foram criadas sem GRANT para o role `authenticated`
-- e sem políticas de RLS.
--
-- Rode este script no Supabase Dashboard > SQL Editor.
-- É idempotente: pode rodar mais de uma vez sem efeito colateral.

-- 1) Privilégios de tabela para usuários logados (role `authenticated`).
grant select, insert, update, delete on public.books to authenticated;
grant select, insert, update, delete on public.notes to authenticated;

-- 2) Row Level Security: garante que cada usuário só enxergue os próprios dados.
alter table public.books enable row level security;
alter table public.notes enable row level security;

-- 3) Políticas: o usuário só acessa linhas onde user_id == seu id.
--    O cast para text torna a política tolerante a user_id uuid OU text.
drop policy if exists "Users manage own books" on public.books;
create policy "Users manage own books"
  on public.books
  for all
  to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

drop policy if exists "Users manage own notes" on public.notes;
create policy "Users manage own notes"
  on public.notes
  for all
  to authenticated
  using ((select auth.uid())::text = user_id::text)
  with check ((select auth.uid())::text = user_id::text);

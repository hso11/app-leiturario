# Segurança de Dados (Data Safety) — Leiturário

Rascunho das respostas do formulário **Política → Segurança dos dados** da Play
Console. Baseado no código atual (auditado): login opcional via Supabase, sync de
conteúdo, OCR **local**, compras via **Google Play Billing** (sem RevenueCat),
**sem SDKs de analytics/crashlytics**.

Princípio-chave do formulário: só se declara como **"coletado"** o dado que sai
do aparelho (é transmitido/armazenado fora dele). Dado que só é processado
localmente **não** é declarado.

---

## Visão geral (as 3 primeiras perguntas)

| Pergunta | Resposta |
|---|---|
| O app coleta ou compartilha algum dos tipos de dados exigidos? | **Sim** (apenas se o usuário criar conta e sincronizar; offline não coleta nada) |
| Todos os dados coletados são criptografados em trânsito? | **Sim** (HTTPS/TLS via Supabase) |
| Você oferece uma forma de o usuário solicitar a exclusão dos dados? | **Sim** (por e-mail; ver seção Exclusão) |

> **"Compartilhar" com terceiros = Não.** O Supabase armazena os dados **por sua
> conta** (provedor de serviço/processador), o que o Google classifica como
> *coleta*, não como *compartilhamento*. Não há transferência de dados para
> terceiros para fins próprios deles.

---

## Tipos de dados COLETADOS (declarar)

Para **cada** item abaixo, no formulário marque:
Coletado = **Sim** · Compartilhado = **Não** · Processado efêmero = **Não** ·
Obrigatório ou opcional = **Opcional** (o app funciona 100% offline sem conta).

### 1. Informações pessoais → **Endereço de e-mail**
- **Finalidades:** Gerenciamento da conta; Funcionalidade do app.
- Por quê: autenticar o login (Google ou e-mail/senha) e identificar a conta.

### 2. Informações pessoais → **IDs do usuário**
- **Finalidades:** Gerenciamento da conta; Funcionalidade do app.
- Por quê: o Supabase gera um ID de usuário para vincular o conteúdo sincronizado.

### 3. Atividade no app → **Outro conteúdo gerado pelo usuário**
- **Finalidades:** Funcionalidade do app.
- Por quê: livros, progresso de leitura, metas, avaliações, anotações e listas —
  enviados à nuvem **apenas quando o usuário aciona a sincronização**.

> Todos os três: **Opcional** (só ocorre com conta) e **criptografados em trânsito**.

---

## Tipos de dados NÃO coletados (marcar como não, com justificativa)

| Categoria | Por que NÃO declarar |
|---|---|
| **Fotos e vídeos** | A câmera é usada só para **OCR local**; a imagem vira texto no aparelho e **não é enviada**. Capas de livro são **URLs** (Google Books), não fotos do usuário. |
| **Áudio** | Permissão `RECORD_AUDIO` foi **removida**; app não grava áudio. |
| **Localização / Contatos / Agenda** | Não acessados. |
| **Informações financeiras / Histórico de compras** | A compra premium é processada pelo **Google Play Billing**; o app **não** coleta nem armazena dados de pagamento (guarda só um flag local "premium"). |
| **Mensagens / Navegação web / Arquivos** | Não acessados. |
| **IDs de dispositivo** | Sem analytics/publicidade; não coletados. |
| **Logs de falha / Diagnóstico** | Sem Crashlytics/Sentry/Analytics no projeto. |

---

## Práticas de segurança

- **Criptografia em trânsito:** Sim — tráfego com o Supabase é HTTPS/TLS.
- **Exclusão de dados:** o usuário pode sair da conta e parar a sync a qualquer
  momento, e **solicitar a exclusão da conta e dos dados sincronizados** por
  e-mail: **heliosales@gmail.com** (consta na política de privacidade).
- **Coleta opcional:** Sim — o app é totalmente utilizável offline, sem conta.

---

## ⚠️ Pontos para você confirmar antes de enviar

1. **Nome do usuário:** o login Google retorna o nome, mas o código sincroniza
   apenas **e-mail** (a política também só cita e-mail). Se você **não** armazena
   o nome no Supabase, **não** declare "Nome". Se em algum momento passar a
   salvar/exibir o nome de forma persistente, aí inclua "Informações pessoais →
   Nome".
2. **Exclusão de conta (exigência do Google):** apps com criação de conta
   precisam oferecer exclusão. Hoje é **por e-mail** — atende, mas o Google
   valoriza uma **URL/formulário de solicitação de exclusão**. Considere criar
   uma página simples (pode ser no mesmo GitHub Pages da política) com um
   e-mail/form de exclusão e informar essa URL na seção de exclusão de conta.
3. Se um dia adicionar analytics, anúncios ou RevenueCat, este formulário muda
   (passaria a declarar IDs de dispositivo / histórico de compras / etc.).

# Passo a passo — Play Console (Leiturário)

Ordem prática, do começo ao "enviar para revisão". Cada bloco diz **onde** clicar
e **de onde tirar o conteúdo** (os rascunhos já prontos na pasta `docs/`).

- **App / package:** `com.helio.controleleitura`
- **Arquivo a enviar:** `build/app/outputs/bundle/release/app-release.aab` ✅ já gerado
- **Produto premium:** `com.leiturario.premium` (não consumível / compra única)

---

## Fase 0 — Pré-requisitos (fazer PRIMEIRO, alguns demoram dias)

1. **Conta Play Developer** — https://play.google.com/console
   - Login com `heliosales@gmail.com` → pagar **US$ 25** (taxa única).
   - Escolher tipo (Pessoal) → **verificação de identidade** (documento).
   - ⏳ *Pode levar alguns dias.* Comece por aqui.
2. **Perfil de pagamentos** (Configurações → Perfil de pagamentos) — necessário
   para receber pela compra premium.
3. **Política de privacidade no ar** — URL pública
   (em finalização via GitHub Pages: `https://hso11.github.io/leiturario-privacy/`).

---

## Fase 1 — Criar o app

**Todos os apps → Criar app**
- Nome: **Leiturário**
- Idioma padrão: **Português (Brasil)**
- Tipo: **App** · **Gratuito**
- Aceitar as declarações → **Criar**.

---

## Fase 2 — Configuração do app (menu "Configurar" / painel principal)

Preencher as seções obrigatórias até ficarem verdes. Ordem sugerida:

### 2.1 Acesso ao app
- Se não há login restrito por trás de credenciais especiais: **"Todas as
  funcionalidades disponíveis sem restrições"**. (O login é opcional e o app roda
  offline; se o revisor precisar testar sync, forneça um login de teste.)

### 2.2 Anúncios
- **Não contém anúncios.**

### 2.3 Classificação de conteúdo (IARC)
- Responder o questionário → conteúdo em **`classificacao-publico-playstore.md`**.
- Resultado esperado: **Livre / Everyone**.

### 2.4 Público-alvo e conteúdo
- Faixas **13–15, 16–17, 18+** (não marcar abaixo de 13).
- Não atrai crianças. → detalhes em **`classificacao-publico-playstore.md`**.

### 2.5 Segurança dos dados (Data Safety)
- Preencher conforme **`data-safety-playstore.md`**:
  coleta e-mail + ID do usuário + conteúdo gerado (opcionais, criptografados,
  não compartilhados). Confirmar os 2 "pontos a confirmar" do rascunho.

### 2.6 App de notícias / COVID / governo
- Responder **Não** a todos.

### 2.7 Política de privacidade
- Colar a URL pública (GitHub Pages).

---

## Fase 3 — Monetização (produto premium)

**Monetização → Produtos → Produtos no app → Criar produto**
- **ID do produto:** `com.leiturario.premium` (idêntico ao do código em
  `lib/core/constants/subscription_constants.dart`).
- Tipo: **não consumível**.
- Nome, descrição e **preço** → **Ativar** o produto.
- Para testar a compra: **Configuração → Testes de licença** → adicionar seu
  e-mail como testador de licença.

---

## Fase 4 — Ficha principal da loja

**Crescer → Presença na loja → Ficha principal da loja** — conteúdo em
**`ficha-loja-playstore.md`**:
- Nome, **descrição curta** (80), **descrição completa** (4000).
- **Ícone** 512×512 PNG.
- **Gráfico de destaque** 1024×500.
- **Screenshots** de celular (2–8) — roteiro no mesmo arquivo.

---

## Fase 5 — Assinatura e primeiro envio (teste interno)

### 5.1 Play App Signing
- No primeiro upload do `.aab`, o Google ativa o **Play App Signing**
  automaticamente (sua keystore vira **chave de upload**).

### 5.2 Teste interno
**Testes → Teste interno → Criar versão**
- Enviar `app-release.aab`.
- Adicionar seu e-mail na **lista de testadores**.
- Escrever as **notas da versão** (em `ficha-loja-playstore.md`).
- Publicar na faixa interna e instalar pelo link de testador.

### 5.3 Pegar o SHA-1 do Play App Signing (IMPORTANTE p/ login Google)
- **Configuração → Integridade do app → Assinatura do app** → copiar
  **SHA-1 e SHA-256** da *chave de assinatura do app* gerada pelo Google.
- Adicionar esse SHA-1 no **Firebase** (projeto `app-controle-leitura`, app
  Android `com.helio.controleleitura`). O SHA da keystore de upload já temos:
  `C5:EE:A2:31:EB:1E:4F:8A:CC:F7:5B:42:43:BA:13:27:6E:6F:C3:FB`.

### 5.4 Validar no teste interno
- Login (Google **e** e-mail/senha), sync push/pull, e a **compra do premium**
  (com testador de licença). Corrigir o que aparecer; se precisar de novo build,
  **incremente o versionCode** (`pubspec.yaml`, ex.: `1.0.1+2`) e gere novo `.aab`.

---

## Fase 6 — Produção

**Produção → Criar nova versão**
- Enviar o `.aab` validado.
- Notas da versão.
- Conferir que **todas as seções obrigatórias estão verdes**.
- **Enviar para revisão.** (Revisão do Google: de horas a alguns dias.)

---

## Ordem-resumo (caminho crítico)
1. Conta Developer + verificação (⏳ dias) — **já**
2. Pages no ar (URL da política)
3. OAuth Google publicado + credencial Web no Supabase (fora da Console)
4. Criar app → preencher Fases 2, 3, 4
5. Teste interno (Fase 5) → pegar SHA do Play App Signing → Firebase
6. Validar login + compra → Produção (Fase 6)

> Rascunhos de apoio nesta pasta: `ficha-loja-playstore.md`,
> `data-safety-playstore.md`, `classificacao-publico-playstore.md`, e o guia
> técnico completo em `../GUIA_PUBLICACAO_PLAYSTORE.md`.

# Guia de Publicação na Google Play Store — Leiturário

Documento com **tudo o que falta** para publicar o app e o **passo a passo** de
configuração das contas do Google (Cloud / Firebase / OAuth) e da Google Play
Console.

- **App:** Leiturário
- **Package / applicationId:** `com.helio.controleleitura`
- **Versão atual:** `1.0.0+1` (versionName `1.0.0`, versionCode `1`)
- **Backend:** Supabase (projeto `liusarieisbuslzbftet`) — login Google + e‑mail/senha
- **Firebase / google-services.json:** projeto `app-controle-leitura`
- **Compra premium (IAP):** produto **gerenciado / não consumível** `com.leiturario.premium` (compra única, **não** é assinatura)

---

## 1. Status — o que já está pronto e o que falta

| Item | Status | Observação |
|------|--------|-----------|
| applicationId único (`com.helio.controleleitura`) | ✅ Pronto | Não é mais `com.example` |
| Nome do app (`Leiturário`) | ✅ Pronto | `android:label` no Manifest |
| Ícone do app | ✅ Pronto | `flutter_launcher_icons` a partir de `assets/icon/icon.png` |
| `targetSdk` 35 / `minSdk` 21 | ✅ Pronto | Atende a exigência atual da Play (API 35) |
| Minify + shrink + ProGuard | ✅ Pronto | `isMinifyEnabled`/`isShrinkResources` ativos |
| `google-services.json` | ✅ Presente | Package confere |
| Texto da política de privacidade | ✅ Escrito | Em `docs/privacy-policy.md` — **falta hospedar** |
| **Keystore de release + `android/key.properties`** | ❌ **BLOQUEADOR** | Sem isso o build sai assinado em **debug** e é **rejeitado** |
| Permissão `SCHEDULE_EXACT_ALARM` removida | ✅ Feito | Removida via `tools:node="remove"` (código usa alarme inexato); confirmado ausente no app instalado |
| Ícone adaptativo (Android 8+) | ✅ Feito | Gerado por `flutter_launcher_icons` (fundo `#5C6BC0` + frente com inset) |
| Splash nativo (`flutter_native_splash`) | ✅ Feito | Branco no claro / `#1E2A3A` no escuro |
| Hospedar a política de privacidade (URL pública) | ❌ Falta | Necessária na Play Console |
| Conta Google Play Developer | ❌ Falta | US$ 25 (taxa única) + verificação de identidade |
| Produto IAP `com.leiturario.premium` na Play Console | ❌ Falta | Criar como **produto no app (não consumível)** |
| OAuth do Google configurado para release | ⚠️ Verificar | SHA‑1 da chave de assinatura da Play precisa estar no Firebase/Supabase |
| Provedor de e‑mail/senha no Supabase + SMTP | ⚠️ Verificar | Habilitar e, para produção, configurar SMTP próprio |
| Ficha da loja (prints, descrição, gráfico) | ❌ Falta | Textos e imagens da listagem |
| Formulário de Segurança de Dados | ❌ Falta | Declarar dados coletados |
| Classificação de conteúdo (IARC) | ❌ Falta | Questionário na console |
| Permissão `RECORD_AUDIO` (plugin `camera`) | ✅ Feito | Removida via `tools:node="remove"`; confirmado ausente no APK gerado |

> **Resumo:** o único bloqueador de código que resta é **gerar a keystore de
> release + `key.properties`** (precisa das suas senhas — passo manual). As
> correções de alarme exato, ícone adaptativo e splash **já foram aplicadas**. O
> restante é configuração de conta/console (abaixo).

---

## 2. Correções de código antes do build

### 2.1 Remover `SCHEDULE_EXACT_ALARM` — ✅ APLICADO
O app agenda lembretes com `AndroidScheduleMode.inexactAllowWhileIdle`, então
**não precisa** de alarme exato. Já removemos `SCHEDULE_EXACT_ALARM` e
`USE_EXACT_ALARM` no `AndroidManifest.xml` via `tools:node="remove"` (neutraliza
o que o `flutter_local_notifications` injeta). Confirmado ausente no app
instalado, evitando o formulário/política de "alarmes exatos" da Play.

### 2.2 Ícone adaptativo e splash nativo — ✅ APLICADO
- Ícone adaptativo gerado por `flutter_launcher_icons` (`adaptive_icon_background:
  "#5C6BC0"` + `adaptive_icon_foreground: assets/icon/icon.png`).
- Splash nativo configurado com `flutter_native_splash` (branco no tema claro,
  `#1E2A3A` no escuro). Os artefatos já foram gerados.
- Para regenerar após trocar a arte:
  `dart run flutter_launcher_icons` e `dart run flutter_native_splash:create`.

### 2.3 Remover `RECORD_AUDIO` do plugin de câmera — ✅ APLICADO
O plugin `camera` declara `RECORD_AUDIO` (microfone) por padrão, mas o app só
captura **foto** (OCR). Já removemos via `tools:node="remove"` no
`AndroidManifest.xml`. Confirmado ausente no APK gerado (`aapt dump permissions`),
então **não é preciso** declarar uso de microfone na Segurança de Dados.

---

## 3. Gerar a keystore de release e o build assinado (BLOQUEADOR)

> A keystore é a sua identidade de assinatura. **Guarde-a e às senhas em local
> seguro** — perdê-la impede futuras atualizações do app. Não versione no git
> (já está no `.gitignore`).

### 3.1 Gerar a keystore (uma única vez)
No diretório `android/app` (onde o `key.properties.example` aponta com
`storeFile=../leiturario-release.jks`, ou seja, a keystore fica em `android/`):

```bash
keytool -genkey -v -keystore leiturario-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias leiturario
```
Responda os dados (nome, organização, etc.) e **anote as senhas**.

> No Windows, o `keytool` vem com o JDK 21 deste projeto:
> `"C:\Program Files\Java\jdk-21.0.9\bin\keytool.exe"`.

### 3.2 Criar `android/key.properties`
Copie `android/key.properties.example` para `android/key.properties` e preencha:
```properties
storeFile=../leiturario-release.jks
storePassword=SUA_SENHA_DA_KEYSTORE
keyAlias=leiturario
keyPassword=SUA_SENHA_DA_CHAVE
```
Com esse arquivo presente, o `build.gradle.kts` passa a assinar o release com a
sua chave automaticamente.

### 3.3 Pegar o SHA‑1 / SHA‑256 da keystore (necessário p/ login Google)
```bash
keytool -list -v -keystore leiturario-release.jks -alias leiturario
```
Guarde os valores **SHA‑1** e **SHA‑256** (serão usados no Firebase e/ou Google
Cloud, ver Parte 5).

### 3.4 Gerar o App Bundle (formato exigido pela Play)
Na raiz do projeto, com `JAVA_HOME` no JDK 21:
```bash
# Windows (cmd):
set "JAVA_HOME=C:\Program Files\Java\jdk-21.0.9" && set ANDROID_HOME=C:\android-sdk && flutter build appbundle --release
```
Saída: `build/app/outputs/bundle/release/app-release.aab`.

---

## 4. Parte A — Criar e configurar a conta da Google Play

### 4.1 Conta de desenvolvedor
1. Acesse **https://play.google.com/console** e faça login com a conta Google
   que será a dona do app (ex.: `heliosales@gmail.com`).
2. Pague a **taxa única de US$ 25**.
3. Escolha o tipo de conta (Pessoal ou Organização) e **conclua a verificação
   de identidade** (documento; para Organização, também D‑U‑N‑S). Pode levar
   alguns dias para aprovar.
4. Em **Configurações → Perfil de pagamentos**, crie/associe um perfil de
   pagamentos (necessário para receber pelas compras do `com.leiturario.premium`).

### 4.2 Criar o app na console
1. **Criar app** → nome `Leiturário`, idioma padrão Português (Brasil), tipo
   **App**, **Gratuito** (com compras no app).
2. Aceite as declarações de políticas.

### 4.3 Play App Signing (assinatura gerenciada pelo Google)
- Ao enviar o primeiro `.aab`, o Google ativa o **Play App Signing**: ele guarda
  a chave final de assinatura e usa a sua keystore (3.1) apenas como **chave de
  upload**.
- **Importante:** depois do primeiro envio, anote em
  **Configuração → Integridade do app → Assinatura do app** os **SHA‑1 e SHA‑256
  da chave de assinatura do app** (gerada pelo Google). Esse SHA‑1 é o que vale
  para o login Google em produção (ver Parte 5.3).

---

## 5. Parte B — Configurar a conta Google (Cloud / Firebase / OAuth) para o login

O login Google é feito **via Supabase OAuth**. Para funcionar em produção:

### 5.1 Tela de consentimento OAuth (Google Cloud)
1. Acesse **https://console.cloud.google.com** com o projeto
   **`app-controle-leitura`** (o mesmo do `google-services.json`).
2. **APIs e serviços → Tela de consentimento OAuth**:
   - Tipo **Externo**.
   - Preencha nome do app (`Leiturário`), e‑mail de suporte, logo, domínios.
   - Escopos: `openid`, `email`, `profile`.
   - **Publique** a tela de consentimento (status "Em produção"); enquanto
     estiver em "Teste", só e‑mails cadastrados como testadores conseguem logar.

### 5.2 Credenciais OAuth para o Supabase
1. **APIs e serviços → Credenciais → Criar credenciais → ID do cliente OAuth →
   Aplicativo da Web**.
2. Em **URIs de redirecionamento autorizados**, adicione a URL de callback do
   Supabase:
   `https://liusarieisbuslzbftet.supabase.co/auth/v1/callback`
3. Copie o **Client ID** e o **Client Secret**.
4. No **painel do Supabase → Authentication → Providers → Google**: habilite,
   cole o Client ID e o Secret, salve.

### 5.3 SHA‑1 da assinatura no Firebase (login Google no app instalado)
1. No **Firebase Console → projeto `app-controle-leitura` → Configurações do
   projeto → Seus apps (Android `com.helio.controleleitura`)**.
2. Adicione as impressões digitais **SHA‑1 e SHA‑256**:
   - da sua **keystore de release** (passo 3.3) e
   - da **chave de assinatura do app gerada pelo Play App Signing** (passo 4.3).
3. Baixe o `google-services.json` atualizado e substitua em `android/app/` se
   houver mudança.

### 5.4 Supabase — provedores e URLs
1. **Authentication → URL Configuration → Redirect URLs**: confirme que está
   cadastrada a URL do deep link:
   `com.helio.controleleitura://login-callback/`
2. **Authentication → Providers → Email**: **habilite** (login por e‑mail/senha).
   - Decida sobre **"Confirm email"** (confirmação por e‑mail). Se ligado, o app
     já mostra "Confira seu e‑mail para confirmar a conta".
3. **Para produção, configure SMTP próprio** (Authentication → SMTP Settings).
   O SMTP padrão do Supabase é limitado e não deve ser usado em produção
   (e‑mails de confirmação/reset podem não chegar de forma confiável).

---

## 6. Parte C — Preencher a ficha e as declarações da Play Console

### 6.1 Produto de compra no app
1. **Monetização → Produtos → Produtos no app → Criar produto**.
2. ID do produto: **`com.leiturario.premium`** (tem que ser idêntico ao do
   código, em `lib/core/constants/subscription_constants.dart`).
3. Tipo: **não consumível** (compra única que libera a biblioteca ilimitada).
4. Defina nome, descrição e preço; **ative** o produto.
> Para testar a compra antes de publicar, cadastre testadores de licença em
> **Configuração → Testes de licença** e use uma faixa de teste (interno).

### 6.2 Política de privacidade (hospedar e linkar)
1. Hospede o conteúdo de `docs/privacy-policy.md` numa URL pública. Opções
   simples: **GitHub Pages**, Google Sites, Notion público ou qualquer hospedagem.
2. Em **Política → Política de privacidade**, cole a URL.

### 6.3 Segurança de dados (Data Safety)
Declare os dados que o app coleta/usa:
- **E‑mail** (login Google/Supabase) — autenticação.
- **Conteúdo do usuário** (livros, anotações) — sincronizado no Supabase.
- **Câmera/Fotos** — uso **local** para OCR (imagens não são enviadas ao servidor).
- Indique se há transmissão para terceiros (Supabase como processador), e que o
  usuário pode solicitar exclusão (e‑mail de contato da política).

### 6.4 Permissões sensíveis
- `CAMERA`, `READ_MEDIA_IMAGES`, `POST_NOTIFICATIONS`, `INTERNET`: justificadas
  pelas funcionalidades (OCR, capa, lembretes, sync/busca).
- `SCHEDULE_EXACT_ALARM`: **remover** (passo 2.1). Se por algum motivo for
  mantida, será preciso preencher a declaração de alarmes exatos.

### 6.5 Classificação de conteúdo
- **Política → Classificação do conteúdo**: responda ao questionário IARC
  (app de produtividade/leitura, sem conteúdo sensível) e gere a classificação.

### 6.6 Público‑alvo e demais declarações
- **Público‑alvo e conteúdo**: defina faixa etária (não direcionado a crianças).
- **Anúncios**: declarar que o app **não** exibe anúncios.
- Preencha as seções obrigatórias até ficarem verdes no painel.

### 6.7 Ficha da loja (Store Listing)
- **Nome** (Leiturário), **descrição curta** e **descrição completa** (PT‑BR).
- **Ícone** 512×512 PNG.
- **Gráfico de destaque** 1024×500.
- **Screenshots** de celular (mín. 2; recomendado 4–8). Aproveite as telas
  reais: login, biblioteca "A Ler", detalhe do livro com anotações,
  estatísticas, e o tutorial.

---

## 7. Enviar e publicar

1. **Testes → Teste interno**: crie uma faixa, suba o `app-release.aab`, adicione
   seu e‑mail como testador e valide instalação, login (Google e e‑mail/senha) e
   a compra do premium (com testador de licença).
2. Corrija o que aparecer; suba uma nova versão se preciso (incremente o
   `versionCode` em `pubspec.yaml`, ex.: `1.0.1+2`).
3. **Produção → Criar nova versão**: suba o `.aab`, escreva as notas da versão,
   confirme todas as seções obrigatórias preenchidas e **envie para revisão**.
4. A revisão do Google costuma levar de algumas horas a alguns dias.

---

## 8. Checklist final (marcar antes de enviar para produção)

- [x] `SCHEDULE_EXACT_ALARM` removida do Manifest (passo 2.1) — ✅ feito
- [x] Ícone adaptativo + splash nativo (passo 2.2) — ✅ feito
- [x] `RECORD_AUDIO` removida (passo 2.3) — ✅ feito
- [ ] Keystore de release gerada e guardada com segurança
- [ ] `android/key.properties` criado (não versionado)
- [ ] `flutter build appbundle --release` gera `.aab` assinado (não debug)
- [ ] Conta Play Developer criada, paga e verificada
- [ ] App criado na Play Console + Play App Signing ativo
- [ ] SHA‑1/256 (keystore **e** Play App Signing) adicionados no Firebase
- [ ] Tela de consentimento OAuth publicada + credencial Web no Supabase
- [ ] Supabase: provedor Email habilitado + Redirect URL + SMTP de produção
- [ ] Produto `com.leiturario.premium` (não consumível) criado e ativo
- [ ] Política de privacidade hospedada e URL informada
- [ ] Segurança de dados, Classificação de conteúdo e Público‑alvo preenchidos
- [ ] Ficha da loja completa (descrições, ícone 512, gráfico 1024×500, prints)
- [ ] Testado na faixa interna (login + compra) antes de produção

---

> Dúvidas frequentes:
> - **"Preciso de assinatura ou compra única?"** → É **compra única**
>   (`buyNonConsumable`). Cadastre como **produto no app não consumível**, não
>   como assinatura.
> - **"O login Google vai funcionar direto?"** → Só depois de publicar a tela de
>   consentimento OAuth e adicionar o **SHA‑1 da chave do Play App Signing** no
>   Firebase. Em testes internos, mantenha-se como testador da tela OAuth.

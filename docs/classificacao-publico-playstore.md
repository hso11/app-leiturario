# Classificação de conteúdo (IARC) e Público-alvo — Leiturário

Rascunho para **Política → Classificação de conteúdo** e **Política → Público-alvo
e conteúdo** da Play Console. App de leitura/produtividade, sem conteúdo sensível,
sem anúncios, com uma compra única (premium) via Google Play Billing.

---

## A. Questionário IARC (classificação de conteúdo)

Primeiro o Google pede a **categoria**: escolha **"Referência, notícias ou
educação"** (ou "Utilitário/Produtividade" se aparecer) — **não** é jogo.

Respostas ao questionário (todas honestas conforme o app atual):

| Pergunta (resumo) | Resposta |
|---|---|
| Violência (real, fantasia, sangue) | **Não** |
| Conteúdo sexual / nudez | **Não** |
| Linguagem imprópria / palavrões | **Não** |
| Referência a drogas, álcool ou tabaco | **Não** |
| Jogos de azar (reais ou simulados) | **Não** |
| Medo / horror / conteúdo perturbador | **Não** |
| Discriminação / discurso de ódio | **Não** |
| Os usuários **interagem ou trocam conteúdo entre si** dentro do app | **Não** — anotações são privadas; não há chat/comunidade. O botão "compartilhar" envia para fora do app (folha de compartilhamento do sistema). |
| O app **compartilha a localização** do usuário com outros | **Não** |
| O app permite **comprar itens digitais** | **Sim** — premium (compra única) via Google Play Billing |
| O app tem **navegador de internet irrestrito** embutido | **Não** — abre links externos específicos (lojas), sem navegador aberto |
| Conteúdo gerado por usuário exibido publicamente | **Não** |

**Classificação esperada:** **Livre** (Brasil) / **Everyone / 3+** / PEGI 3.
O IARC gera automaticamente após responder.

---

## B. Público-alvo e conteúdo

### Faixas etárias
Marque **13–15, 16–17 e 18 ou mais**. **Deixe desmarcadas** as faixas abaixo de
13 anos (5 e menos, 6–8, 9–12).

> **Por quê:** incluir qualquer faixa **abaixo de 13** ativa a **Política para
> Famílias** do Google (regras extras, revisão mais rígida). O app não é
> destinado a crianças (a política de privacidade já diz isso), então o mais
> simples e coerente é público **13+**. Se preferir o caminho mais conservador,
> marque **só 18 ou mais** — reduz alcance, mas zera qualquer risco de Famílias.

### A ficha ou o conteúdo do app atraem crianças?
- **Não.** Design e linguagem são voltados a leitores adultos/adolescentes;
  nada de personagens, cores ou temas infantis.

### Anúncios
- O app **exibe anúncios?** **Não.** (declare "sem anúncios")

### Outras declarações comuns
| Pergunta | Resposta |
|---|---|
| É um app de **notícias**? | Não |
| É um app **governamental**? | Não |
| Faz **rastreamento de contato / status COVID-19**? | Não |
| É um app financeiro/carteira? | Não |
| Coleta dados de crianças conscientemente? | Não |

---

## Resumo do que isso resolve
Preenchendo essas duas seções + a de Segurança de Dados (rascunho em
`data-safety-playstore.md`), as declarações de conteúdo/públic-alvo da Console
ficam completas. Restam então: conta paga, assets gráficos, produto IAP, OAuth e
o upload do `.aab`.

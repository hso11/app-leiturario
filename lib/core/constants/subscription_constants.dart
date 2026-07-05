class SubscriptionConstants {
  /// ID do produto cadastrado na Google Play Console.
  /// Formato: com.seuapp.premium (ou qualquer ID que você definir na loja)
  static const productPremium = 'com.leiturario.premium';

  /// Limite do plano gratuito: número máximo de livros na biblioteca
  /// (todos os status: lendo + lidos + a ler). A partir do 11º livro,
  /// é necessário o plano Premium.
  static const freeMaxBooks = 10;
}

class AppStrings {
  // General
  static const appName = 'Leiturário';
  static const cancel = 'Cancelar';
  static const confirm = 'Confirmar';
  static const delete = 'Deletar';
  static const edit = 'Editar';
  static const save = 'Salvar';
  static const close = 'Fechar';
  static const loading = 'Carregando...';
  static const error = 'Erro';
  static const success = 'Sucesso';

  // Tabs
  static const history = 'Lidos';
  static const reading = 'Lendo';
  static const wantToRead = 'A ler';
  static const statistics = 'Estatísticas';

  // Books
  static const newBook = 'Novo Livro';
  static const bookTitle = 'Título do livro';
  static const bookAuthor = 'Autor';
  static const totalPages = 'Total de páginas';
  static const bookAdded = 'Livro adicionado!';
  static const bookDeleted = 'Livro removido';
  static const moveToReading = 'Mover para Lendo';
  static const moveToWantToRead = 'Voltar para A Ler';
  static const markAsRead = 'Marcar como Lido';
  static const startReading = 'Começar a ler';
  static const pagesPerDay = 'págs/dia';
  static const dragToRead = 'Arraste para começar a ler';
  static const reorderHint = 'Segure e arraste para reordenar';

  // Notes
  static const notes = 'Anotações';
  static const newNote = 'Nova Anotação';
  static const noteContent = 'Conteúdo da anotação';
  static const pageRef = 'Página (opcional)';
  static const noteAdded = 'Anotação adicionada!';
  static const noteDeleted = 'Anotação removida';
  static const takePhoto = 'Tirar foto (OCR)';
  static const allBooks = 'Todos os livros';

  // Auth
  static const loginGoogle = 'Entrar com Google';
  static const loginEmail = 'E-mail';
  static const loginPassword = 'Senha';
  static const loginEnter = 'Entrar';
  static const loginCreateAccount = 'Criar conta';
  static const loginHaveAccount = 'Já tenho conta';
  static const loginForgotPassword = 'Esqueci minha senha';
  static const loginOr = 'ou';
  static const loginEmailRequired = 'Informe um e-mail válido';
  static const loginPasswordRequired = 'A senha precisa ter ao menos 6 caracteres';
  static const loginConfirmationSent =
      'Enviamos um e-mail de confirmação. Confirme sua conta para entrar.';
  static const loginResetSent =
      'Se o e-mail existir, enviamos um link para redefinir a senha.';
  static const logout = 'Sair';
  static const syncNow = 'Sincronizar agora';
  static const lastSync = 'Última sync';
  static const syncing = 'Sincronizando...';
  static const syncSuccess = 'Sincronizado!';
  static const syncError = 'Erro ao sincronizar';
  static const loginTitle = 'Bem-vindo ao Leiturário';
  static const loginSubtitle = 'Faça login para sincronizar seus livros na nuvem';
  static const continueOffline = 'Continuar sem login';

  // Theme
  static const darkMode = 'Modo escuro';
  static const lightMode = 'Modo claro';

  // Tutorial / Onboarding
  static const tutorialSkip = 'Pular';
  static const tutorialNext = 'Próximo';
  static const tutorialStart = 'Começar';
  static const tutorialMenuItem = 'Ver tutorial';
  static const tutorialHelpSection = 'Ajuda';

  static const tutorialWelcomeTitle = 'Bem-vindo ao Leiturário';
  static const tutorialWelcomeDesc =
      'Acompanhe sua leitura: cadastre livros, organize sua fila e registre suas anotações. Vamos dar uma volta rápida?';

  static const tutorialAddTitle = 'Cadastre seus livros';
  static const tutorialAddDesc =
      'Toque em "Novo Livro" e busque pelo título — a capa e os dados vêm automaticamente do acervo online.';

  static const tutorialReorderTitle = 'Organize a fila "A Ler"';
  static const tutorialReorderDesc =
      'Segure e arraste para reordenar os livros que quer ler. Arraste para o topo para começar a leitura.';

  static const tutorialNotesTitle = 'Anotações e comentários';
  static const tutorialNotesDesc =
      'Na tela do livro, registre comentários com a página de referência. Pode até fotografar um trecho e extrair o texto (OCR).';

  static const tutorialProgressTitle = 'Progresso e conquistas';
  static const tutorialProgressDesc =
      'Atualize seu progresso, avalie ao terminar e acompanhe suas estatísticas. Faça backup na nuvem quando quiser.';

  // Reading progress & review
  static const currentPage = 'Página atual';
  static const updateProgress = 'Atualizar progresso';
  static const rating = 'Avaliação';
  static const review = 'Resenha';
  static const genre = 'Gênero';
  static const exportNotes = 'Exportar Anotações';

  // Annual goal & streak
  static const annualGoal = 'Meta anual';
  static const setGoal = 'Definir meta';
  static const booksRead = 'livros lidos';
  static const streak = 'dias seguidos';
  static const readingStreak = 'Sequência de leitura';

  // Search & sort
  static const search = 'Buscar livros e anotações...';
  static const sortBy = 'Ordenar por';
  static const sortTitle = 'Título';
  static const sortStartDate = 'Início';
  static const sortEndDate = 'Conclusão';
  static const sortRating = 'Avaliação';

  // Mercado Livre price search
  static const mlPrices = 'Preços no Mercado Livre';
  static const mlSearchButton = 'Buscar no Mercado Livre';
  static const amazonSearchButton = 'Buscar na Amazon';
  static const mlNoResults = 'Nenhum resultado encontrado.';
  static const mlError = 'Erro ao buscar preços. Tente novamente.';
  static const mlRetry = 'Tentar novamente';

  static const List<String> predefinedGenres = [
    'Ficção',
    'Não-ficção',
    'Terror',
    'Romance',
    'Fantasia',
    'Biografia',
    'Autoajuda',
    'Tecnologia',
    'História',
    'Ciência',
  ];
}

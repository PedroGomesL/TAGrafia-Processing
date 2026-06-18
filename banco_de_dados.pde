// 1. Declaração global das tabelas
Table tabelaEscolas;
Table tabelaEventos;
Table tabelaProdIntl;
Table tabelaProdBR;

// Variável para travar o sistema caso algo dê errado
boolean bancoCarregadoComSucesso = false; 

// 2. Função principal para resgatar os dados
void iniciarBancoDeDados() {
  println("--- INICIANDO RESGATE DO BANCO DE DADOS ---");
  
  // Usamos um bloco try-catch para evitar que o programa feche abruptamente se der erro
  try {
    tabelaEscolas  = loadTable("Escolas.tsv", "tsv, header");
    tabelaEventos  = loadTable("Eventos_contexto.tsv", "tsv, header");
    tabelaProdIntl = loadTable("Produtos internacionais.tsv", "tsv, header");
    tabelaProdBR   = loadTable("Produtos brasileiros.tsv", "tsv, header");
    
    // Chama o verificador para validar se as variáveis não estão nulas
    bancoCarregadoComSucesso = validarCarregamento();
    
  } catch (Exception e) {
    println("ERRO CRÍTICO: Falha na leitura dos arquivos. Verifique a pasta 'data'.");
    bancoCarregadoComSucesso = false;
  }
}

// 3. Verificador para validar as informações
boolean validarCarregamento() {
  boolean sucesso = true; // Assumimos que deu certo, até provar o contrário
  
  println("\n--- RESULTADO DA VALIDAÇÃO ---");
  
  if (tabelaEscolas == null) {
    println("[ ERRO ] 'Escola.tsv' não foi encontrado ou está corrompido.");
    sucesso = false;
  } else {
    println("[  OK  ] Escolas resgatadas: " + tabelaEscolas.getRowCount());
  }
  
  if (tabelaEventos == null) {
    println("[ ERRO ] 'Eventos_contextos.tsv' não foi encontrado ou está corrompido.");
    sucesso = false;
  } else {
    println("[  OK  ] Eventos/Contextos resgatados: " + tabelaEventos.getRowCount());
  }
  
  if (tabelaProdIntl == null) {
    println("[ ERRO ] 'Produtos internacionais.tsv' não foi encontrado.");
    sucesso = false;
  } else {
    println("[  OK  ] Produtos Internacionais resgatados: " + tabelaProdIntl.getRowCount());
  }
  
  if (tabelaProdBR == null) {
    println("[ ERRO ] 'produtos brasileiros.tsv' não foi encontrado.");
    sucesso = false;
  } else {
    println("[  OK  ] Produtos Brasileiros resgatados: " + tabelaProdBR.getRowCount());
  }
  
  println("------------------------------\n");
  
  // Feedback final
  if (sucesso) {
    println("STATUS: Banco de dados validado e pronto para uso!");
  } else {
    println("STATUS: A validação falhou. Corrija os arquivos na pasta 'data' antes de continuar.");
  }
  
  return sucesso;
}

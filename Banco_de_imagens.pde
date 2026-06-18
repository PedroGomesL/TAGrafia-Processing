import java.io.File; // Import necessário para vasculhar as pastas

// Criamos dois dicionários (HashMaps) que ligam um número (ID) a uma lista de imagens (ArrayList<PImage>)
HashMap<Integer, ArrayList<PImage>> imagensNacionais;
HashMap<Integer, ArrayList<PImage>> imagensInternacionais;

void iniciarBancoDeImagens() {
  println("\n--- INICIANDO CARREGAMENTO DE IMAGENS ---");
  
  // Inicializa os dicionários vazios
  imagensNacionais = new HashMap<Integer, ArrayList<PImage>>();
  imagensInternacionais = new HashMap<Integer, ArrayList<PImage>>();
  
  // Carrega as duas pastas
  carregarPasta("Banco de imagens nacional", imagensNacionais);
  carregarPasta("Banco de imagens internacional", imagensInternacionais);
  
  println("-----------------------------------------\n");
}

// Função inteligente que vasculha a pasta e organiza as imagens pelo ID
void carregarPasta(String nomePasta, HashMap<Integer, ArrayList<PImage>> mapaImagens) {
  
  // dataPath() encontra o caminho absoluto da pasta "data" não importa o sistema operacional
  File pasta = new File(dataPath(nomePasta));
  
  // Verificador: a pasta existe mesmo?
  if (!pasta.exists() || !pasta.isDirectory()) {
    println("[ ERRO ] A pasta '" + nomePasta + "' não foi encontrada dentro de 'data'.");
    return; // Para a função aqui
  }
  
  File[] arquivos = pasta.listFiles();
  
  if (arquivos == null || arquivos.length == 0) {
    println("[ AVISO ] A pasta '" + nomePasta + "' está vazia.");
    return;
  }
  
  int totalCarregadas = 0;
  
  // Vasculha arquivo por arquivo dentro da pasta
  for (File arquivo : arquivos) {
    String nomeArquivo = arquivo.getName();
    String nomeMin = nomeArquivo.toLowerCase();
    
    // Verifica se é uma imagem
    if (nomeMin.endsWith(".jpg") || nomeMin.endsWith(".png") || nomeMin.endsWith(".avif")) {
      
      // Divide o nome do arquivo usando o "_"
      // Ex: "15_01.jpg" vira um array -> partes[0] = "15", partes[1] = "01.jpg"
      String[] partes = split(nomeArquivo, '_');
      
      if (partes.length >= 2) {
        int idProduto = int(partes[0]); // Pega o 15 e transforma em número
        
        // Tenta carregar a imagem na memória
        PImage img = loadImage(arquivo.getAbsolutePath());
        
        if (img != null) {
          // Se esse ID ainda não existe no dicionário, cria uma lista nova para ele
          if (!mapaImagens.containsKey(idProduto)) {
            mapaImagens.put(idProduto, new ArrayList<PImage>());
          }
          
          // Guarda a imagem na lista desse ID
          mapaImagens.get(idProduto).add(img);
          totalCarregadas++;
        } else {
          println("[ ERRO ] Falha ao processar a imagem (formato não suportado?): " + nomeArquivo);
        }
      }
    }
  }
  
  println("[  OK  ] " + totalCarregadas + " imagens carregadas de '" + nomePasta + "'.");
}

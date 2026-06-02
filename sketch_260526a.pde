// Listas para armazenar os dados na memória
ArrayList<Produto> produtos = new ArrayList<Produto>();
ArrayList<Evento> eventos = new ArrayList<Evento>();
ArrayList<Escola> escolas = new ArrayList<Escola>();
ArrayList<ImagemProduto> bancoImagens = new ArrayList<ImagemProduto>();
int produtoSelecionadoIndex = 0;

void setup() {
  size(1024, 768); // Aumentamos a tela para caber imagem e texto
  
  carregarBancosDeDados(); // Lê os CSVs
  carregarBancoDeImagens(); // Lê a pasta de imagens e já vincula aos produtos automaticamente
    
  println("Sistema pronto! Pressione as setas ESQUERDA/DIREITA para navegar.");
}

void draw() {
  background(240);
  if (produtos.size() > 0) {
    desenharDetalheProduto(produtos.get(produtoSelecionadoIndex));
  } else {
    fill(0);
    text("Nenhum produto carregado. Verifique os CSVs.", 50, 50);
  }
}


// ==========================================
// FUNÇÃO DE CARREGAMENTO (COM DEBUG)
// ==========================================
void carregarBancosDeDados() {
  println("Iniciando leitura de Produtos...");
  Table tabProdutos = loadTable("Produtos.csv", "header, csv");
  if (tabProdutos != null) {
    for (TableRow row : tabProdutos.rows()) {
      produtos.add(new Produto(row));
    }
    println("> Produtos carregados com sucesso!");
  }

  println("Iniciando leitura de Eventos...");
  Table tabEventos = loadTable("Eventos_contexto.csv", "header, csv"); 
  if (tabEventos != null) {
    for (TableRow row : tabEventos.rows()) {
      eventos.add(new Evento(row));
    }
    println("> Eventos carregados com sucesso!");
  }

  println("Iniciando leitura de Escolas...");
  Table tabEscolas = loadTable("Escolas.csv", "header, csv");
  if (tabEscolas != null) {
    for (TableRow row : tabEscolas.rows()) {
      escolas.add(new Escola(row));
    }
    println("> Escolas carregadas com sucesso!");
  }
}

// ==========================================
// CLASSES DE DADOS
// ==========================================
class Produto {
  int id;
  String nome, tipo, material, datacao, localizacao, autoria;
  String condicionantes, numeroExemplares, tecnicaComposicao;
  String materiais, estetico, tecnicasConstrucao;

  ArrayList<PImage> imagensRelacionadas;

  Produto(TableRow row) {
    this.id = row.getInt("ID");
    this.nome = row.getString("Nome");
    this.tipo = row.getString("Tipo");
    this.material = row.getString("Material");
    this.datacao = row.getString("Datação");
    this.localizacao = row.getString("Localização Geográfica");
    this.autoria = row.getString("Autoria");
    this.condicionantes = row.getString("Condicionantes Industriais/Econômicos");
    this.numeroExemplares = row.getString("Número de exemplares");
    this.tecnicaComposicao = row.getString("Técnica de Composição");
    this.materiais = row.getString("Materiais");
    this.estetico = row.getString("Estético");
    this.tecnicasConstrucao = row.getString("Técnicas de construção/Funcionalidades");
    this.imagensRelacionadas = new ArrayList<PImage>();
  }
}

class Evento {
  int id;
  String nome, contexto, duracao, localizacao, atores, instituicoes, descricao;

  Evento(TableRow row) {
    this.id = row.getInt("ID");
    this.nome = row.getString("Nome / Título do Evento");
    this.contexto = row.getString("Contexto");
    this.duracao = row.getString("Duração");
    this.localizacao = row.getString("Localização Geográfica");
    this.atores = row.getString("Atores Históricos Envolvidos");
    this.instituicoes = row.getString("Instituições Promotoras");
    this.descricao = row.getString("Descrição");
  }
}

class Escola {
  int id;
  String escola, contexto, fases, principaisNomes, metodologia, materiaisUsados, principaisObras;

  Escola(TableRow row) {
    this.id = row.getInt("id"); // Nota: na planilha de escolas o id está minúsculo
    this.escola = row.getString("Escola");
    this.contexto = row.getString("Contexto");
    this.fases = row.getString("Fases");
    this.principaisNomes = row.getString("Principais nomes");
    this.metodologia = row.getString("Metodologia de Ensino");
    this.materiaisUsados = row.getString("Materiais usados");
    this.principaisObras = row.getString("Principais obras");
  }
}
class ImagemProduto {
  String idBanco; // Sintaxe: produto_imagem (ex: "10_01")
  int idProduto;
  PImage img;

  ImagemProduto(int idProduto, int indiceImagem, String extensao) {
    this.idProduto = idProduto;
    
    // Formata o índice da imagem para sempre ter dois dígitos (ex: 1 vira "01")
    String indiceFormatado = nf(indiceImagem, 2); 
    
    // Concatena seguindo a sintaxe exigida
    this.idBanco = idProduto + "_" + indiceFormatado;
    
    // Carrega a imagem da pasta 'data' (ex: "10_01.jpg" ou "10_01.png")
    this.img = loadImage(this.idBanco + extensao);
  }
}

// ==========================================
// CONTROLE DE NAVEGAÇÃO (Teclado)
// ==========================================
void keyPressed() {
  if (keyCode == RIGHT) {
    produtoSelecionadoIndex++;
    if (produtoSelecionadoIndex >= produtos.size()) produtoSelecionadoIndex = 0; // Volta pro início
  } else if (keyCode == LEFT) {
    produtoSelecionadoIndex--;
    if (produtoSelecionadoIndex < 0) produtoSelecionadoIndex = produtos.size() - 1; // Vai pro final
  }
}
void vincularImagensAosProdutos() {
  println("Vinculando imagens aos produtos...");
  for (ImagemProduto imgBanco : bancoImagens) {
    for (Produto p : produtos) {
      if (p.id == imgBanco.idProduto) {
        p.imagensRelacionadas.add(imgBanco.img); // Conecta a imagem ao produto!
      }
    }
  }
}
void desenharDetalheProduto(Produto p) {
  fill(30);
  
  // Título e ID
  textSize(28);
  text(p.nome, 50, 60);
  textSize(14);
  fill(100);
  text("ID: " + p.id + " | Ano: " + p.datacao + " | Design: " + p.autoria, 50, 90);
  
  // Renderização da Imagem (Mostra a primeira imagem, se houver)
  if (p.imagensRelacionadas.size() > 0 && p.imagensRelacionadas.get(0) != null) {
    PImage imgPrincipal = p.imagensRelacionadas.get(0);
    // Desenha a imagem redimensionada para caber no layout
    image(imgPrincipal, 50, 120, 400, (400.0/imgPrincipal.width) * imgPrincipal.height);
  } else {
    // Retângulo de marcação (Placeholder) caso não tenha imagem
    fill(200);
    noStroke();
    rect(50, 120, 400, 300);
    fill(100);
    textAlign(CENTER, CENTER);
    text("Imagem Indisponível\nou não vinculada", 250, 270);
    textAlign(LEFT, BASELINE); // Reseta o alinhamento
  }
  
  // Metadados do Produto
  fill(30);
  textSize(16);
  text("Material: " + p.material, 500, 120);
  text("Tipo: " + p.tipo, 500, 150);
  text("Localização: " + p.localizacao, 500, 180);
  
  textSize(14);
  textLeading(20); // Espaçamento entre linhas
  text("Condicionantes:\n" + p.condicionantes, 500, 230, 450, 200); // Caixa de texto limitadora
}

// ==========================================
// FUNÇÃO DE CARREGAMENTO AUTOMÁTICO DE IMAGENS
// ==========================================
void carregarBancoDeImagens() {
  println("Iniciando varredura automática do Banco de Imagens...");
  int totalImagensEncontradas = 0;

  // Itera por todos os produtos que já foram carregados do CSV
  for (Produto p : produtos) {
    int indice = 1;
    boolean buscandoImagens = true;
    
    // Fica em loop tentando achar 01, 02, 03... até o arquivo não existir mais
    while (buscandoImagens) {
      
      // Formata o ID e o Índice para sempre terem 2 dígitos (Ex: id 2 vira "02")
      String idFormatado = nf(p.id, 2);
      String indiceFormatado = nf(indice, 2);
      
      // Monta a sintaxe que você criou: "02_01.jpg"
      String nomeArquivo = idFormatado + "_" + indiceFormatado + ".jpg";
      String caminhoRelativo = "Banco de imagens/" + nomeArquivo;
      
      // Truque essencial: Usa a função nativa File e dataPath para checar se o 
      // arquivo existe ANTES de carregar. Isso evita tela de erro no console!
      File arquivo = new File(dataPath(caminhoRelativo));
      
      if (arquivo.exists()) {
        // Se a imagem existe na pasta, carrega e já guarda direto dentro do Produto
        PImage img = loadImage(caminhoRelativo);
        p.imagensRelacionadas.add(img);
        
        totalImagensEncontradas++;
        indice++; // Tenta procurar a próxima imagem (ex: 02_02.jpg)
      } else {
        // Se o arquivo não existe, acabaram as imagens desse produto. 
        // Quebra o 'while' e passa para o próximo produto.
        buscandoImagens = false; 
      }
    }
  }
  
  println("> Sucesso! Varredura concluída. Total de imagens vinculadas: " + totalImagensEncontradas);
}

// Listas para armazenar os dados na memória
ArrayList<Produto> produtos = new ArrayList<Produto>();
ArrayList<Evento> eventos = new ArrayList<Evento>();
ArrayList<Escola> escolas = new ArrayList<Escola>();
ArrayList<ImagemProduto> bancoImagens = new ArrayList<ImagemProduto>();
int produtoSelecionadoIndex = 0;
boolean menuVisivel = false;
Produto produtoFocado = null;
Slot[] slots = new Slot[8];
ArrayList<Card> cardsAtivos = new ArrayList<Card>();
Card cardArrastado = null;
float arrastoOffsetX, arrastoOffsetY;

void setup() {
  size(1024, 768); // Aumentamos a tela para caber imagem e texto
  
  carregarBancosDeDados(); // Lê os CSVs
  carregarBancoDeImagens(); // Lê a pasta de imagens e já vincula aos produtos automaticamente
  
for (int i = 0; i < 8; i++) {
    slots[i] = new Slot(0, 0, 130, 100); // Requisito 2: Tamanho reduzido
  }
}

void draw() {
  background(240);
if (cardsAtivos.size() == 0 && !menuVisivel) {
    fill(150);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Clique com o botão DIREITO em qualquer lugar para abrir o menu.\nArraste os cards para organizar sua mesa.", width/2, height/2);
    textAlign(LEFT, BASELINE);
  }
  
  // 1. Renderiza os Cards ativos na mesa
  for (Card c : cardsAtivos) {
    c.desenhar();
  }
  
  // 2. Renderiza o Menu de Slots (se estiver aberto)
  if (menuVisivel) {
    // Sombra leve para destacar os slots sobre os cards
    fill(0, 20);
    noStroke();
    rect(0, 0, width, height);
    
    for (int i = 0; i < slots.length; i++) {
      slots[i].desenhar();
    }
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

// ==========================================
// MOTOR DE INTERAÇÃO DO MOUSE
// ==========================================
void mousePressed() {
 if (mouseButton == RIGHT) {
    menuVisivel = !menuVisivel;
    
    if (menuVisivel) {
      // Requisito 1: Posiciona os slots ao redor do clique (50px de distância)
      posicionarSlotsAoRedor(mouseX, mouseY, 50);
      sortearProdutosParaSlots();
    }
  } 
  else if (mouseButton == LEFT) {
    if (menuVisivel) {
      boolean clicouEmSlot = false;
      
      for (int i = 0; i < slots.length; i++) {
        if (slots[i].indexProdutoAtribuido != -1 && slots[i].isMouseOver()) {
          // Requisito 3 e 7: Cria um Card no mesmo lugar e tamanho do Slot
          Produto p = produtos.get(slots[i].indexProdutoAtribuido);
          cardsAtivos.add(new Card(slots[i].x, slots[i].y, slots[i].w, slots[i].h, p));
          
          menuVisivel = false;
          clicouEmSlot = true;
          break;
        }
      }
      
      if (!clicouEmSlot) menuVisivel = false; // Fecha se clicar no vazio
      
    } else {
      // Se o menu está fechado, verifica interação com os Cards na mesa
      // Itera de trás para frente para clicar no card que está no topo
      for (int i = cardsAtivos.size() - 1; i >= 0; i--) {
        Card c = cardsAtivos.get(i);
        
        // Requisito 4: Clicou no botão de deletar (X)?
        if (c.isCloseHovered()) {
          cardsAtivos.remove(i);
          return;
        } 
        // Clicou no corpo do Card para arrastar?
        else if (c.isMouseOver()) {
          cardArrastado = c;
          arrastoOffsetX = mouseX - c.x;
          arrastoOffsetY = mouseY - c.y;
          
          // Traz o card clicado para a frente (topo da lista)
          cardsAtivos.remove(i);
          cardsAtivos.add(c);
          return;
        }
      }
    }
  }
}
void mouseDragged() {
  // Permite organizar a mesa arrastando os cards
  if (cardArrastado != null && !menuVisivel) {
    cardArrastado.x = mouseX - arrastoOffsetX;
    cardArrastado.y = mouseY - arrastoOffsetY;
  }
}
void mouseReleased() {
 ArrayList<Integer> indicesDisponiveis = new ArrayList<Integer>();
  
  for (int i = 0; i < produtos.size(); i++) {
    // Requisito 6: Verifica se a obra já está em formato de Card na mesa
    boolean jaEstaNaMesa = false;
    for (Card c : cardsAtivos) {
      if (c.p.id == produtos.get(i).id) {
        jaEstaNaMesa = true;
        break;
      }
    }
    
    // Se não estiver na mesa, é elegível para aparecer no Slot
    if (!jaEstaNaMesa) {
      indicesDisponiveis.add(i);
    }
  }
  
  // Preenche os 8 slots com as obras disponíveis
  for (int i = 0; i < slots.length; i++) {
    if (indicesDisponiveis.size() > 0) {
      int posicaoSorteada = int(random(indicesDisponiveis.size()));
      slots[i].indexProdutoAtribuido = indicesDisponiveis.get(posicaoSorteada);
      indicesDisponiveis.remove(posicaoSorteada); 
    } else {
      // Se acabaram as obras disponíveis, desativa este slot
      slots[i].indexProdutoAtribuido = -1;
    }
  }
}

void desenharProdutoFocado() {
  // Centraliza o Nome do Produto na parte superior
  fill(40);
  textSize(24);
  textAlign(CENTER, CENTER);
  text(produtoFocado.nome, width/2, 80);
  
  // Renderiza a Imagem Principal centralizada
  if (produtoFocado.imagensRelacionadas.size() > 0) {
    PImage img = produtoFocado.imagensRelacionadas.get(0);
    
    // Limita o tamanho máximo da imagem no centro mantendo proporções
    float maxH = 450;
    float maxW = 600;
    float renderW = maxW;
    float renderH = (maxW / img.width) * img.height;
    
    if (renderH > maxH) {
      renderH = maxH;
      renderW = (maxH / img.height) * img.width;
    }
    
    imageMode(CENTER);
    image(img, width/2, height/2 + 20, renderW, renderH);
    imageMode(CORNER); // Reseta padrão do Processing
  } else {
    // Placeholder limpo centralizado
    rectMode(CENTER);
    fill(220);
    noStroke();
    rect(width/2, height/2 + 20, 400, 300, 8);
    fill(120);
    textSize(14);
    text("Imagem não disponível", width/2, height/2 + 20);
    rectMode(CORNER);
  }
  textAlign(LEFT, BASELINE); // Reseta alinhamento padrão
}

// ==========================================
// CLASSE AUXILIAR: SLOT DE INTERFACE
// ==========================================
class Slot {
  float x, y, w, h;
  int indexProdutoAtribuido = -1;

  Slot(float x, float y, float w, float h) {
    this.x = x; this.y = y; this.w = w; this.h = h;
  }

  void desenhar() {
    if (indexProdutoAtribuido == -1) return; // Não desenha se estiver vazio
    
    Produto p = produtos.get(indexProdutoAtribuido);
    
    if (isMouseOver()) { fill(255); stroke(180); } 
    else { fill(250); stroke(220); }
    
    strokeWeight(1);
    rect(x, y, w, h, 6);
    
    desenharConteudoInterno(p, x, y, w, h);
  }

  boolean isMouseOver() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
}

void posicionarSlotsAoRedor(float mx, float my, float gap) {
  float w = slots[0].w;
  float h = slots[0].h;
  
  // Mapeamento de uma grade 3x3 oca (NW, N, NE, W, E, SW, S, SE)
  slots[0].x = mx - gap - w; slots[0].y = my - gap - h; // Superior Esq
  slots[1].x = mx - w/2;     slots[1].y = my - gap - h; // Superior Centro
  slots[2].x = mx + gap;     slots[2].y = my - gap - h; // Superior Dir
  
  slots[3].x = mx - gap - w; slots[3].y = my - h/2;     // Meio Esq
  slots[4].x = mx + gap;     slots[4].y = my - h/2;     // Meio Dir
  
  slots[5].x = mx - gap - w; slots[5].y = my + gap;     // Inferior Esq
  slots[6].x = mx - w/2;     slots[6].y = my + gap;     // Inferior Centro
  slots[7].x = mx + gap;     slots[7].y = my + gap;     // Inferior Dir
}
 

class Card {
  float x, y, w, h;
  Produto p;

  Card(float x, float y, float w, float h, Produto p) {
    this.x = x; this.y = y; this.w = w; this.h = h;
    this.p = p;
  }
  
  void desenhar() {
    // Sombra do card para destacá-old
    fill(0, 30);
    noStroke();
    rect(x + 3, y + 3, w, h, 6);
    
    // Fundo do card
    fill(255);
    stroke(150);
    strokeWeight(1);
    rect(x, y, w, h, 6);
    
    desenharConteudoInterno(p, x, y, w, h);
    
    // Botão de Fechar (X) vermelho no canto superior direito
    if (isCloseHovered()) fill(255, 50, 50); else fill(200, 80, 80);
    noStroke();
    rect(x + w - 20, y, 20, 20, 0, 6, 0, 4); // Canto arredondado no topo direito
    
    fill(255);
    textSize(10);
    textAlign(CENTER, CENTER);
    text("X", x + w - 10, y + 10);
    textAlign(LEFT, BASELINE);
  }

  boolean isMouseOver() {
    return (mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h);
  }
  
  boolean isCloseHovered() {
    return (mouseX >= x + w - 20 && mouseX <= x + w && mouseY >= y && mouseY <= y + 20);
  }
}

// Função auxiliar para reaproveitar a renderização da imagem/texto do Slot e do Card
void desenharConteudoInterno(Produto p, float x, float y, float w, float h) {
  float thumbW = w - 10;
  float thumbH = h - 35;
  
  if (p.imagensRelacionadas.size() > 0) {
    PImage img = p.imagensRelacionadas.get(0);
    float renderW = thumbW;
    float renderH = (thumbW / img.width) * img.height;
    if (renderH > thumbH) {
      renderH = thumbH;
      renderW = (thumbH / img.height) * img.width;
    }
    image(img, x + 5 + (thumbW - renderW)/2, y + 5 + (thumbH - renderH)/2, renderW, renderH);
  } else {
    fill(235);
    noStroke();
    rect(x + 5, y + 5, thumbW, thumbH, 4);
  }
  
  fill(40);
  textSize(10);
  textAlign(CENTER, TOP);
  text(p.nome, x + 5, y + h - 25, w - 10, 25);
  textAlign(LEFT, BASELINE);
}

void sortearProdutosParaSlots() {
  ArrayList<Integer> indicesDisponiveis = new ArrayList<Integer>();
  
  for (int i = 0; i < produtos.size(); i++) {
    // Requisito 6: Verifica se a obra já está em formato de Card na mesa
    boolean jaEstaNaMesa = false;
    for (Card c : cardsAtivos) {
      if (c.p.id == produtos.get(i).id) {
        jaEstaNaMesa = true;
        break;
      }
    }
    
    // Se não estiver na mesa, é elegível para aparecer no Slot
    if (!jaEstaNaMesa) {
      indicesDisponiveis.add(i);
    }
  }
  
  // Preenche os 8 slots com as obras disponíveis
  for (int i = 0; i < slots.length; i++) {
    if (indicesDisponiveis.size() > 0) {
      int posicaoSorteada = int(random(indicesDisponiveis.size()));
      slots[i].indexProdutoAtribuido = indicesDisponiveis.get(posicaoSorteada);
      indicesDisponiveis.remove(posicaoSorteada); 
    } else {
      // Se acabaram as obras disponíveis, desativa este slot
      slots[i].indexProdutoAtribuido = -1;
    }
  }
}

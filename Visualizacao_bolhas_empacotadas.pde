int VISAO_CIRCULAR = 0;
int VISAO_BOLHAS = 1;
int VISAO_LINHA_TEMPO = 2;
int visualizacaoAtiva = VISAO_CIRCULAR;
PFont fonteBotaoVisualizacao;
PFont fonteExportarTitulo;
PFont fonteExportarOpcao;
PFont fonteExportarTexto;
PImage iconeExportar;
boolean painelExportacaoAberto = false;
boolean exportarCircular = true;
boolean exportarBolhas = true;
boolean exportarLinhaTempo = true;
String mensagemExportacao = "";
int mensagemExportacaoFrame = 0;

VisualizacaoBolhasEmpacotadas visualizacaoBolhas;
VisualizacaoLinhaTempo visualizacaoLinhaTempo;

void inicializarVisualizacoes() {
  inicializarVisualizacaoCircular();
  inicializarVisualizacaoBolhasEmpacotadas();
  inicializarVisualizacaoLinhaTempo();
  fonteBotaoVisualizacao = createFont("Afacad Flux Bold", 10, true);
  fonteExportarTitulo = createFont("Afacad Flux Bold", 34, true);
  fonteExportarOpcao = createFont("Afacad Flux Regular", 37, true);
  fonteExportarTexto = createFont("Roboto Condensed", 16, true);
  iconeExportar = loadImage("Icones/export.png");
}

void inicializarVisualizacaoBolhasEmpacotadas() {
  visualizacaoBolhas = new VisualizacaoBolhasEmpacotadas(sistemaFiltros);
  visualizacaoBolhas.carregarAssets();
}

void inicializarVisualizacaoLinhaTempo() {
  visualizacaoLinhaTempo = new VisualizacaoLinhaTempo(sistemaFiltros);
  visualizacaoLinhaTempo.carregarAssets();
}

void desenharVisualizacaoAtual() {
  desenharVisualizacaoPorId(visualizacaoAtiva);
  desenharBotaoExportar();
  desenharBotaoAlternarVisualizacao();
  desenharPainelExportacao();
}

void desenharVisualizacaoPorId(int visao) {
  if (visao == VISAO_LINHA_TEMPO) {
    desenharVisualizacaoLinhaTempo();
  } else if (visao == VISAO_BOLHAS) {
    desenharVisualizacaoBolhasEmpacotadas();
  } else {
    desenharVisualizacaoCircular();
  }
}

void desenharVisualizacaoBolhasEmpacotadas() {
  if (visualizacaoBolhas != null) {
    visualizacaoBolhas.desenhar();
  }
}

void desenharVisualizacaoLinhaTempo() {
  if (visualizacaoLinhaTempo != null) {
    visualizacaoLinhaTempo.desenhar();
  }
}

boolean visualizacaoAtualMousePressed() {
  if (exportacaoMousePressed(mouseX, mouseY)) {
    return true;
  }

  if (clicouBotaoAlternarVisualizacao(mouseX, mouseY)) {
    visualizacaoAtiva = (visualizacaoAtiva + 1) % 3;
    return true;
  }
  if (visualizacaoAtiva == VISAO_LINHA_TEMPO) {
    return visualizacaoLinhaTempo != null && visualizacaoLinhaTempo.mousePressed(mouseX, mouseY);
  }
  if (visualizacaoAtiva == VISAO_BOLHAS) {
    return visualizacaoBolhas != null && visualizacaoBolhas.mousePressed(mouseX, mouseY);
  }
  return visualizacaoCircularMousePressed();
}

boolean visualizacaoAtualMouseDragged() {
  if (painelExportacaoAberto) {
    return true;
  }

  if (visualizacaoAtiva == VISAO_LINHA_TEMPO) {
    return visualizacaoLinhaTempo != null && visualizacaoLinhaTempo.mouseDragged(mouseX, mouseY);
  }
  if (visualizacaoAtiva == VISAO_BOLHAS) {
    return visualizacaoBolhas != null && visualizacaoBolhas.mouseDragged(mouseX, mouseY);
  }
  return visualizacaoCircularMouseDragged();
}

void visualizacaoAtualMouseReleased() {
  if (visualizacaoAtiva == VISAO_CIRCULAR) {
    visualizacaoCircularMouseReleased();
  } else if (visualizacaoAtiva == VISAO_LINHA_TEMPO && visualizacaoLinhaTempo != null) {
    visualizacaoLinhaTempo.mouseReleased();
  } else if (visualizacaoBolhas != null) {
    visualizacaoBolhas.mouseReleased();
  }
}

void desenharBotaoAlternarVisualizacao() {
  float bx = botaoVisualizacaoX();
  float by = botaoVisualizacaoY();
  float bw = 44;
  float bh = 28;

  pushStyle();
  stroke(#FFFFFF);
  strokeWeight(1.5f);
  fill(#151515, 220);
  rect(bx, by, bw, bh, 7);

  noStroke();
  fill(visualizacaoAtiva == VISAO_BOLHAS ? #FF00FB : #D9D9D9);
  ellipse(bx + 15, by + 14, 12, 12);
  fill(#FFCB00);
  ellipse(bx + 27, by + 13, 8, 8);
  fill(#FFFFFF);
  textFont(fonteBotaoVisualizacao);
  textAlign(CENTER, CENTER);
  text(rotuloProximaVisualizacao(), bx + 36, by + 14);
  popStyle();
}

String rotuloProximaVisualizacao() {
  if (visualizacaoAtiva == VISAO_CIRCULAR) {
    return "B";
  }
  if (visualizacaoAtiva == VISAO_BOLHAS) {
    return "T";
  }
  return "C";
}

boolean clicouBotaoAlternarVisualizacao(float mx, float my) {
  float bx = botaoVisualizacaoX();
  float by = botaoVisualizacaoY();
  return mx >= bx && mx <= bx + 44 && my >= by && my <= by + 28;
}

float botaoVisualizacaoX() {
  return direitaVisualLayout() - 58;
}

float botaoVisualizacaoY() {
  return 16;
}

void desenharBotaoExportar() {
  float bx = botaoExportarX();
  float by = botaoExportarY();
  float d = 78;

  pushStyle();
  noFill();
  stroke(#FFFFFF);
  strokeWeight(3);
  ellipse(bx + d/2, by + d/2, d, d);

  if (iconeExportar != null) {
    tint(#FFFFFF);
    image(iconeExportar, bx + 20, by + 20, 38, 38);
    noTint();
  } else {
    desenharIconeExportarVetorial(bx + d/2, by + d/2);
  }
  popStyle();
}

void desenharIconeExportarVetorial(float cx, float cy) {
  stroke(#FFFFFF);
  strokeWeight(5);
  strokeCap(SQUARE);
  noFill();
  line(cx, cy - 18, cx, cy + 8);
  line(cx - 13, cy - 4, cx, cy + 9);
  line(cx + 13, cy - 4, cx, cy + 9);
  rect(cx - 21, cy + 10, 42, 20);
}

void desenharPainelExportacao() {
  if (!painelExportacaoAberto) {
    return;
  }

  float px = painelExportacaoX();
  float py = painelExportacaoY();
  float pw = painelExportacaoW();
  float ph = painelExportacaoH();

  pushStyle();
  noStroke();
  fill(#202020, 248);
  rect(px, py, pw, ph);

  fill(#FFFFFF);
  textFont(fonteExportarTitulo);
  textAlign(LEFT, TOP);
  text("Exportar", px + 28, py + 18);

  desenharOpcaoFormatoExportacao("PDF", px + 28, py + 92);
  desenharOpcaoFormatoExportacao("JPG", px + 28, py + 166);
  desenharOpcaoFormatoExportacao("SVG", px + 28, py + 240);

  desenharChecklistExportacao(px + 274, py + 96);
  desenharMensagemExportacao(px + 28, py + ph - 34, pw - 56);
  popStyle();
}

void desenharOpcaoFormatoExportacao(String formato, float x, float y) {
  float w = 210;
  float h = 55;
  noStroke();
  fill(#000000);
  rect(x, y, w, h, 6);

  fill(#FFFFFF);
  textFont(fonteExportarOpcao);
  textAlign(LEFT, CENTER);
  text(formato, x + 20, y + h/2 - 2);

  noFill();
  stroke(#FFFFFF);
  strokeWeight(3);
  ellipse(x + w - 28, y + h/2, 27, 27);
  strokeWeight(2.5f);
  line(x + w - 28, y + h/2 - 10, x + w - 28, y + h/2 + 3);
  line(x + w - 36, y + h/2 - 3, x + w - 28, y + h/2 + 5);
  line(x + w - 20, y + h/2 - 3, x + w - 28, y + h/2 + 5);
  line(x + w - 37, y + h/2 + 9, x + w - 19, y + h/2 + 9);
}

void desenharChecklistExportacao(float x, float y) {
  fill(#FFFFFF);
  textFont(fonteExportarTexto);
  textSize(16);
  textAlign(LEFT, TOP);
  text("Visualizacoes", x, y - 32);

  desenharCheckExportacao("Circular", exportarCircular, x, y);
  desenharCheckExportacao("Bolhas", exportarBolhas, x, y + 42);
  desenharCheckExportacao("Linha do tempo", exportarLinhaTempo, x, y + 84);
}

void desenharCheckExportacao(String rotulo, boolean ativo, float x, float y) {
  stroke(#FFFFFF);
  strokeWeight(2);
  fill(ativo ? #FFCB00 : #111111);
  rect(x, y, 22, 22, 4);

  if (ativo) {
    stroke(#000000);
    strokeWeight(3);
    line(x + 5, y + 11, x + 10, y + 17);
    line(x + 10, y + 17, x + 18, y + 5);
  }

  fill(#FFFFFF);
  noStroke();
  textFont(fonteExportarTexto);
  textSize(16);
  textAlign(LEFT, CENTER);
  text(rotulo, x + 34, y + 11);
}

void desenharMensagemExportacao(float x, float y, float largura) {
  if (mensagemExportacao.length() == 0) {
    return;
  }

  fill(frameCount - mensagemExportacaoFrame < 180 ? #FFCB00 : #FFFFFF);
  textFont(fonteExportarTexto);
  textSize(13);
  textAlign(LEFT, TOP);
  text(mensagemExportacao, x, y, largura, 28);
}

boolean exportacaoMousePressed(float mx, float my) {
  if (clicouBotaoExportar(mx, my)) {
    painelExportacaoAberto = !painelExportacaoAberto;
    return true;
  }

  if (!painelExportacaoAberto) {
    return false;
  }

  if (clicouFormatoExportacao(mx, my, "PDF")) {
    exportarVisualizacoesSelecionadas("PDF");
    return true;
  }
  if (clicouFormatoExportacao(mx, my, "JPG")) {
    exportarVisualizacoesSelecionadas("JPG");
    return true;
  }
  if (clicouFormatoExportacao(mx, my, "SVG")) {
    exportarVisualizacoesSelecionadas("SVG");
    return true;
  }

  if (clicouChecklistExportacao(mx, my)) {
    return true;
  }

  if (dentroPainelExportacao(mx, my)) {
    return true;
  }

  painelExportacaoAberto = false;
  return true;
}

boolean clicouBotaoExportar(float mx, float my) {
  float cx = botaoExportarX() + 39;
  float cy = botaoExportarY() + 39;
  return dist(mx, my, cx, cy) <= 42;
}

boolean clicouFormatoExportacao(float mx, float my, String formato) {
  float x = painelExportacaoX() + 28;
  float y = painelExportacaoY() + 92;
  if (formato.equals("JPG")) {
    y += 74;
  } else if (formato.equals("SVG")) {
    y += 148;
  }
  return mx >= x && mx <= x + 210 && my >= y && my <= y + 55;
}

boolean clicouChecklistExportacao(float mx, float my) {
  float x = painelExportacaoX() + 274;
  float y = painelExportacaoY() + 96;

  if (clicouCheck(mx, my, x, y)) {
    exportarCircular = !exportarCircular;
    return true;
  }
  if (clicouCheck(mx, my, x, y + 42)) {
    exportarBolhas = !exportarBolhas;
    return true;
  }
  if (clicouCheck(mx, my, x, y + 84)) {
    exportarLinhaTempo = !exportarLinhaTempo;
    return true;
  }
  return false;
}

boolean clicouCheck(float mx, float my, float x, float y) {
  return mx >= x && mx <= x + 220 && my >= y - 8 && my <= y + 30;
}

boolean dentroPainelExportacao(float mx, float my) {
  return mx >= painelExportacaoX() && mx <= painelExportacaoX() + painelExportacaoW() &&
    my >= painelExportacaoY() && my <= painelExportacaoY() + painelExportacaoH();
}

float botaoExportarX() {
  return LAYOUT_FILTRO_W + 38;
}

float botaoExportarY() {
  return 50;
}

float painelExportacaoX() {
  return LAYOUT_FILTRO_W + 150;
}

float painelExportacaoY() {
  return 50;
}

float painelExportacaoW() {
  return min(475, max(340, larguraVisualLayout() - 190));
}

float painelExportacaoH() {
  return 350;
}

void exportarVisualizacoesSelecionadas(String formato) {
  ArrayList<Integer> visoes = visoesSelecionadasParaExportar();
  if (visoes.size() == 0) {
    mensagemExportacao = "Selecione pelo menos uma visualizacao.";
    mensagemExportacaoFrame = frameCount;
    return;
  }

  File pasta = new File(sketchPath("exports"));
  pasta.mkdirs();

  int visualizacaoAnterior = visualizacaoAtiva;
  boolean painelAnterior = painelExportacaoAberto;
  painelExportacaoAberto = false;

  String marca = timestampExportacao();
  for (int i = 0; i < visoes.size(); i++) {
    int visao = visoes.get(i);
    String caminho = pasta.getAbsolutePath() + File.separator + marca + "_" + nomeArquivoVisualizacao(visao) + "." + formato.toLowerCase();
    exportarVisualizacao(visao, formato, caminho);
  }

  visualizacaoAtiva = visualizacaoAnterior;
  painelExportacaoAberto = painelAnterior;
  mensagemExportacao = "Exportado em exports/ (" + formato + ")";
  mensagemExportacaoFrame = frameCount;
}

ArrayList<Integer> visoesSelecionadasParaExportar() {
  ArrayList<Integer> visoes = new ArrayList<Integer>();
  if (exportarCircular) {
    visoes.add(VISAO_CIRCULAR);
  }
  if (exportarBolhas) {
    visoes.add(VISAO_BOLHAS);
  }
  if (exportarLinhaTempo) {
    visoes.add(VISAO_LINHA_TEMPO);
  }
  return visoes;
}

void exportarVisualizacao(int visao, String formato, String caminho) {
  visualizacaoAtiva = visao;

  if (formato.equals("JPG")) {
    desenharVisualizacaoPorId(visao);
    PImage captura = get(LAYOUT_FILTRO_W, 0, round(larguraVisualLayout()), height);
    captura.save(caminho);
    return;
  }

  if (formato.equals("PDF")) {
    beginRecord(PDF, caminho);
    desenharVisualizacaoPorId(visao);
    endRecord();
    return;
  }

  beginRecord(SVG, caminho);
  desenharVisualizacaoPorId(visao);
  endRecord();
}

String nomeArquivoVisualizacao(int visao) {
  if (visao == VISAO_BOLHAS) {
    return "bolhas";
  }
  if (visao == VISAO_LINHA_TEMPO) {
    return "linha_do_tempo";
  }
  return "circular";
}

String timestampExportacao() {
  return nf(year(), 4) + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2);
}

class VisualizacaoBolhasEmpacotadas {
  SistemaFiltros filtros;

  final int X = 255;
  final int Y = 0;
  final int W = 1166;
  final int H = 1080;
  final int TIMELINE_W = 1158;
  final int TIMELINE_H = 100;
  final int TIMELINE_HANDLE_W = 7;
  final int TIMELINE_HANDLE_H = 70;
  final int ANO_MIN = 1880;
  final int ANO_MAX = 2010;

  final color COR_FUNDO = #111111;
  final color COR_BOLHA = #D9D9D9;
  final color COR_TEXTO = #000000;
  final color COR_NACIONAL = #FFCB00;
  final color COR_INTERNACIONAL = #FF00FB;

  PFont fonteGrupo;
  PFont fontePequena;
  PFont fonteAno;

  ArrayList<AreaProdutoBolha> areasProdutos = new ArrayList<AreaProdutoBolha>();
  int anoInicio = 1880;
  int anoFim = 2010;
  int handleArrastado = 0;

  VisualizacaoBolhasEmpacotadas(SistemaFiltros filtros) {
    this.filtros = filtros;
  }

  void carregarAssets() {
    fonteGrupo = createFont("Afacad Flux Bold", 17, true);
    fontePequena = createFont("Roboto Condensed", 11, true);
    fonteAno = createFont("Afacad Flux SemiBold", 30, true);
  }

  void desenhar() {
    pushStyle();
    desenharFundo();

    float cx = centroX();
    float cy = centroY();
    float raioExterno = raioExterno();
    ArrayList<GrupoBolha> grupos = gruposVisiveis();

    posicionarGrupos(grupos, cx, cy, raioExterno);
    desenharCirculoExterno(cx, cy, raioExterno);
    areasProdutos.clear();

    for (GrupoBolha grupo : grupos) {
      desenharGrupo(grupo);
    }

    if (grupos.size() == 0) {
      desenharMensagemVazia(cx, cy);
    }

    desenharTimeline();
    popStyle();
  }

  void desenharFundo() {
    noStroke();
    fill(COR_FUNDO);
    rect(X, Y, larguraVisual(), alturaVisual());
  }

  void desenharCirculoExterno(float cx, float cy, float raio) {
    noFill();
    stroke(#FFFFFF);
    strokeWeight(4);
    ellipse(cx, cy, raio * 2, raio * 2);
  }

  void desenharGrupo(GrupoBolha grupo) {
    stroke(#000000);
    strokeWeight(2);
    fill(COR_BOLHA);
    ellipse(grupo.x, grupo.y, grupo.r * 2, grupo.r * 2);

    desenharProdutosDoGrupo(grupo);
    desenharNomeGrupo(grupo);
  }

  void desenharProdutosDoGrupo(GrupoBolha grupo) {
    int total = grupo.produtos.size();
    if (total == 0) {
      return;
    }

    float margem = max(18, grupo.r * 0.25f);
    float raioUtil = max(6, grupo.r - margem);
    float dotR = constrain(raioUtil / max(2.2f, sqrt(total) * 2.2f), 5, 9);

    for (int i = 0; i < total; i++) {
      ProdutoFiltrado produto = grupo.produtos.get(i);
      PVector pos = posicaoProdutoNoGrupo(grupo, i, total, raioUtil);
      noStroke();
      fill(produto.origem.equals("brasileiro") ? COR_NACIONAL : COR_INTERNACIONAL);
      ellipse(pos.x, pos.y, dotR * 2, dotR * 2);
      areasProdutos.add(new AreaProdutoBolha(produto, pos.x, pos.y, dotR + 4));
    }
  }

  PVector posicaoProdutoNoGrupo(GrupoBolha grupo, int indice, int total, float raioUtil) {
    if (total == 1) {
      return new PVector(grupo.x, grupo.y + grupo.r * 0.28f);
    }

    float angulo = indice * 2.3999632f - HALF_PI;
    float distancia = sqrt((indice + 0.5f) / total) * raioUtil;
    return new PVector(grupo.x + cos(angulo) * distancia, grupo.y + sin(angulo) * distancia);
  }

  void desenharNomeGrupo(GrupoBolha grupo) {
    fill(COR_TEXTO);
    textFont(fonteGrupo);
    float tamanho = tamanhoTextoGrupo(grupo.nome, grupo.r * 1.45f);
    textSize(tamanho);
    textAlign(CENTER, CENTER);
    text(grupo.nome, grupo.x - grupo.r * 0.72f, grupo.y - tamanho * 0.75f, grupo.r * 1.44f, tamanho * 3.2f);
  }

  void desenharMensagemVazia(float cx, float cy) {
    fill(#FFFFFF, 180);
    textFont(fontePequena);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Nenhum produto encontrado para os filtros atuais", cx, cy);
  }

  ArrayList<GrupoBolha> gruposVisiveis() {
    HashMap<String, GrupoBolha> porNome = new HashMap<String, GrupoBolha>();
    ArrayList<ProdutoFiltrado> produtos = produtosExibidosNaVisualizacaoCircular();

    for (ProdutoFiltrado produto : produtos) {
      int ano = anoProduto(produto);
      if (ano < anoInicio || ano > anoFim) {
        continue;
      }

      String grupoNome = nomeGrupoProduto(produto);
      if (!porNome.containsKey(grupoNome)) {
        porNome.put(grupoNome, new GrupoBolha(grupoNome));
      }
      porNome.get(grupoNome).produtos.add(produto);
    }

    ArrayList<GrupoBolha> grupos = new ArrayList<GrupoBolha>();
    for (GrupoBolha grupo : porNome.values()) {
      ordenarProdutos(grupo.produtos);
      grupos.add(grupo);
    }

    Collections.sort(grupos, new Comparator<GrupoBolha>() {
      public int compare(GrupoBolha a, GrupoBolha b) {
        if (b.produtos.size() != a.produtos.size()) {
          return b.produtos.size() - a.produtos.size();
        }
        return a.nome.compareToIgnoreCase(b.nome);
      }
    });

    calcularRaiosGrupos(grupos);

    return grupos;
  }

  void desenharTimeline() {
    float tx = X + 4;
    float ty = limiteInferiorVisual();

    noStroke();
    fill(#505050);
    rect(tx, ty + 40, timelineW(), 60);

    float xInicio = xAno(anoInicio);
    float xFim = xAno(anoFim);
    fill(#FFCB00);
    rect(xInicio + TIMELINE_HANDLE_W, ty + 40, max(0, xFim - xInicio - TIMELINE_HANDLE_W), 60);

    float faixaX = xInicio + TIMELINE_HANDLE_W;
    float faixaW = max(0, xFim - xInicio - TIMELINE_HANDLE_W);
    clip(round(faixaX), round(ty + 40), round(faixaW), 60);
    stroke(#202020);
    strokeWeight(3);
    for (float hx = xInicio - 60; hx < xFim; hx += 18) {
      line(hx, ty + 100, hx + 58, ty + 40);
    }
    noClip();

    noStroke();
    fill(#505050);
    rect(tx, ty + 40, max(0, faixaX - tx), 60);
    rect(xFim, ty + 40, max(0, tx + timelineW() - xFim), 60);

    fill(#FFFFFF);
    rect(xInicio, ty + 10, TIMELINE_HANDLE_W, TIMELINE_HANDLE_H);
    rect(xFim, ty + 10, TIMELINE_HANDLE_W, TIMELINE_HANDLE_H);

    desenharAnoTimeline(anoInicio, xInicio, ty);
    desenharAnoTimeline(anoFim, xFim, ty);
  }

  void desenharAnoTimeline(int ano, float x, float ty) {
    fill(#FFFFFF);
    textFont(fonteAno);
    textSize(30);
    textAlign(CENTER, BOTTOM);

    float yTexto = ty + 8;
    if (x < X + 48) {
      x += 40;
    }
    if (x > X + larguraVisual() - 48) {
      x -= 40;
    }
    text(str(ano), x, yTexto);
  }

  void ordenarProdutos(ArrayList<ProdutoFiltrado> produtos) {
    Collections.sort(produtos, new Comparator<ProdutoFiltrado>() {
      public int compare(ProdutoFiltrado a, ProdutoFiltrado b) {
        return a.nome.compareToIgnoreCase(b.nome);
      }
    });
  }

  String nomeGrupoProduto(ProdutoFiltrado produto) {
    if (produto.origem.equals("brasileiro")) {
      return "Obras brasileiras";
    }

    String escola = valorColuna(produto, "Escola ou movimento", 5);
    if (trim(escola).length() == 0) {
      return "Sem escola";
    }
    return nomeCanonicoMovimento(escola);
  }

  String nomeCanonicoMovimento(String nome) {
    String texto = filtros.normalizarBusca(nome);
    texto = texto.replaceAll("\\s*/\\s*", " / ");

    if (texto.indexOf("bahaus") >= 0 || texto.indexOf("bauhaus") >= 0) {
      return "Bauhaus";
    }
    if (texto.indexOf("modernismo norte") >= 0) {
      return "Modernismo Norte-Americano";
    }
    if (texto.indexOf("pop art") >= 0) {
      return "Pop Art";
    }
    if (texto.indexOf("estilo internacional") >= 0) {
      return "Estilo Internacional";
    }
    if (texto.indexOf("hfg ulm") >= 0 || texto.indexOf("good design") >= 0) {
      return "HfG Ulm / Good Design";
    }
    if (texto.indexOf("cranbrook academy") >= 0) {
      return "Cranbrook Academy of Art";
    }
    if (texto.indexOf("california new wave") >= 0) {
      return "California New Wave";
    }
    if (texto.indexOf("deutscher werkbund") >= 0) {
      return "Deutscher Werkbund";
    }
    if (texto.indexOf("art nouveau") >= 0 && texto.indexOf("jugendstil") < 0) {
      return "Art Nouveau";
    }
    if (texto.indexOf("jugendstil") >= 0) {
      return "Jugendstil";
    }
    if (texto.indexOf("streamlining") >= 0) {
      return "Streamlining";
    }
    if (texto.indexOf("anti-design") >= 0 || texto.indexOf("anti design") >= 0) {
      return "Anti-Design";
    }
    if (texto.indexOf("vkhutemas") >= 0) {
      return "Vkhutemas";
    }
    if (texto.indexOf("memphis") >= 0) {
      return "Memphis";
    }
    if (texto.indexOf("biomorfismo") >= 0) {
      return "Biomorfismo";
    }
    if (texto.indexOf("design organico") >= 0) {
      return "Design Orgânico";
    }
    return filtros.limparTexto(nome);
  }

  String valorColuna(ProdutoFiltrado produto, String coluna, int fallback) {
    if (produto == null || produto.linhaOriginal == null) {
      return "";
    }
    try {
      return filtros.limparTexto(produto.linhaOriginal.getString(coluna));
    } catch (Exception erro) {
      try {
        return filtros.limparTexto(produto.linhaOriginal.getString(fallback));
      } catch (Exception outroErro) {
        return "";
      }
    }
  }

  int anoProduto(ProdutoFiltrado produto) {
    String texto = valorColuna(produto, "Datação", 4);
    String[] partes = match(texto, "(18|19|20)\\d\\d");
    if (partes != null && partes.length > 0) {
      return int(partes[0]);
    }
    return ANO_MIN;
  }

  void calcularRaiosGrupos(ArrayList<GrupoBolha> grupos) {
    if (grupos.size() == 0) {
      return;
    }

    float somaArea = 0;
    for (GrupoBolha grupo : grupos) {
      grupo.r = raioGrupoBase(grupo.produtos.size());
      somaArea += PI * grupo.r * grupo.r;
    }

    float areaDisponivel = PI * raioExterno() * raioExterno() * 0.66f;
    float escala = somaArea > areaDisponivel ? sqrt(areaDisponivel / somaArea) : 1;
    for (GrupoBolha grupo : grupos) {
      grupo.r = constrain(grupo.r * escala, 30, 118);
    }
  }

  float raioGrupoBase(int totalProdutos) {
    return constrain(30 + sqrt(totalProdutos) * 16.0f, 38, 118);
  }

  void posicionarGrupos(ArrayList<GrupoBolha> grupos, float cx, float cy, float raioExterno) {
    if (grupos.size() == 0) {
      return;
    }

    for (int i = 0; i < grupos.size(); i++) {
      GrupoBolha grupo = grupos.get(i);
      if (i == 0) {
        grupo.x = cx;
        grupo.y = cy;
      } else {
        float angulo = -HALF_PI + i * 2.3999632f;
        float distancia = min(raioExterno - grupo.r - 10, 42 + sqrt(i) * 72);
        grupo.x = cx + cos(angulo) * distancia;
        grupo.y = cy + sin(angulo) * distancia;
      }
    }

    for (int iteracao = 0; iteracao < 420; iteracao++) {
      relaxarGrupos(grupos, cx, cy, raioExterno);
    }
  }

  void relaxarGrupos(ArrayList<GrupoBolha> grupos, float cx, float cy, float raioExterno) {
    for (GrupoBolha grupo : grupos) {
      grupo.x += (cx - grupo.x) * 0.0035f;
      grupo.y += (cy - grupo.y) * 0.0035f;
    }

    for (int i = 0; i < grupos.size(); i++) {
      GrupoBolha a = grupos.get(i);
      for (int j = i + 1; j < grupos.size(); j++) {
        GrupoBolha b = grupos.get(j);
        float dx = b.x - a.x;
        float dy = b.y - a.y;
        float distAtual = max(0.001f, sqrt(dx * dx + dy * dy));
        float distMin = a.r + b.r + 4;
        if (distAtual < distMin) {
          float empurrao = (distMin - distAtual) * 0.5f;
          float nx = dx / distAtual;
          float ny = dy / distAtual;
          a.x -= nx * empurrao;
          a.y -= ny * empurrao;
          b.x += nx * empurrao;
          b.y += ny * empurrao;
        }
      }
    }

    for (GrupoBolha grupo : grupos) {
      manterDentroDoCirculo(grupo, cx, cy, raioExterno);
    }
  }

  void manterDentroDoCirculo(GrupoBolha grupo, float cx, float cy, float raioExterno) {
    float dx = grupo.x - cx;
    float dy = grupo.y - cy;
    float distancia = sqrt(dx * dx + dy * dy);
    float limite = raioExterno - grupo.r - 8;
    if (distancia > limite && distancia > 0) {
      grupo.x = cx + dx / distancia * limite;
      grupo.y = cy + dy / distancia * limite;
    }
  }

  boolean mousePressed(float mx, float my) {
    if (!dentro(mx, my)) {
      return false;
    }

    if (clicouHandleTempo(mx, my)) {
      return true;
    }

    ProdutoFiltrado produto = produtoSobMouse(mx, my);
    if (produto != null) {
      painelProdutoSelecionar(produto);
      return true;
    }

    return false;
  }

  boolean mouseDragged(float mx, float my) {
    if (handleArrastado == 0) {
      return false;
    }

    int novoAno = anoPorX(mx);
    if (handleArrastado == 1) {
      anoInicio = constrain(novoAno, ANO_MIN, anoFim);
    } else {
      anoFim = constrain(novoAno, anoInicio, ANO_MAX);
    }
    return true;
  }

  void mouseReleased() {
    handleArrastado = 0;
  }

  boolean clicouHandleTempo(float mx, float my) {
    float ty = limiteInferiorVisual();
    if (my < ty || my > ty + TIMELINE_H) {
      return false;
    }

    float xi = xAno(anoInicio);
    float xf = xAno(anoFim);
    if (abs(mx - xi) < 18) {
      handleArrastado = 1;
      return true;
    }
    if (abs(mx - xf) < 18) {
      handleArrastado = 2;
      return true;
    }
    return false;
  }

  ProdutoFiltrado produtoSobMouse(float mx, float my) {
    for (int i = areasProdutos.size() - 1; i >= 0; i--) {
      AreaProdutoBolha area = areasProdutos.get(i);
      if (dist(mx, my, area.x, area.y) <= area.r) {
        return area.produto;
      }
    }
    return null;
  }

  boolean dentro(float mx, float my) {
    return mx >= X && mx <= X + larguraVisual() && my >= Y && my <= Y + alturaVisual();
  }

  float centroX() {
    return X + larguraVisual()/2.0f;
  }

  float centroY() {
    return Y + (alturaVisual() - TIMELINE_H)/2.0f;
  }

  float raioExterno() {
    return min(500, min(larguraVisual() - 120, alturaVisual() - TIMELINE_H - 80) / 2.0f);
  }

  float limiteInferiorVisual() {
    return Y + alturaVisual() - TIMELINE_H;
  }

  float xAno(int ano) {
    float tx = X + 4;
    return tx + map(ano, ANO_MIN, ANO_MAX, 0, timelineW() - TIMELINE_HANDLE_W);
  }

  int anoPorX(float x) {
    float tx = X + 4;
    float fim = tx + timelineW() - TIMELINE_HANDLE_W;
    int ano = round(map(constrain(x, tx, fim), tx, fim, ANO_MIN, ANO_MAX) / 10.0f) * 10;
    return constrain(ano, ANO_MIN, ANO_MAX);
  }

  float larguraVisual() {
    return larguraVisualLayout();
  }

  float alturaVisual() {
    return height;
  }

  float timelineW() {
    return larguraTimelineLayout();
  }

  float tamanhoTextoGrupo(String texto, float largura) {
    float tamanho = 17;
    textFont(fonteGrupo);
    textSize(tamanho);
    while (textWidth(texto) > largura && tamanho > 10) {
      tamanho -= 1;
      textSize(tamanho);
    }
    return tamanho;
  }
}

class GrupoBolha {
  String nome;
  ArrayList<ProdutoFiltrado> produtos = new ArrayList<ProdutoFiltrado>();
  float x;
  float y;
  float r;

  GrupoBolha(String nome) {
    this.nome = nome;
  }
}

class AreaProdutoBolha {
  ProdutoFiltrado produto;
  float x;
  float y;
  float r;

  AreaProdutoBolha(ProdutoFiltrado produto, float x, float y, float r) {
    this.produto = produto;
    this.x = x;
    this.y = y;
    this.r = r;
  }
}

PainelProduto painelProduto;

void inicializarPainelProduto() {
  painelProduto = new PainelProduto(sistemaFiltros);
  painelProduto.carregarAssets();
}

void desenharPainelProduto() {
  if (painelProduto != null) {
    painelProduto.desenhar();
  }
}

boolean painelProdutoMousePressed() {
  return painelProduto != null && painelProduto.mousePressed(mouseX, mouseY);
}

boolean painelProdutoMouseWheel(processing.event.MouseEvent evento) {
  return painelProduto != null && painelProduto.mouseWheel(evento);
}

boolean painelProdutoKeyPressed(char tecla, int codigo) {
  return painelProduto != null && painelProduto.keyPressed(tecla, codigo);
}

void painelProdutoSelecionar(ProdutoFiltrado produto) {
  if (painelProduto != null) {
    painelProduto.selecionar(produto);
  }
}

boolean painelProdutoPrecisaSelecao() {
  return painelProduto != null && painelProduto.produto == null;
}

class PainelProduto {
  SistemaFiltros filtros;
  ProdutoFiltrado produto;

  final int W = 505;
  final int IMAGE_H = 337;
  final int INFO_H = 80;
  final float TAB_W = W / 2.0f;
  final int TAB_H = 55;
  final int BAR_W = W;
  final int BAR_H = 44;

  final color COR_AMARELO = #FFCB00;
  final color COR_FUNDO = #222222;
  final color COR_ABA_INATIVA = #624E00;
  final color COR_MATERIAL = #3E4AD3;
  final color COR_TECNICA = #4AD33E;
  final color COR_ESTETICO = #D33E4A;

  PFont fonteTitulo;
  PFont fonteRegular;
  PFont fonteLight;
  PFont fonteBarra;
  PFont fonteTexto;

  PImage iconeSetaEsquerda;
  PImage iconeSetaDireita;
  PImage iconeContainer;
  PImage iconeSalvar;
  PImage iconeAutor;
  PImage iconeComparar;
  PImage iconeArtesanal;
  PImage iconeDesignAssinado;
  PImage iconeIndustrial;
  PImage iconeMaterial;
  PImage iconeTecnica;
  PImage iconeEstetico;
  PImage iconeClose;
  PImage iconeMore;

  int imagemAtual = 0;
  boolean detalhesAtivo = true;
  boolean materialAberto = true;
  boolean tecnicaAberta = false;
  boolean esteticoAberto = true;
  float scrollDetalhes = 0;
  float maxScrollDetalhes = 0;
  ArrayList<ProdutoFiltrado> produtosSalvos = new ArrayList<ProdutoFiltrado>();
  String buscaSalvos = "";
  boolean buscaSalvosAtiva = false;
  int modoOrdenacaoSalvos = 0;
  float scrollSalvos = 0;
  float maxScrollSalvos = 0;

  PainelProduto(SistemaFiltros filtros) {
    this.filtros = filtros;
  }

  void carregarAssets() {
    fonteTitulo = createFont("Afacad Flux Bold", 20, true);
    fonteRegular = createFont("Afacad Flux Regular", 15, true);
    fonteLight = createFont("Afacad Flux Light", 15, true);
    fonteBarra = createFont("New Amsterdam Regular", 20, true);
    fonteTexto = createFont("Roboto Condensed", 16, true);

    iconeSetaEsquerda = loadImage("Icones/keyboard_arrow_left.png");
    iconeSetaDireita = loadImage("Icones/keyboard_arrow_right.png");
    iconeContainer = loadImage("Icones/containerproduto.png");
    iconeSalvar = loadImage("Icones/salvar_produto.png");
    iconeAutor = loadImage("Icones/autor.png");
    iconeComparar = loadImage("Icones/comparar.png");
    iconeArtesanal = loadImage("Icones/produto artesanal.png");
    iconeDesignAssinado = loadImage("Icones/design_assinado.png");
    iconeIndustrial = loadImage("Icones/produto industrial.png");
    iconeMaterial = loadImage("Icones/material.png");
    iconeTecnica = loadImage("Icones/técnica.png");
    iconeEstetico = loadImage("Icones/estético.png");
    iconeClose = loadImage("Icones/close.png");
    iconeMore = loadImage("Icones/more.png");
  }

  void selecionar(ProdutoFiltrado novoProduto) {
    if (novoProduto == null) {
      return;
    }
    if (produto == null || !produto.id.equals(novoProduto.id) || !produto.origem.equals(novoProduto.origem)) {
      produto = novoProduto;
      imagemAtual = 0;
      scrollDetalhes = 0;
    }
  }

  void desenhar() {
    float x = painelX();
    pushStyle();
    noStroke();
    fill(COR_FUNDO);
    rect(x, 0, W, height);

    desenharConteudo(x, IMAGE_H + INFO_H + TAB_H + 1);
    desenharImagemProduto(x, 0);
    desenharLinhaImagem(x, IMAGE_H);
    desenharInfoProduto(x, IMAGE_H + 1);
    desenharAbas(x, IMAGE_H + INFO_H + 1);
    popStyle();
  }

  void desenharImagemProduto(float x, float y) {
    fill(#FFFFFF);
    rect(x, y, W, IMAGE_H);

    ArrayList<PImage> imagens = imagensProduto();
    if (imagens != null && imagens.size() > 0) {
      imagemAtual = constrain(imagemAtual, 0, imagens.size() - 1);
      desenharImagemInteira(imagens.get(imagemAtual), x, y, W, IMAGE_H);
    } else {
      fill(#111111, 130);
      textFont(fonteTexto);
      textSize(15);
      textAlign(CENTER, CENTER);
      text("Imagem nao encontrada", x + W/2, y + IMAGE_H/2);
    }

    desenharIcone(iconeSetaEsquerda, x + 45, y + IMAGE_H - 64, 38, 38);
    desenharIcone(iconeSetaDireita, x + W - 45, y + IMAGE_H - 64, 38, 38);
  }

  void desenharLinhaImagem(float x, float y) {
    noStroke();
    fill(#000000);
    rect(x + (W - 475)/2.0f, y, 475, 1);
  }

  void desenharInfoProduto(float x, float y) {
    noStroke();
    fill(#F2F2F2);
    rect(x, y, W, INFO_H);

    if (produto == null) {
      fill(#000000);
      textFont(fonteTexto);
      textSize(15);
      textAlign(LEFT, CENTER);
      text("Selecione um produto", x + 14, y + INFO_H/2);
      return;
    }

    desenharContainerProduto(x, y);

    float nomeX = x + 14;
    float nomeY = y + 25;
    String anoTexto = "(" + anoProdutoPainel(produto) + ")";
    float larguraTitulo = W - 274;
    float tamanhoTitulo = 20;
    fill(#000000);
    textAlign(LEFT, BASELINE);
    textFont(fonteTitulo);
    textSize(tamanhoTitulo);
    while (textWidth(produto.nome) > larguraTitulo && tamanhoTitulo > 12) {
      tamanhoTitulo -= 1;
      textSize(tamanhoTitulo);
    }
    text(produto.nome, nomeX, nomeY);

    float anoX = nomeX + textWidth(produto.nome) + 6;
    textFont(fonteRegular);
    textSize(15);
    float autorY = y + 48;
    if (anoX + textWidth(anoTexto) < x + W - 260) {
      text(anoTexto, anoX, nomeY - 1);
    } else {
      text(anoTexto, nomeX, y + 42);
      autorY = y + 57;
    }

    textFont(fonteLight);
    textSize(15);
    textAlign(LEFT, TOP);
    text(autorProduto(produto), nomeX, autorY, W - 274, 20);
  }

  void desenharContainerProduto(float x, float y) {
    float containerX = x + W - 250;
    float containerY = y + INFO_H - 54;
    float escalaContainer = 0.5f;

    if (iconeContainer != null) {
      clip(round(x), round(y), W, INFO_H);
      image(iconeContainer, containerX, containerY, iconeContainer.width * escalaContainer, iconeContainer.height * escalaContainer);
    } else {
      clip(round(x), round(y), W, INFO_H);
      noStroke();
      fill(COR_AMARELO);
      ellipse(x + W - 125, y + INFO_H, 110, 110);
      rect(x + W - 125, y + 26, 125, INFO_H - 26);
    }

    PImage[] icones = {
      iconeSalvar,
      iconeAutor,
      iconeComparar,
      iconeTipoProducao()
    };

    float[] centrosOriginais = {428, 325, 220, 118};
    float cy = containerY + 58 * escalaContainer;
    for (int i = 0; i < icones.length; i++) {
      float cx = containerX + centrosOriginais[i] * escalaContainer;
      desenharIcone(icones[i], cx, cy, 26, 26);
    }
    noClip();
  }

  void desenharAbas(float x, float y) {
    desenharAba(x, y, "DETALHES DO PRODUTO", detalhesAtivo);
    desenharAba(x + TAB_W, y, "PRODUTOS SALVOS", !detalhesAtivo);
  }

  void desenharAba(float x, float y, String rotulo, boolean ativa) {
    stroke(#000000);
    strokeWeight(1);
    fill(ativa ? COR_AMARELO : COR_ABA_INATIVA);
    rect(x, y, TAB_W, TAB_H);

    fill(ativa ? #000000 : #FFFFFF);
    textFont(fonteBarra);
    textSize(20);
    textAlign(CENTER, CENTER);
    text(rotulo, x + TAB_W/2, y + TAB_H/2 + 1);
  }

  void desenharConteudo(float x, float y) {
    fill(COR_FUNDO);
    noStroke();
    rect(x, y, W, max(0, height - y));

    if (!detalhesAtivo) {
      desenharProdutosSalvos(x, y);
      return;
    }

    float alturaVisivel = max(0, height - y);
    float alturaTotal = alturaTotalDetalhes();
    maxScrollDetalhes = max(0, alturaTotal - alturaVisivel);
    scrollDetalhes = constrain(scrollDetalhes, 0, maxScrollDetalhes);

    clip(round(x), round(y), W, round(alturaVisivel));
    pushMatrix();
    translate(0, -scrollDetalhes);
    float atualY = y;
    atualY = desenharSecao(x, atualY, filtros.DIM_MATERIAL, "MATERIAIS", iconeMaterial, materialAberto, textoMaterial());
    atualY = desenharSecao(x, atualY, filtros.DIM_TECNICAS, "TECNICAS DE CONSTRUCAO", iconeTecnica, tecnicaAberta, textoCondicionantes());
    desenharSecao(x, atualY, filtros.DIM_ESTETICO, "ESTETICO", iconeEstetico, esteticoAberto, textoComposicao());
    popMatrix();
    noClip();

    desenharScrollDetalhes(x, y, alturaVisivel);
  }

  float desenharSecao(float x, float y, String dimensaoId, String titulo, PImage icone, boolean aberta, String texto) {
    float barX = x;
    stroke(#000000);
    strokeWeight(1);
    fill(COR_AMARELO);
    rect(barX, y, BAR_W, BAR_H);

    desenharIcone(icone, barX + 33, y + BAR_H/2, 34, 34);
    fill(#000000);
    textFont(fonteBarra);
    textSize(20);
    textAlign(LEFT, CENTER);
    text(titulo, barX + 64, y + BAR_H/2 + 1);
    desenharIcone(aberta ? iconeClose : iconeMore, barX + BAR_W - 30, y + BAR_H/2, 24, 24);

    if (!aberta) {
      return y + BAR_H;
    }

    float conteudoY = y + BAR_H;
    float altura = alturaConteudo(dimensaoId, texto);
    noStroke();
    fill(COR_FUNDO);
    rect(x, conteudoY, W, altura);
    desenharConteudoSecao(x, conteudoY, dimensaoId, texto);
    return conteudoY + altura;
  }

  void desenharConteudoSecao(float x, float y, String dimensaoId, String texto) {
    float cursorX = x + 84;
    float cursorY = y + 14;
    float maxX = x + W - 20;
    float chipH = 25;

    fill(#FFFFFF);
    textFont(fonteTexto);
    textSize(16);
    textAlign(LEFT, CENTER);
    text("Tags:", x + 18, cursorY + chipH/2 - 1);

    for (TagFiltro tag : tagsProduto(dimensaoId)) {
      float chipW = max(54, textWidth(tag.rotulo) + 18);
      if (cursorX + chipW > maxX) {
        cursorX = x + 84;
        cursorY += chipH + 8;
      }
      noStroke();
      fill(corDimensao(dimensaoId));
      rect(cursorX, cursorY, chipW, chipH, 3);
      fill(dimensaoId.equals(filtros.DIM_TECNICAS) ? #000000 : #FFFFFF);
      textAlign(CENTER, CENTER);
      text(tag.rotulo, cursorX + chipW/2, cursorY + chipH/2 - 1);
      cursorX += chipW + 7;
    }

    if (texto == null || trim(texto).length() == 0) {
      return;
    }

    float textoY = cursorY + chipH + 26;
    fill(#FFFFFF);
    textFont(fonteTexto);
    textSize(16);
    textAlign(LEFT, TOP);
    desenharTextoQuebrado(texto, x + 18, textoY, W - 36, 16, -1);
  }

  float alturaConteudo(String dimensaoId, String texto) {
    int linhasChips = max(1, linhasChips(tagsProduto(dimensaoId), W - 104));
    int linhasTexto = 0;
    if (texto != null && trim(texto).length() > 0) {
      linhasTexto = quebrarTexto(texto, W - 36, fonteTexto, 16).size();
    }
    return 24 + linhasChips * 33 + (linhasTexto > 0 ? 24 + linhasTexto * 18 : 12);
  }

  float alturaTotalDetalhes() {
    float total = BAR_H;
    if (materialAberto) {
      total += alturaConteudo(filtros.DIM_MATERIAL, textoMaterial());
    }
    total += BAR_H;
    if (tecnicaAberta) {
      total += alturaConteudo(filtros.DIM_TECNICAS, textoCondicionantes());
    }
    total += BAR_H;
    if (esteticoAberto) {
      total += alturaConteudo(filtros.DIM_ESTETICO, textoComposicao());
    }
    return total;
  }

  void desenharScrollDetalhes(float x, float y, float alturaVisivel) {
    if (maxScrollDetalhes <= 0 || alturaVisivel <= 0) {
      return;
    }

    float trilhoX = x + W - 6;
    float trilhoY = y + 6;
    float trilhoH = alturaVisivel - 12;
    float indicadorH = max(34, trilhoH * alturaVisivel / (alturaVisivel + maxScrollDetalhes));
    float indicadorY = trilhoY + map(scrollDetalhes, 0, maxScrollDetalhes, 0, trilhoH - indicadorH);

    noStroke();
    fill(#FFFFFF, 45);
    rect(trilhoX, trilhoY, 3, trilhoH, 2);
    fill(COR_AMARELO);
    rect(trilhoX - 1, indicadorY, 5, indicadorH, 2);
  }

  int linhasChips(ArrayList<TagFiltro> tags, float larguraDisponivel) {
    if (tags.size() == 0) {
      return 1;
    }
    textFont(fonteTexto);
    textSize(16);
    int linhas = 1;
    float usado = 0;
    for (TagFiltro tag : tags) {
      float chipW = max(54, textWidth(tag.rotulo) + 18) + 7;
      if (usado + chipW > larguraDisponivel) {
        linhas++;
        usado = 0;
      }
      usado += chipW;
    }
    return linhas;
  }

  ArrayList<TagFiltro> tagsProduto(String dimensaoId) {
    if (produto == null) {
      return new ArrayList<TagFiltro>();
    }
    return produto.tagsDaDimensao(dimensaoId);
  }

  boolean mousePressed(float mx, float my) {
    float x = painelX();
    if (mx < x || mx > x + W || my < 0 || my > height) {
      return false;
    }

    if (clicouSalvarProduto(mx, my)) {
      salvarProdutoAtual();
      return true;
    }

    if (clicouSeta(mx, my, true)) {
      trocarImagem(-1);
      return true;
    }
    if (clicouSeta(mx, my, false)) {
      trocarImagem(1);
      return true;
    }

    float abasY = IMAGE_H + INFO_H + 1;
    if (my >= abasY && my <= abasY + TAB_H) {
      if (mx >= x && mx <= x + TAB_W) {
        detalhesAtivo = true;
        return true;
      }
      if (mx >= x + TAB_W && mx <= x + W) {
        detalhesAtivo = false;
        buscaSalvosAtiva = false;
        return true;
      }
    }

    if (!detalhesAtivo) {
      return mousePressedSalvos(mx, my);
    }

    float conteudoY = IMAGE_H + INFO_H + TAB_H + 1;
    if (detalhesAtivo && my >= conteudoY) {
      clicarSecoes(mx, my);
    }
    return true;
  }

  void clicarSecoes(float mx, float my) {
    float x = painelX();
    float y = IMAGE_H + INFO_H + TAB_H + 1 - scrollDetalhes;

    if (clicouBarraSecao(mx, my, y)) {
      materialAberto = !materialAberto;
      return;
    }
    y += BAR_H + (materialAberto ? alturaConteudo(filtros.DIM_MATERIAL, textoMaterial()) : 0);

    if (clicouBarraSecao(mx, my, y)) {
      tecnicaAberta = !tecnicaAberta;
      return;
    }
    y += BAR_H + (tecnicaAberta ? alturaConteudo(filtros.DIM_TECNICAS, textoCondicionantes()) : 0);

    if (clicouBarraSecao(mx, my, y)) {
      esteticoAberto = !esteticoAberto;
    }
  }

  boolean mouseWheel(processing.event.MouseEvent evento) {
    float y = IMAGE_H + INFO_H + TAB_H + 1;
    if (mxForaPainel(mouseX, mouseY) || mouseY < y) {
      return false;
    }
    if (!detalhesAtivo) {
      if (maxScrollSalvos <= 0) {
        return false;
      }
      scrollSalvos = constrain(scrollSalvos + evento.getCount() * 32, 0, maxScrollSalvos);
      return true;
    }
    if (maxScrollDetalhes <= 0) {
      return false;
    }
    scrollDetalhes = constrain(scrollDetalhes + evento.getCount() * 32, 0, maxScrollDetalhes);
    return true;
  }

  boolean mxForaPainel(float mx, float my) {
    float x = painelX();
    return mx < x || mx > x + W || my < 0 || my > height;
  }

  boolean clicouBarraSecao(float mx, float my, float y) {
    float x = painelX();
    return mx >= x && mx <= x + BAR_W && my >= y && my <= y + BAR_H;
  }

  boolean keyPressed(char tecla, int codigo) {
    if (!buscaSalvosAtiva) {
      return false;
    }

    if (tecla == BACKSPACE) {
      if (buscaSalvos.length() > 0) {
        buscaSalvos = buscaSalvos.substring(0, buscaSalvos.length() - 1);
        scrollSalvos = 0;
      }
      return true;
    }

    if (tecla == DELETE) {
      buscaSalvos = "";
      scrollSalvos = 0;
      return true;
    }

    if (tecla == ENTER || tecla == RETURN) {
      buscaSalvosAtiva = false;
      return true;
    }

    if (tecla >= 32 && tecla != CODED) {
      buscaSalvos += tecla;
      scrollSalvos = 0;
      return true;
    }

    return true;
  }

  boolean clicouSeta(float mx, float my, boolean esquerda) {
    float x = painelX();
    float cx = esquerda ? x + 45 : x + W - 45;
    float cy = IMAGE_H - 64;
    return dist(mx, my, cx, cy) <= 30;
  }

  boolean clicouSalvarProduto(float mx, float my) {
    if (produto == null) {
      return false;
    }
    float[] centro = centroIconeContainer(0);
    return dist(mx, my, centro[0], centro[1]) <= 24;
  }

  float[] centroIconeContainer(int indice) {
    float x = painelX();
    float y = IMAGE_H + 1;
    float containerX = x + W - 250;
    float containerY = y + INFO_H - 54;
    float escalaContainer = 0.5f;
    float[] centrosOriginais = {428, 325, 220, 118};
    return new float[] {
      containerX + centrosOriginais[indice] * escalaContainer,
      containerY + 58 * escalaContainer
    };
  }

  void salvarProdutoAtual() {
    if (produto == null || produtoJaSalvo(produto)) {
      return;
    }
    produtosSalvos.add(produto);
  }

  boolean produtoJaSalvo(ProdutoFiltrado alvo) {
    for (ProdutoFiltrado salvo : produtosSalvos) {
      if (salvo.id.equals(alvo.id) && salvo.origem.equals(alvo.origem)) {
        return true;
      }
    }
    return false;
  }

  void desenharProdutosSalvos(float x, float y) {
    float topoY = y + 18;
    float buscaX = x + 22;
    float buscaW = 240;
    float buscaH = 20;

    noStroke();
    fill(#D9D9D9);
    rect(buscaX, topoY, buscaW, buscaH, buscaH/2);
    fill(buscaSalvos.length() == 0 ? color(80) : #000000);
    textFont(fonteTexto);
    textSize(12);
    textAlign(LEFT, CENTER);
    text(buscaSalvos.length() == 0 ? "Digite o nome, tipo ou ano" : buscaSalvos, buscaX + 13, topoY + buscaH/2 - 1);

    float botaoX = x + 292;
    float botaoW = 66;
    fill(#D9D9D9);
    rect(botaoX, topoY, botaoW, buscaH, buscaH/2);
    fill(#000000);
    textAlign(CENTER, CENTER);
    text(rotuloOrdenacaoSalvos(), botaoX + botaoW/2, topoY + buscaH/2 - 1);

    ArrayList<ProdutoFiltrado> itens = produtosSalvosFiltrados();
    float gridY = y + 58;
    float alturaVisivel = max(0, height - gridY);
    int colunas = 3;
    float cardW = 92;
    float cardH = 122;
    float gapX = 33;
    float gapY = 32;
    float gridX = x + 22;
    int linhas = ceil(itens.size() / float(colunas));
    float alturaTotal = linhas * cardH + max(0, linhas - 1) * gapY;
    maxScrollSalvos = max(0, alturaTotal - alturaVisivel);
    scrollSalvos = constrain(scrollSalvos, 0, maxScrollSalvos);

    clip(round(x), round(gridY), W, round(alturaVisivel));
    pushMatrix();
    translate(0, -scrollSalvos);
    for (int i = 0; i < itens.size(); i++) {
      int col = i % colunas;
      int row = i / colunas;
      float cx = gridX + col * (cardW + gapX);
      float cy = gridY + row * (cardH + gapY);
      desenharCardSalvo(itens.get(i), cx, cy, cardW, cardH);
    }
    popMatrix();
    noClip();

    desenharScrollSalvos(x, gridY, alturaVisivel);
  }

  void desenharCardSalvo(ProdutoFiltrado item, float x, float y, float w, float h) {
    color corOrigem = item.origem.equals("brasileiro") ? COR_AMARELO : #FF00FB;
    noStroke();
    fill(#8D8D8D);
    rect(x, y, w, 88, 7);
    fill(#FFFFFF);
    rect(x + 5, y + 5, w - 10, 74, 4);

    PImage img = primeiraImagemProduto(item);
    if (img != null) {
      desenharImagemInteiraSemClip(img, x + 8, y + 8, w - 16, 68);
    }

    fill(corOrigem);
    rect(x + 5, y + 72, w - 10, 14, 0, 0, 6, 6);

    fill(#000000);
    rect(x, y + 96, w, 19, 10);
    fill(#FFFFFF);
    textFont(fonteTexto);
    textSize(tamanhoTextoAjustado(item.nome, fonteTexto, 11, 8, w - 10));
    textAlign(CENTER, CENTER);
    text(item.nome, x + w/2, y + 105);
  }

  void desenharScrollSalvos(float x, float y, float alturaVisivel) {
    if (maxScrollSalvos <= 0 || alturaVisivel <= 0) {
      return;
    }
    float trilhoX = x + W - 6;
    float trilhoY = y + 4;
    float trilhoH = alturaVisivel - 8;
    float indicadorH = max(34, trilhoH * alturaVisivel / (alturaVisivel + maxScrollSalvos));
    float indicadorY = trilhoY + map(scrollSalvos, 0, maxScrollSalvos, 0, trilhoH - indicadorH);
    noStroke();
    fill(#FFFFFF, 45);
    rect(trilhoX, trilhoY, 3, trilhoH, 2);
    fill(COR_AMARELO);
    rect(trilhoX - 1, indicadorY, 5, indicadorH, 2);
  }

  boolean mousePressedSalvos(float mx, float my) {
    float x = painelX();
    float y = IMAGE_H + INFO_H + TAB_H + 1;
    float topoY = y + 18;

    if (my >= topoY && my <= topoY + 20 && mx >= x + 22 && mx <= x + 262) {
      buscaSalvosAtiva = true;
      return true;
    }
    buscaSalvosAtiva = false;

    if (my >= topoY && my <= topoY + 20 && mx >= x + 292 && mx <= x + 358) {
      modoOrdenacaoSalvos = (modoOrdenacaoSalvos + 1) % 3;
      scrollSalvos = 0;
      return true;
    }

    ProdutoFiltrado clicado = produtoSalvoSobMouse(mx, my);
    if (clicado != null) {
      selecionar(clicado);
      detalhesAtivo = true;
      return true;
    }
    return true;
  }

  ProdutoFiltrado produtoSalvoSobMouse(float mx, float my) {
    float x = painelX();
    float y = IMAGE_H + INFO_H + TAB_H + 1;
    float gridY = y + 58;
    if (my < gridY) {
      return null;
    }

    ArrayList<ProdutoFiltrado> itens = produtosSalvosFiltrados();
    float cardW = 92;
    float cardH = 122;
    float gapX = 33;
    float gapY = 32;
    float gridX = x + 22;
    float localY = my - gridY + scrollSalvos;
    for (int i = 0; i < itens.size(); i++) {
      int col = i % 3;
      int row = i / 3;
      float cx = gridX + col * (cardW + gapX);
      float cy = row * (cardH + gapY);
      if (mx >= cx && mx <= cx + cardW && localY >= cy && localY <= cy + cardH) {
        return itens.get(i);
      }
    }
    return null;
  }

  ArrayList<ProdutoFiltrado> produtosSalvosFiltrados() {
    ArrayList<ProdutoFiltrado> resultado = new ArrayList<ProdutoFiltrado>();
    String busca = filtros.normalizarBusca(buscaSalvos);
    for (ProdutoFiltrado item : produtosSalvos) {
      String alvo = filtros.normalizarBusca(item.nome + " " + tipoProduto(item) + " " + anoProdutoPainel(item));
      if (busca.length() == 0 || alvo.indexOf(busca) >= 0) {
        resultado.add(item);
      }
    }

    Collections.sort(resultado, new Comparator<ProdutoFiltrado>() {
      public int compare(ProdutoFiltrado a, ProdutoFiltrado b) {
        if (modoOrdenacaoSalvos == 1) {
          return anoProdutoInt(a) - anoProdutoInt(b);
        }
        if (modoOrdenacaoSalvos == 2) {
          int cmpTipo = tipoProduto(a).compareToIgnoreCase(tipoProduto(b));
          if (cmpTipo != 0) {
            return cmpTipo;
          }
        }
        return a.nome.compareToIgnoreCase(b.nome);
      }
    });

    return resultado;
  }

  String rotuloOrdenacaoSalvos() {
    if (modoOrdenacaoSalvos == 1) {
      return "ANO";
    }
    if (modoOrdenacaoSalvos == 2) {
      return "TIPO";
    }
    return "A-Z";
  }

  void trocarImagem(int direcao) {
    ArrayList<PImage> imagens = imagensProduto();
    if (imagens == null || imagens.size() <= 1) {
      return;
    }
    imagemAtual = (imagemAtual + direcao + imagens.size()) % imagens.size();
  }

  ArrayList<PImage> imagensProduto() {
    return imagensProduto(produto);
  }

  ArrayList<PImage> imagensProduto(ProdutoFiltrado item) {
    if (item == null) {
      return null;
    }
    int id = idProduto(item);
    if (id < 0) {
      return null;
    }
    HashMap<Integer, ArrayList<PImage>> banco = item.origem.equals("brasileiro") ? imagensNacionais : imagensInternacionais;
    if (banco == null || !banco.containsKey(id)) {
      return null;
    }
    return banco.get(id);
  }

  PImage primeiraImagemProduto(ProdutoFiltrado item) {
    ArrayList<PImage> imagens = imagensProduto(item);
    if (imagens == null || imagens.size() == 0) {
      return null;
    }
    return imagens.get(0);
  }

  int idProduto() {
    return idProduto(produto);
  }

  int idProduto(ProdutoFiltrado item) {
    try {
      return int(item.id);
    } catch (Exception erro) {
      return -1;
    }
  }

  String autorProduto(ProdutoFiltrado produto) {
    return valorIndice(produto, 6);
  }

  String anoProdutoPainel(ProdutoFiltrado produto) {
    String texto = valorIndice(produto, 4);
    String[] partes = match(texto, "(18|19|20)\\d\\d");
    if (partes != null && partes.length > 0) {
      return partes[0];
    }
    return texto;
  }

  int anoProdutoInt(ProdutoFiltrado produto) {
    String ano = anoProdutoPainel(produto);
    try {
      return int(ano);
    } catch (Exception erro) {
      return 0;
    }
  }

  String tipoProduto(ProdutoFiltrado produto) {
    if (produto == null) {
      return "";
    }
    ArrayList<TagFiltro> tipos = produto.tagsDaDimensao(filtros.DIM_TIPO_OBRA);
    if (tipos.size() == 0) {
      return "";
    }
    return tipos.get(0).rotulo;
  }

  String textoMaterial() {
    if (produto == null) {
      return "";
    }
    return valorIndice(produto, 3);
  }

  String textoCondicionantes() {
    if (produto == null || !produto.origem.equals("brasileiro")) {
      return "";
    }
    return valorIndice(produto, 7);
  }

  String textoComposicao() {
    if (produto == null) {
      return "";
    }
    return produto.origem.equals("brasileiro") ? valorIndice(produto, 9) : valorIndice(produto, 8);
  }

  String textoProducao() {
    if (produto == null) {
      return "";
    }
    return produto.origem.equals("brasileiro") ? valorIndice(produto, 8) : valorIndice(produto, 7);
  }

  String valorIndice(ProdutoFiltrado produto, int indice) {
    if (produto == null || produto.linhaOriginal == null) {
      return "";
    }
    try {
      String valor = produto.linhaOriginal.getString(indice);
      if (valor == null) {
        return "";
      }
      return trim(valor);
    } catch (Exception erro) {
      return "";
    }
  }

  PImage iconeTipoProducao() {
    String texto = textoProducao().toLowerCase();
    if (texto.indexOf("artesanal") >= 0) {
      return iconeArtesanal;
    }
    if (texto.indexOf("assinado") >= 0) {
      return iconeDesignAssinado;
    }
    if (texto.indexOf("industrial") >= 0 || texto.indexOf("massa") >= 0 || texto.indexOf("seri") >= 0) {
      return iconeIndustrial;
    }
    return iconeDesignAssinado;
  }

  color corDimensao(String dimensaoId) {
    if (dimensaoId.equals(filtros.DIM_MATERIAL)) {
      return COR_MATERIAL;
    }
    if (dimensaoId.equals(filtros.DIM_TECNICAS)) {
      return COR_TECNICA;
    }
    return COR_ESTETICO;
  }

  float painelX() {
    return max(0, min(255 + 1166, width - W));
  }

  void desenharImagemInteira(PImage img, float x, float y, float w, float h) {
    if (img == null || img.width == 0 || img.height == 0) {
      return;
    }
    clip(round(x), round(y), round(w), round(h));
    desenharImagemInteiraSemClip(img, x, y, w, h);
    noClip();
  }

  void desenharImagemInteiraSemClip(PImage img, float x, float y, float w, float h) {
    if (img == null || img.width == 0 || img.height == 0) {
      return;
    }
    float escala = min(w / img.width, h / img.height);
    float iw = img.width * escala;
    float ih = img.height * escala;
    image(img, x + (w - iw)/2, y + (h - ih)/2, iw, ih);
  }

  void desenharIcone(PImage img, float cx, float cy, float w, float h) {
    if (img == null) {
      return;
    }
    float escala = min(w / img.width, h / img.height);
    float iw = img.width * escala;
    float ih = img.height * escala;
    image(img, cx - iw/2, cy - ih/2, iw, ih);
  }

  void desenharTextoQuebrado(String texto, float x, float y, float largura, float tamanho, int maxLinhas) {
    ArrayList<String> linhas = quebrarTexto(texto, largura, fonteTexto, tamanho);
    textFont(fonteTexto);
    textSize(tamanho);
    int limite = maxLinhas < 0 ? linhas.size() : min(linhas.size(), maxLinhas);
    for (int i = 0; i < limite; i++) {
      text(linhas.get(i), x, y + i * 18);
    }
  }

  ArrayList<String> quebrarTexto(String texto, float largura, PFont fonte, float tamanho) {
    ArrayList<String> linhas = new ArrayList<String>();
    if (texto == null) {
      return linhas;
    }

    textFont(fonte);
    textSize(tamanho);
    String[] palavras = splitTokens(texto, " \n\r\t");
    String linha = "";
    for (String palavra : palavras) {
      String tentativa = linha.length() == 0 ? palavra : linha + " " + palavra;
      if (textWidth(tentativa) <= largura || linha.length() == 0) {
        linha = tentativa;
      } else {
        linhas.add(linha);
        linha = palavra;
      }
    }
    if (linha.length() > 0) {
      linhas.add(linha);
    }
    return linhas;
  }

  float tamanhoTextoAjustado(String texto, PFont fonte, float tamanhoMaximo, float tamanhoMinimo, float larguraMaxima) {
    float tamanho = tamanhoMaximo;
    textFont(fonte);
    textSize(tamanho);
    while (textWidth(texto) > larguraMaxima && tamanho > tamanhoMinimo) {
      tamanho -= 1;
      textSize(tamanho);
    }
    return tamanho;
  }
}

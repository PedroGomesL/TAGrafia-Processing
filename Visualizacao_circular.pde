VisualizacaoCircular visualizacaoCircular;

void inicializarVisualizacaoCircular() {
  visualizacaoCircular = new VisualizacaoCircular(sistemaFiltros);
  visualizacaoCircular.carregarAssets();
}

void desenharVisualizacaoCircular() {
  if (visualizacaoCircular != null) {
    visualizacaoCircular.desenhar();
  }
}

boolean visualizacaoCircularMousePressed() {
  return visualizacaoCircular != null && visualizacaoCircular.mousePressed(mouseX, mouseY);
}

boolean visualizacaoCircularMouseDragged() {
  return visualizacaoCircular != null && visualizacaoCircular.mouseDragged(mouseX, mouseY);
}

void visualizacaoCircularMouseReleased() {
  if (visualizacaoCircular != null) {
    visualizacaoCircular.mouseReleased();
  }
}

class VisualizacaoCircular {
  SistemaFiltros filtros;

  final int X = 255;
  final int Y = 0;
  final int W = 1166;
  final int H = 1080;
  final int CIRCLE_SIZE = 700;
  final int TIMELINE_W = 1158;
  final int TIMELINE_H = 100;
  final int TIMELINE_HANDLE_W = 7;
  final int TIMELINE_HANDLE_H = 70;
  final int ANO_MIN = 1880;
  final int ANO_MAX = 2010;

  final color COR_MATERIAL = #3E4AD3;
  final color COR_TECNICA = #4AD33E;
  final color COR_ESTETICO = #D33E4A;
  final color COR_TIPO_PRODUTO = #FFCB00;
  final color COR_NACIONAL = #FFCB00;
  final color COR_INTERNACIONAL = #FF00FB;

  PFont fonteProduto;
  PFont fonteAno;
  PFont fonteFiltro;

  boolean temaEscuro = true;
  int anoInicio = 1880;
  int anoFim = 2010;
  int handleArrastado = 0;
  TagFiltro tagEmDestaque = null;

  VisualizacaoCircular(SistemaFiltros filtros) {
    this.filtros = filtros;
  }

  void carregarAssets() {
    fonteProduto = createFont("Afacad Flux Bold", 22, true);
    fonteAno = createFont("Afacad Flux SemiBold", 30, true);
    fonteFiltro = createFont("Roboto Condensed", 13, true);
  }

  void desenhar() {
    pushStyle();
    desenharFundo();
    ArrayList<TagFiltro> tags = tagsSelecionadas();
    ArrayList<ProdutoVisual> produtos = produtosVisiveis(tags);
    desenharCirculo(tags, produtos);
    desenharTimeline();
    popStyle();
  }

  void desenharFundo() {
    noStroke();
    fill(temaEscuro ? #000000 : #FFFFFF);
    rect(X, Y, W, H);
  }

  void desenharCirculo(ArrayList<TagFiltro> tags, ArrayList<ProdutoVisual> produtos) {
    float cx = X + 350;
    float cy = Y + 520;
    float raio = CIRCLE_SIZE/2.0f;

    noFill();
    stroke(corCirculo());
    strokeWeight(13);
    desenharCirculoTracejado(cx, cy, raio, 38);

    HashMap<String, PVector> posicoesTags = new HashMap<String, PVector>();
    for (TagFiltro tag : tags) {
      PVector pos = posicaoTag(tag, cx, cy, raio * 0.72f);
      posicoesTags.put(tag.chave(), pos);
      desenharBolinhaTag(tag, pos);
    }

    desenharProdutos(produtos, posicoesTags, cx + raio - 8, cy);

    if (tagEmDestaque != null) {
      desenharNomeTagDestaque(tagEmDestaque, cx, cy + raio + 28);
    }

    if (tags.size() == 0) {
      desenharMensagemVazia(cx, cy);
    }
  }

  void desenharCirculoTracejado(float cx, float cy, float raio, int segmentos) {
    float passo = TWO_PI / segmentos;
    for (int i = 0; i < segmentos; i++) {
      float a1 = i * passo;
      float a2 = a1 + passo * 0.42f;
      arc(cx, cy, raio * 2, raio * 2, a1, a2);
    }
  }

  void desenharBolinhaTag(TagFiltro tag, PVector pos) {
    boolean ativa = tagEmDestaque == null || tagEmDestaque.chave().equals(tag.chave());
    noStroke();
    fill(corTag(tag), ativa ? 255 : 75);
    ellipse(pos.x, pos.y, ativa ? 11 : 8, ativa ? 11 : 8);
  }

  void desenharProdutos(ArrayList<ProdutoVisual> produtos, HashMap<String, PVector> posicoesTags, float saidaX, float centroY) {
    int limite = min(produtos.size(), 14);
    float yInicial = centroY - limite * 32;

    for (int i = 0; i < limite; i++) {
      ProdutoVisual produto = produtos.get(i);
      float cardW = constrain(120 + produto.peso * 38, 130, 285);
      float cardH = 42 + min(2, produto.peso - 1) * 13;
      float cardX = saidaX + 18;
      float cardY = yInicial + i * 64;

      if (i % 3 == 0) {
        cardY -= 18;
      } else if (i % 3 == 2) {
        cardY += 14;
      }

      desenharConexoes(produto, posicoesTags, cardX, cardY + cardH/2);
      desenharCardProduto(produto, cardX, cardY, cardW, cardH, i);
    }
  }

  void desenharConexoes(ProdutoVisual produto, HashMap<String, PVector> posicoesTags, float alvoX, float alvoY) {
    for (TagFiltro tag : produto.tags) {
      PVector origem = posicoesTags.get(tag.chave());
      if (origem == null) {
        continue;
      }

      boolean ativa = tagEmDestaque == null || tagEmDestaque.chave().equals(tag.chave());
      stroke(corTag(tag), ativa ? 230 : 55);
      strokeWeight(ativa ? 1.8f : 0.8f);
      line(origem.x, origem.y, alvoX, alvoY);
    }
  }

  void desenharCardProduto(ProdutoVisual produto, float x, float y, float w, float h, int indice) {
    pushMatrix();
    float rotacao = (indice % 4 == 0) ? radians(-13) : ((indice % 4 == 3) ? radians(8) : 0);
    translate(x + w/2, y + h/2);
    rotate(rotacao);

    noStroke();
    fill(produto.origem.equals("brasileiro") ? COR_NACIONAL : COR_INTERNACIONAL);
    rect(-w/2, -h/2, w, h);

    fill(#000000);
    textFont(fonteProduto);
    textSize(tamanhoTextoProduto(produto.nome, w - 22));
    textAlign(CENTER, CENTER);
    text(produto.nome, -w/2 + 9, -h/2, w - 18, h);
    popMatrix();
  }

  void desenharNomeTagDestaque(TagFiltro tag, float cx, float y) {
    fill(temaEscuro ? #FFFFFF : #111111);
    textFont(fonteFiltro);
    textSize(13);
    textAlign(CENTER, TOP);
    text(tag.rotulo, cx, y);
  }

  void desenharMensagemVazia(float cx, float cy) {
    fill(temaEscuro ? #FFFFFF : #111111, 170);
    textFont(fonteFiltro);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Selecione tags no filtro para visualizar os produtos", cx, cy);
  }

  void desenharTimeline() {
    float tx = X + 4;
    float ty = Y + H - TIMELINE_H;

    noStroke();
    fill(temaEscuro ? #505050 : #D7D7D7);
    rect(tx, ty + 40, TIMELINE_W, 60);

    float xInicio = xAno(anoInicio);
    float xFim = xAno(anoFim);
    fill(#FFCB00);
    rect(xInicio + TIMELINE_HANDLE_W, ty + 40, max(0, xFim - xInicio - TIMELINE_HANDLE_W), 60);

    stroke(temaEscuro ? #202020 : #B08A00);
    strokeWeight(3);
    for (float hx = xInicio + 20; hx < xFim - 8; hx += 18) {
      line(hx, ty + 100, hx + 58, ty + 40);
    }

    noStroke();
    fill(#FFFFFF);
    rect(xInicio, ty + 10, TIMELINE_HANDLE_W, TIMELINE_HANDLE_H);
    rect(xFim, ty + 10, TIMELINE_HANDLE_W, TIMELINE_HANDLE_H);

    desenharAnoTimeline(anoInicio, xInicio, ty);
    desenharAnoTimeline(anoFim, xFim, ty);
  }

  void desenharAnoTimeline(int ano, float x, float ty) {
    fill(temaEscuro ? #FFFFFF : #111111);
    textFont(fonteAno);
    textSize(30);
    textAlign(CENTER, BOTTOM);

    float yTexto = ty + 8;
    if (x < X + 48) {
      x += 40;
    }
    if (x > X + W - 48) {
      x -= 40;
    }
    text(str(ano), x, yTexto);
  }

  boolean mousePressed(float mx, float my) {
    if (!dentro(mx, my)) {
      return false;
    }

    if (clicouHandleTempo(mx, my)) {
      return true;
    }

    TagFiltro tag = tagSobMouse(mx, my);
    if (tag != null) {
      if (tagEmDestaque != null && tagEmDestaque.chave().equals(tag.chave())) {
        tagEmDestaque = null;
      } else {
        tagEmDestaque = tag;
      }
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
    float ty = Y + H - TIMELINE_H;
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

  TagFiltro tagSobMouse(float mx, float my) {
    float cx = X + 350;
    float cy = Y + 520;
    float raio = CIRCLE_SIZE/2.0f * 0.72f;

    for (TagFiltro tag : tagsSelecionadas()) {
      PVector pos = posicaoTag(tag, cx, cy, raio);
      if (dist(mx, my, pos.x, pos.y) <= 13) {
        return tag;
      }
    }
    return null;
  }

  boolean dentro(float mx, float my) {
    return mx >= X && mx <= X + W && my >= Y && my <= Y + H;
  }

  ArrayList<TagFiltro> tagsSelecionadas() {
    ArrayList<TagFiltro> tags = new ArrayList<TagFiltro>();
    for (String chave : filtros.tagsSelecionadas) {
      TagFiltro tag = filtros.tagsPorChave.get(chave);
      if (tag != null) {
        tags.add(tag);
      }
    }
    return tags;
  }

  ArrayList<ProdutoVisual> produtosVisiveis(ArrayList<TagFiltro> tags) {
    ArrayList<ProdutoVisual> resultado = new ArrayList<ProdutoVisual>();
    if (tags.size() == 0) {
      return resultado;
    }

    for (ProdutoFiltrado produto : filtros.produtos) {
      int ano = anoProduto(produto);
      if (ano < anoInicio || ano > anoFim) {
        continue;
      }

      ArrayList<TagFiltro> tagsDoProduto = new ArrayList<TagFiltro>();
      for (TagFiltro tag : tags) {
        if (produto.possuiTag(tag) && (tagEmDestaque == null || tagEmDestaque.chave().equals(tag.chave()))) {
          tagsDoProduto.add(tag);
        }
      }

      if (tagsDoProduto.size() > 0) {
        resultado.add(new ProdutoVisual(produto.nome, produto.origem, ano, tagsDoProduto));
      }
    }

    Collections.sort(resultado, new Comparator<ProdutoVisual>() {
      public int compare(ProdutoVisual a, ProdutoVisual b) {
        if (b.peso != a.peso) {
          return b.peso - a.peso;
        }
        return a.ano - b.ano;
      }
    });

    return resultado;
  }

  int anoProduto(ProdutoFiltrado produto) {
    String texto = "";
    try {
      texto = produto.linhaOriginal.getString("Datação");
    } catch (Exception erro) {
      try {
        texto = produto.linhaOriginal.getString(4);
      } catch (Exception outroErro) {
        texto = "";
      }
    }

    String[] partes = match(texto, "(18|19|20)\\d\\d");
    if (partes != null && partes.length > 0) {
      return int(partes[0]);
    }
    return ANO_MIN;
  }

  PVector posicaoTag(TagFiltro tag, float cx, float cy, float raio) {
    int h = abs(tag.chave().hashCode());
    float angulo = map(h % 10000, 0, 9999, PI * 0.65f, PI * 1.75f);
    float r = raio * map((h / 10000) % 100, 0, 99, 0.35f, 1.0f);
    return new PVector(cx + cos(angulo) * r, cy + sin(angulo) * r);
  }

  float xAno(int ano) {
    float tx = X + 4;
    return tx + map(ano, ANO_MIN, ANO_MAX, 0, TIMELINE_W - TIMELINE_HANDLE_W);
  }

  int anoPorX(float x) {
    float tx = X + 4;
    int ano = round(map(constrain(x, tx, tx + TIMELINE_W), tx, tx + TIMELINE_W, ANO_MIN, ANO_MAX) / 10.0f) * 10;
    return constrain(ano, ANO_MIN, ANO_MAX);
  }

  color corTag(TagFiltro tag) {
    if (tag.dimensao.id.equals(filtros.DIM_MATERIAL)) {
      return COR_MATERIAL;
    }
    if (tag.dimensao.id.equals(filtros.DIM_TECNICAS)) {
      return COR_TECNICA;
    }
    if (tag.dimensao.id.equals(filtros.DIM_ESTETICO)) {
      return COR_ESTETICO;
    }
    return COR_TIPO_PRODUTO;
  }

  color corCirculo() {
    return temaEscuro ? #FFFFFF : #111111;
  }

  float tamanhoTextoProduto(String texto, float largura) {
    float tamanho = 22;
    textFont(fonteProduto);
    textSize(tamanho);
    while (textWidth(texto) > largura && tamanho > 12) {
      tamanho -= 1;
      textSize(tamanho);
    }
    return tamanho;
  }
}

class ProdutoVisual {
  String nome;
  String origem;
  int ano;
  int peso;
  ArrayList<TagFiltro> tags;

  ProdutoVisual(String nome, String origem, int ano, ArrayList<TagFiltro> tags) {
    this.nome = nome;
    this.origem = origem;
    this.ano = ano;
    this.tags = tags;
    this.peso = tags.size();
  }
}

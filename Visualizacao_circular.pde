import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;

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

ArrayList<ProdutoFiltrado> produtosExibidosNaVisualizacaoCircular() {
  if (visualizacaoCircular == null) {
    return sistemaFiltros.produtosVisiveisParaVisualizacoes();
  }
  return visualizacaoCircular.produtosOriginaisExibidos();
}

class VisualizacaoCircular {
  SistemaFiltros filtros;

  final int X = 255;
  final int Y = 0;
  final int CIRCLE_SIZE = 700;
  final int SLOTS_CIRCULO = 38;
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

  int anoInicio = 1880;
  int anoFim = 2010;
  int handleArrastado = 0;
  TagFiltro tagEmDestaque = null;
  ArrayList<AreaProdutoVisual> areasProdutos = new ArrayList<AreaProdutoVisual>();

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
    ArrayList<TagFiltro> tagsAtivas = tagsSelecionadas();
    ArrayList<TagFiltro> tagsTipoProduto = tagsDaDimensao(tagsAtivas, filtros.DIM_TIPO_OBRA);
    ArrayList<TagFiltro> tagsVisuais = tagsParaVisualizacao(tagsAtivas);
    ArrayList<ProdutoVisual> produtos = produtosExibidos(tagsVisuais, tagsTipoProduto);
    desenharCirculo(tagsVisuais, produtos);
    desenharTimeline();
    popStyle();
  }

  void desenharFundo() {
    noStroke();
    fill(temaCorFundoVisualPrototipo());
    rect(X, Y, larguraVisual(), alturaVisual());
  }

  void desenharCirculo(ArrayList<TagFiltro> tags, ArrayList<ProdutoVisual> produtos) {
    atualizarDestaque(tags);

    float cx = centroCirculoX();
    float cy = centroCirculoY();
    float raio = raioCirculo();

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

    desenharProdutos(produtos, posicoesTags, cx, cy, raio);

    if (tagEmDestaque != null) {
      desenharNomeTagDestaque(tagEmDestaque, cx, cy + raio + 28);
    }

    if (tags.size() == 0) {
      desenharMensagemVazia(cx, cy);
    }
  }

  void atualizarDestaque(ArrayList<TagFiltro> tags) {
    if (tagEmDestaque == null) {
      return;
    }

    for (TagFiltro tag : tags) {
      if (tag.chave().equals(tagEmDestaque.chave())) {
        return;
      }
    }

    tagEmDestaque = null;
  }

  void desenharCirculoTracejado(float cx, float cy, float raio, int segmentos) {
    float passo = TWO_PI / segmentos;
    for (int i = 0; i < segmentos; i++) {
      float centroSegmento = -HALF_PI + i * passo;
      float a1 = centroSegmento - passo * 0.21f;
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

  void desenharProdutos(ArrayList<ProdutoVisual> produtos, HashMap<String, PVector> posicoesTags, float cx, float cy, float raio) {
    int slot = 0;
    areasProdutos.clear();
    for (int i = 0; i < produtos.size() && slot < SLOTS_CIRCULO; i++) {
      ProdutoVisual produto = produtos.get(i);
      int segmentos = segmentosProduto(produto);
      if (slot + segmentos > SLOTS_CIRCULO) {
        segmentos = SLOTS_CIRCULO - slot;
      }

      float angulo = anguloCentroSlots(slot, segmentos);
      float cardW = larguraCardProduto(produto.nome);
      float cardH = max(38, larguraSlot(raio) * segmentos * 0.92f);
      float distancia = raio + cardW/2 + 6;
      float cardCx = cx + cos(angulo) * distancia;
      float cardCy = cy + sin(angulo) * distancia;
      float alvoX = cx + cos(angulo) * raio;
      float alvoY = cy + sin(angulo) * raio;
      float rotacao = rotacaoLegivel(angulo);

      desenharConexoes(produto, posicoesTags, alvoX, alvoY);
      desenharCardProduto(produto, cardCx, cardCy, cardW, cardH, rotacao, segmentos);
      areasProdutos.add(new AreaProdutoVisual(produto, cardCx, cardCy, cardW, cardH, rotacao));
      if (i == 0 && painelProdutoPrecisaSelecao()) {
        painelProdutoSelecionar(produto.produtoOriginal);
      }
      slot += segmentos;
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

  void desenharCardProduto(ProdutoVisual produto, float cx, float cy, float w, float h, float rotacao, int segmentos) {
    pushMatrix();
    translate(cx, cy);
    rotate(rotacao);

    noStroke();
    fill(produto.origem.equals("brasileiro") ? COR_NACIONAL : COR_INTERNACIONAL);
    rect(-w/2, -h/2, w, h);

    fill(#000000);
    textFont(fonteProduto);
    textSize(tamanhoTextoProduto(produto.nome, w - 18));
    textAlign(CENTER, CENTER);
    text(produto.nome, -w/2 + 9, -h/2, w - 18, h);
    popMatrix();
  }

  int segmentosProduto(ProdutoVisual produto) {
    return constrain(produto.peso, 1, 3);
  }

  float anguloCentroSlots(int slotInicial, int segmentos) {
    return -HALF_PI + (slotInicial + (segmentos - 1) / 2.0f) * TWO_PI / SLOTS_CIRCULO;
  }

  float rotacaoLegivel(float angulo) {
    float rotacao = angulo;
    if (cos(angulo) < 0) {
      rotacao += PI;
    }
    return rotacao;
  }

  float larguraSlot(float raio) {
    float arco = TWO_PI * raio / SLOTS_CIRCULO;
    return max(40, arco * 0.68f);
  }

  float larguraCardProduto(String nome) {
    textFont(fonteProduto);
    textSize(18);
    return constrain(textWidth(nome) + 28, 100, 150);
  }

  void desenharNomeTagDestaque(TagFiltro tag, float cx, float y) {
    fill(temaCorTextoVisualPrototipo());
    textFont(fonteFiltro);
    textSize(13);
    textAlign(CENTER, TOP);
    text(tag.rotulo, cx, y);
  }

  void desenharMensagemVazia(float cx, float cy) {
    fill(temaCorTextoVisualPrototipo(), 170);
    textFont(fonteFiltro);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Selecione tags no filtro para visualizar os produtos", cx, cy);
  }

  void desenharTimeline() {
    float tx = X + 4;
    float ty = limiteInferiorVisual();

    noStroke();
    fill(temaCorTimelineFundoPrototipo());
    rect(tx, ty + 40, timelineW(), 60);

    float xInicio = xAno(anoInicio);
    float xFim = xAno(anoFim);
    fill(#FFCB00);
    rect(xInicio + TIMELINE_HANDLE_W, ty + 40, max(0, xFim - xInicio - TIMELINE_HANDLE_W), 60);

    float faixaX = xInicio + TIMELINE_HANDLE_W;
    float faixaW = max(0, xFim - xInicio - TIMELINE_HANDLE_W);
    clip(round(faixaX), round(ty + 40), round(faixaW), 60);
    stroke(temaCorTimelineHachuraPrototipo());
    strokeWeight(3);
    for (float hx = xInicio - 60; hx < xFim; hx += 18) {
      line(hx, ty + 100, hx + 58, ty + 40);
    }
    noClip();

    noStroke();
    fill(temaCorTimelineFundoPrototipo());
    rect(tx, ty + 40, max(0, faixaX - tx), 60);
    rect(xFim, ty + 40, max(0, tx + timelineW() - xFim), 60);

    noStroke();
    fill(temaCorTextoVisualPrototipo());
    rect(xInicio, ty + 10, TIMELINE_HANDLE_W, TIMELINE_HANDLE_H);
    rect(xFim, ty + 10, TIMELINE_HANDLE_W, TIMELINE_HANDLE_H);

    desenharAnoTimeline(anoInicio, xInicio, ty);
    desenharAnoTimeline(anoFim, xFim, ty);
  }

  void desenharAnoTimeline(int ano, float x, float ty) {
    fill(temaCorTextoVisualPrototipo());
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

  boolean mousePressed(float mx, float my) {
    if (!dentro(mx, my)) {
      return false;
    }

    ProdutoVisual produto = produtoSobMouse(mx, my);
    if (produto != null) {
      painelProdutoSelecionar(produto.produtoOriginal);
      return true;
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

  TagFiltro tagSobMouse(float mx, float my) {
    float cx = centroCirculoX();
    float cy = centroCirculoY();
    float raio = raioCirculo() * 0.72f;

    for (TagFiltro tag : tagsParaVisualizacao(tagsSelecionadas())) {
      PVector pos = posicaoTag(tag, cx, cy, raio);
      if (dist(mx, my, pos.x, pos.y) <= 13) {
        return tag;
      }
    }
    return null;
  }

  ProdutoVisual produtoSobMouse(float mx, float my) {
    for (int i = areasProdutos.size() - 1; i >= 0; i--) {
      AreaProdutoVisual area = areasProdutos.get(i);
      if (area.contem(mx, my)) {
        return area.produto;
      }
    }
    return null;
  }

  boolean dentro(float mx, float my) {
    return mx >= X && mx <= X + larguraVisual() && my >= Y && my <= Y + alturaVisual();
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

  ArrayList<TagFiltro> tagsParaVisualizacao(ArrayList<TagFiltro> tagsAtivas) {
    ArrayList<TagFiltro> tagsNaoTipo = new ArrayList<TagFiltro>();
    ArrayList<TagFiltro> tagsTipoProduto = new ArrayList<TagFiltro>();

    for (TagFiltro tag : tagsAtivas) {
      if (tag.dimensao.id.equals(filtros.DIM_TIPO_OBRA)) {
        tagsTipoProduto.add(tag);
      } else {
        tagsNaoTipo.add(tag);
      }
    }

    if (tagsNaoTipo.size() > 0) {
      return tagsNaoTipo;
    }
    return tagsTipoProduto;
  }

  ArrayList<TagFiltro> tagsDaDimensao(ArrayList<TagFiltro> tags, String dimensaoId) {
    ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
    for (TagFiltro tag : tags) {
      if (tag.dimensao.id.equals(dimensaoId)) {
        resultado.add(tag);
      }
    }
    return resultado;
  }

  ArrayList<ProdutoVisual> produtosVisiveis(ArrayList<TagFiltro> tagsVisuais, ArrayList<TagFiltro> tagsTipoProduto) {
    ArrayList<ProdutoVisual> resultado = new ArrayList<ProdutoVisual>();
    if (tagsVisuais.size() == 0) {
      return resultado;
    }

    for (ProdutoFiltrado produto : filtros.produtos) {
      int ano = anoProduto(produto);
      if (ano < anoInicio || ano > anoFim) {
        continue;
      }
      if (!produtoPassaFiltroTipo(produto, tagsTipoProduto)) {
        continue;
      }

      ArrayList<TagFiltro> tagsDoProduto = new ArrayList<TagFiltro>();
      boolean ligadoAoDestaque = tagEmDestaque == null;
      for (TagFiltro tag : tagsVisuais) {
        if (produto.possuiTag(tag)) {
          tagsDoProduto.add(tag);
          if (tagEmDestaque != null && tagEmDestaque.chave().equals(tag.chave())) {
            ligadoAoDestaque = true;
          }
        }
      }

      if (tagsDoProduto.size() > 0 && ligadoAoDestaque) {
        resultado.add(new ProdutoVisual(produto, produto.nome, produto.origem, ano, tipoProduto(produto), tagsDoProduto));
      }
    }

    final HashMap<String, Integer> frequenciasPorTipo = frequenciasTipo(resultado);
    Collections.sort(resultado, new Comparator<ProdutoVisual>() {
      public int compare(ProdutoVisual a, ProdutoVisual b) {
        if (b.peso != a.peso) {
          return b.peso - a.peso;
        }
        int origemA = a.origem.equals("brasileiro") ? 1 : 0;
        int origemB = b.origem.equals("brasileiro") ? 1 : 0;
        if (origemB != origemA) {
          return origemB - origemA;
        }
        int freqA = frequenciasPorTipo.containsKey(a.tipo) ? frequenciasPorTipo.get(a.tipo) : 0;
        int freqB = frequenciasPorTipo.containsKey(b.tipo) ? frequenciasPorTipo.get(b.tipo) : 0;
        if (freqB != freqA) {
          return freqB - freqA;
        }
        return a.nome.compareToIgnoreCase(b.nome);
      }
    });

    return resultado;
  }

  ArrayList<ProdutoVisual> produtosExibidos(ArrayList<TagFiltro> tagsVisuais, ArrayList<TagFiltro> tagsTipoProduto) {
    atualizarDestaque(tagsVisuais);
    return limitarProdutosAosSlots(produtosVisiveis(tagsVisuais, tagsTipoProduto));
  }

  ArrayList<ProdutoFiltrado> produtosOriginaisExibidos() {
    ArrayList<TagFiltro> tagsAtivas = tagsSelecionadas();
    ArrayList<TagFiltro> tagsTipoProduto = tagsDaDimensao(tagsAtivas, filtros.DIM_TIPO_OBRA);
    ArrayList<TagFiltro> tagsVisuais = tagsParaVisualizacao(tagsAtivas);
    ArrayList<ProdutoVisual> produtos = produtosExibidos(tagsVisuais, tagsTipoProduto);
    ArrayList<ProdutoFiltrado> resultado = new ArrayList<ProdutoFiltrado>();

    for (ProdutoVisual produto : produtos) {
      resultado.add(produto.produtoOriginal);
    }

    return resultado;
  }

  ArrayList<ProdutoVisual> limitarProdutosAosSlots(ArrayList<ProdutoVisual> produtos) {
    ArrayList<ProdutoVisual> resultado = new ArrayList<ProdutoVisual>();
    int slot = 0;

    for (ProdutoVisual produto : produtos) {
      if (slot >= SLOTS_CIRCULO) {
        break;
      }

      int segmentos = segmentosProduto(produto);
      if (slot + segmentos > SLOTS_CIRCULO) {
        segmentos = SLOTS_CIRCULO - slot;
      }
      if (segmentos <= 0) {
        break;
      }

      resultado.add(produto);
      slot += segmentos;
    }

    return resultado;
  }

  boolean produtoPassaFiltroTipo(ProdutoFiltrado produto, ArrayList<TagFiltro> tagsTipoProduto) {
    if (tagsTipoProduto.size() == 0) {
      return true;
    }
    for (TagFiltro tag : tagsTipoProduto) {
      if (produto.possuiTag(tag)) {
        return true;
      }
    }
    return false;
  }

  HashMap<String, Integer> frequenciasTipo(ArrayList<ProdutoVisual> produtos) {
    HashMap<String, Integer> frequencias = new HashMap<String, Integer>();
    for (ProdutoVisual produto : produtos) {
      if (produto.tipo.length() == 0) {
        continue;
      }
      int atual = frequencias.containsKey(produto.tipo) ? frequencias.get(produto.tipo) : 0;
      frequencias.put(produto.tipo, atual + 1);
    }
    return frequencias;
  }

  String tipoProduto(ProdutoFiltrado produto) {
    ArrayList<TagFiltro> tipos = produto.tagsDaDimensao(filtros.DIM_TIPO_OBRA);
    if (tipos.size() == 0) {
      return "";
    }
    return tipos.get(0).rotulo;
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
    float angulo = map(h % 10000, 0, 9999, 0, TWO_PI);
    float r = raio * map((h / 10000) % 100, 0, 99, 0.35f, 1.0f);
    return new PVector(cx + cos(angulo) * r, cy + sin(angulo) * r);
  }

  float xAno(int ano) {
    float tx = X + 4;
    return tx + map(ano, ANO_MIN, ANO_MAX, 0, timelineW() - TIMELINE_HANDLE_W);
  }

  float centroCirculoX() {
    return X + larguraVisual()/2.0f;
  }

  float centroCirculoY() {
    return Y + (alturaVisual() - TIMELINE_H)/2.0f;
  }

  float limiteInferiorVisual() {
    return Y + alturaVisual() - TIMELINE_H;
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

  float timelineW() {
    return larguraTimelineLayout();
  }

  float raioCirculo() {
    float larguraDisponivel = max(220, larguraVisual() - 320);
    float alturaDisponivel = max(260, alturaVisual() - TIMELINE_H - 80);
    return min(CIRCLE_SIZE/2.0f, min(larguraDisponivel, alturaDisponivel) / 2.0f);
  }

  float alturaVisual() {
    return height;
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
    return temaCorLinhaVisualPrototipo();
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
  ProdutoFiltrado produtoOriginal;
  String nome;
  String origem;
  String tipo;
  int ano;
  int peso;
  ArrayList<TagFiltro> tags;

  ProdutoVisual(ProdutoFiltrado produtoOriginal, String nome, String origem, int ano, String tipo, ArrayList<TagFiltro> tags) {
    this.produtoOriginal = produtoOriginal;
    this.nome = nome;
    this.origem = origem;
    this.tipo = tipo == null ? "" : tipo;
    this.ano = ano;
    this.tags = tags;
    this.peso = tags.size();
  }
}

class AreaProdutoVisual {
  ProdutoVisual produto;
  float cx;
  float cy;
  float w;
  float h;
  float rotacao;

  AreaProdutoVisual(ProdutoVisual produto, float cx, float cy, float w, float h, float rotacao) {
    this.produto = produto;
    this.cx = cx;
    this.cy = cy;
    this.w = w;
    this.h = h;
    this.rotacao = rotacao;
  }

  boolean contem(float mx, float my) {
    float dx = mx - cx;
    float dy = my - cy;
    float c = cos(-rotacao);
    float s = sin(-rotacao);
    float localX = dx * c - dy * s;
    float localY = dx * s + dy * c;
    return abs(localX) <= w/2 && abs(localY) <= h/2;
  }
}

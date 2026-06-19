class VisualizacaoLinhaTempo {
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
  final color COR_NACIONAL = #FFCB00;
  final color COR_INTERNACIONAL = #FF00FB;

  PFont fonteAno;
  PFont fonteTexto;

  int anoInicio = 1880;
  int anoFim = 2010;
  int handleArrastado = 0;
  ArrayList<AreaProdutoLinhaTempo> areasProdutos = new ArrayList<AreaProdutoLinhaTempo>();

  VisualizacaoLinhaTempo(SistemaFiltros filtros) {
    this.filtros = filtros;
  }

  void carregarAssets() {
    fonteAno = createFont("Afacad Flux SemiBold", 30, true);
    fonteTexto = createFont("Roboto Condensed", 15, true);
  }

  void desenhar() {
    pushStyle();
    desenharFundo();
    ArrayList<ProdutoFiltrado> produtos = produtosVisiveis();
    desenharEixoProdutos(produtos);
    desenharTimeline();
    popStyle();
  }

  void desenharFundo() {
    noStroke();
    fill(COR_FUNDO);
    rect(X, Y, W, H);
  }

  void desenharEixoProdutos(ArrayList<ProdutoFiltrado> produtos) {
    float eixoY = centroEixoY();
    float x1 = X + 40;
    float x2 = X + W - 40;
    areasProdutos.clear();

    stroke(#FFFFFF);
    strokeWeight(3);
    line(X, eixoY, X + W, eixoY);

    if (produtos.size() == 0) {
      fill(#FFFFFF, 180);
      textFont(fonteTexto);
      textSize(16);
      textAlign(CENTER, CENTER);
      text("Nenhum produto encontrado para os filtros atuais", X + W/2, eixoY - 42);
      return;
    }

    float raioProduto = produtos.size() > 140 ? 5 : produtos.size() > 85 ? 6 : 8;
    float passoY = raioProduto * 2.8f;
    ArrayList<PVector> posicoesUsadas = new ArrayList<PVector>();

    for (ProdutoFiltrado produto : produtos) {
      int ano = anoProduto(produto);
      float px = xProduto(ano, x1, x2);
      float py = ySemSobreposicao(px, eixoY, passoY, raioProduto, posicoesUsadas);
      py = constrain(py, Y + 54, limiteInferiorVisual() - 42);

      noStroke();
      fill(produto.origem.equals("brasileiro") ? COR_NACIONAL : COR_INTERNACIONAL);
      ellipse(px, py, raioProduto * 2, raioProduto * 2);
      posicoesUsadas.add(new PVector(px, py));
      areasProdutos.add(new AreaProdutoLinhaTempo(produto, px, py, raioProduto + 5));
    }
  }

  float ySemSobreposicao(float px, float eixoY, float passoY, float raioProduto, ArrayList<PVector> posicoesUsadas) {
    int[] ordemCamadas = { -1, 1, -2, 2, -3, 3, -4, 4, -5, 5, -6, 6, -7, 7, -8, 8, -9, 9, -10, 10 };
    float distanciaMinima = raioProduto * 2.35f;

    for (int i = 0; i < ordemCamadas.length; i++) {
      float py = eixoY + ordemCamadas[i] * passoY;
      if (py < Y + 54 || py > limiteInferiorVisual() - 42) {
        continue;
      }
      if (!colideComProduto(px, py, distanciaMinima, posicoesUsadas)) {
        return py;
      }
    }

    return eixoY + ordemCamadas[ordemCamadas.length - 1] * passoY;
  }

  boolean colideComProduto(float px, float py, float distanciaMinima, ArrayList<PVector> posicoesUsadas) {
    for (PVector pos : posicoesUsadas) {
      if (dist(px, py, pos.x, pos.y) < distanciaMinima) {
        return true;
      }
    }
    return false;
  }

  ArrayList<ProdutoFiltrado> produtosVisiveis() {
    ArrayList<ProdutoFiltrado> resultado = new ArrayList<ProdutoFiltrado>();
    ArrayList<ProdutoFiltrado> produtos = filtros.produtosFiltrados(false);

    for (ProdutoFiltrado produto : produtos) {
      int ano = anoProduto(produto);
      if (ano >= anoInicio && ano <= anoFim) {
        resultado.add(produto);
      }
    }

    Collections.sort(resultado, new Comparator<ProdutoFiltrado>() {
      public int compare(ProdutoFiltrado a, ProdutoFiltrado b) {
        int anoA = anoProduto(a);
        int anoB = anoProduto(b);
        if (anoA != anoB) {
          return anoA - anoB;
        }
        return a.nome.compareToIgnoreCase(b.nome);
      }
    });

    return resultado;
  }

  void desenharTimeline() {
    float tx = X + 4;
    float ty = limiteInferiorVisual();

    noStroke();
    fill(#505050);
    rect(tx, ty + 40, TIMELINE_W, 60);

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
    rect(xFim, ty + 40, max(0, tx + TIMELINE_W - xFim), 60);

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
      AreaProdutoLinhaTempo area = areasProdutos.get(i);
      if (dist(mx, my, area.x, area.y) <= area.r) {
        return area.produto;
      }
    }
    return null;
  }

  int anoProduto(ProdutoFiltrado produto) {
    String texto = valorColuna(produto, "Datação", 4);
    String[] partes = match(texto, "(18|19|20)\\d\\d");
    if (partes != null && partes.length > 0) {
      return int(partes[0]);
    }
    return ANO_MIN;
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

  float xProduto(int ano, float x1, float x2) {
    if (anoInicio == anoFim) {
      return (x1 + x2) / 2.0f;
    }
    return map(constrain(ano, anoInicio, anoFim), anoInicio, anoFim, x1, x2);
  }

  float xAno(int ano) {
    float tx = X + 4;
    return tx + map(ano, ANO_MIN, ANO_MAX, 0, TIMELINE_W - TIMELINE_HANDLE_W);
  }

  int anoPorX(float x) {
    float tx = X + 4;
    float fim = tx + TIMELINE_W - TIMELINE_HANDLE_W;
    int ano = round(map(constrain(x, tx, fim), tx, fim, ANO_MIN, ANO_MAX) / 10.0f) * 10;
    return constrain(ano, ANO_MIN, ANO_MAX);
  }

  float centroEixoY() {
    return Y + (min(height, H) - TIMELINE_H) * 0.50f;
  }

  float limiteInferiorVisual() {
    return Y + min(height, H) - TIMELINE_H;
  }

  boolean dentro(float mx, float my) {
    return mx >= X && mx <= X + W && my >= Y && my <= Y + H;
  }
}

class AreaProdutoLinhaTempo {
  ProdutoFiltrado produto;
  float x;
  float y;
  float r;

  AreaProdutoLinhaTempo(ProdutoFiltrado produto, float x, float y, float r) {
    this.produto = produto;
    this.x = x;
    this.y = y;
    this.r = r;
  }
}

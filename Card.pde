class Card {
  final float MIN_W = 90;
  final float MIN_H = 75;
  final float MIN_DETAIL_W = 520;
  final float MIN_DETAIL_H = 520;
  final float DETAIL_BUTTON_W = 22;
  final int TOTAL_CAMPOS_DETALHE = 8;

  float x;
  float y;
  float w;
  float h;
  Produto p;
  boolean detalhesVisiveis = false;
  boolean tamanhoOriginalSalvo = false;
  float originalW;
  float originalH;
  boolean[] camposDetalheVisiveis = { true, true, true, true, true, true, true, true };
  float[] detalheLabelX = new float[TOTAL_CAMPOS_DETALHE];
  float[] detalheLabelY = new float[TOTAL_CAMPOS_DETALHE];
  float[] detalheLabelW = new float[TOTAL_CAMPOS_DETALHE];
  float[] detalheLabelH = new float[TOTAL_CAMPOS_DETALHE];

  Card(float x, float y, float w, float h, Produto p) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.p = p;
  }

  void desenhar() {
    fill(0, 30);
    noStroke();
    rect(x + 3, y + 3, w, h, 6);

    fill(255);
    stroke(150);
    strokeWeight(1);
    rect(x, y, w, h, 6);

    if (detalhesVisiveis) {
      desenharDetalhes();
    } else {
      desenharConteudoInterno(p, x + DETAIL_BUTTON_W, y, w - DETAIL_BUTTON_W, h);
    }

    desenharBotaoDetalhes();
    desenharBotaoFechar();
    desenharAlcaRedimensionar();
  }

  void desenharBotaoDetalhes() {
    if (isDetailHovered()) {
      fill(70, 70, 70);
    } else {
      fill(100, 100, 100);
    }

    noStroke();
    rect(x, y + h/2 - 18, DETAIL_BUTTON_W, 36, 0, 6, 6, 0);

    fill(255);
    textSize(14);
    textAlign(CENTER, CENTER);
    text(detalhesVisiveis ? "-" : "+", x + DETAIL_BUTTON_W/2, y + h/2);
    textAlign(LEFT, BASELINE);
  }

  void desenharDetalhes() {
    float margem = 14;
    float conteudoX = x + DETAIL_BUTTON_W + margem;
    float conteudoY = y + margem;
    float conteudoW = w - DETAIL_BUTTON_W - margem * 2;
    float topoH = min(210, max(165, h * 0.38));
    float caixasY = conteudoY + topoH + 10;
    float limiteY = y + h - margem - 22;

    limparAreasCamposDetalhe();
    desenharImagemTopoDetalhes(conteudoX, conteudoY, conteudoW, topoH);
    desenharCaixasDetalhes(conteudoX, caixasY, conteudoW, limiteY);

    textAlign(LEFT, BASELINE);
  }

  void desenharImagemTopoDetalhes(float imgX, float imgY, float imgW, float imgH) {
    fill(230);
    noStroke();
    rect(imgX, imgY, imgW, imgH, 8);

    PImage img = obterImagemTopoDetalhes();

    if (img != null) {
      desenharImagemProdutoPreenchendo(img, imgX, imgY, imgW, imgH);
      fill(0, 90);
      rect(imgX, imgY, imgW, imgH, 8);
    } else {
      fill(120);
      textSize(12);
      textAlign(CENTER, CENTER);
      text("Imagem indisponivel", imgX + imgW/2, imgY + imgH/2);
    }

    fill(255);
    textAlign(LEFT, TOP);
    textSize(18);
    ArrayList<String> linhasTitulo = quebrarTextoComReticencias(p.nome, imgW - 32, 2);
    float tituloY = imgY + 14;

    for (String linha : linhasTitulo) {
      desenharTextoNegrito(linha, imgX + 16, tituloY);
      tituloY += 20;
    }
  }

  PImage obterImagemTopoDetalhes() {
    if (p.imagensRelacionadas.size() > 1 && p.imagensRelacionadas.get(1) != null) {
      return p.imagensRelacionadas.get(1);
    }

    if (p.imagensRelacionadas.size() > 0 && p.imagensRelacionadas.get(0) != null) {
      return p.imagensRelacionadas.get(0);
    }

    return null;
  }

  void desenharImagemProdutoPreenchendo(PImage img, float imgX, float imgY, float imgW, float imgH) {
    float escala = max(imgW / img.width, imgH / img.height);
    int origemW = max(1, int(imgW / escala));
    int origemH = max(1, int(imgH / escala));
    int origemX = max(0, (img.width - origemW) / 2);
    int origemY = max(0, (img.height - origemH) / 2);

    copy(img, origemX, origemY, origemW, origemH, int(imgX), int(imgY), int(imgW), int(imgH));
  }

  void desenharCaixasDetalhes(float baseX, float baseY, float baseW, float limiteY) {
    float gap = 8;
    float colunaW = (baseW - gap) / 2;
    float caixaH = 34;
    float cursorY = baseY;
    int[][] camposCurtos = {
      { 0, 1 },
      { 2, 3 },
      { 4, 6 }
    };

    for (int linha = 0; linha < camposCurtos.length; linha++) {
      desenharCaixaDetalhe(camposCurtos[linha][0], baseX, cursorY, colunaW, caixaH);
      desenharCaixaDetalhe(camposCurtos[linha][1], baseX + colunaW + gap, cursorY, colunaW, caixaH);
      cursorY += caixaH + gap;
    }

    float espacoLongo = max(92, limiteY - cursorY);
    float caixaLongaH = max(44, (espacoLongo - gap) / 2);

    desenharCaixaDetalhe(5, baseX, cursorY, baseW, caixaLongaH);
    cursorY += caixaLongaH + gap;
    desenharCaixaDetalhe(7, baseX, cursorY, baseW, caixaLongaH);
  }

  void desenharCaixaDetalhe(int indice, float caixaX, float caixaY, float caixaW, float caixaH) {
    String rotulo = obterRotuloCampoDetalhe(indice);
    String valor = obterValorCampoDetalhe(indice);
    boolean campoCurto = indice != 5 && indice != 7;
    float padding = campoCurto ? 8 : 10;
    float textoX = caixaX + padding;
    float textoW = caixaW - padding * 2;
    float rotuloY = caixaY + padding;
    float valorY = campoCurto ? rotuloY : rotuloY + 16;

    fill(255);
    stroke(224);
    strokeWeight(1);
    rect(caixaX, caixaY, caixaW, caixaH, 8);
    noStroke();

    fill(isMouseSobreCampoDetalhe(indice) ? 20 : 80);
    textSize(campoCurto ? 10 : 10);
    textAlign(LEFT, TOP);

    detalheLabelX[indice] = textoX;
    detalheLabelY[indice] = rotuloY;
    detalheLabelW[indice] = textWidth(rotulo + ":");
    detalheLabelH[indice] = campoCurto ? 16 : 13;

    if (campoCurto) {
      desenharLinhaCampoCurto(indice, rotulo, valor, textoX, rotuloY, textoW);
      return;
    }

    desenharTextoNegrito(rotulo, textoX, rotuloY);

    if (!camposDetalheVisiveis[indice]) {
      fill(25);
      textSize(11);
      text("...", textoX, valorY);
      return;
    }

    fill(25);
    textSize(11);
    int maxLinhas = max(1, int((caixaY + caixaH - padding - valorY) / 13));
    ArrayList<String> linhas = quebrarTextoComReticencias(valor, textoW, maxLinhas);
    float linhaY = valorY;

    for (String linha : linhas) {
      text(linha, textoX, linhaY);
      linhaY += 13;
    }
  }

  void desenharLinhaCampoCurto(int indice, String rotulo, String valor, float textoX, float textoY, float textoW) {
    String prefixo = rotulo + ": ";
    float prefixoW = textWidth(prefixo);

    fill(isMouseSobreCampoDetalhe(indice) ? 20 : 80);
    textSize(10);
    desenharTextoNegrito(prefixo, textoX, textoY);

    fill(25);
    textSize(10);

    if (!camposDetalheVisiveis[indice]) {
      text("...", textoX + prefixoW, textoY);
      return;
    }

    text(encurtarComReticencias(valor, textoW - prefixoW), textoX + prefixoW, textoY);
  }

  void desenharTextoNegrito(String texto, float textoX, float textoY) {
    text(texto, textoX, textoY);
    text(texto, textoX + 0.6, textoY);
  }

  void desenharTextoNegrito(String texto, float textoX, float textoY, float textoW, float textoH) {
    text(texto, textoX, textoY, textoW, textoH);
    text(texto, textoX + 0.6, textoY, textoW, textoH);
  }

  void limparAreasCamposDetalhe() {
    for (int i = 0; i < TOTAL_CAMPOS_DETALHE; i++) {
      detalheLabelX[i] = -1;
      detalheLabelY[i] = -1;
      detalheLabelW[i] = 0;
      detalheLabelH[i] = 0;
    }
  }

  String obterRotuloCampoDetalhe(int indice) {
    String[] rotulos = {
      "Tipo",
      "Material",
      "Datacao",
      "Localizacao geografica",
      "Autoria",
      "Condicionantes industriais/economicos",
      "Numero de exemplares",
      "Tecnica de composicao"
    };

    return rotulos[indice];
  }

  String obterValorCampoDetalhe(int indice) {
    String[] valores = {
      p.tipo,
      p.material,
      p.datacao,
      p.localizacao,
      p.autoria,
      p.condicionantes,
      p.numeroExemplares,
      p.tecnicaComposicao
    };

    if (valores[indice] == null || valores[indice].length() == 0) {
      return "Informacao indisponivel";
    }

    return valores[indice];
  }

  ArrayList<String> quebrarTextoComReticencias(String texto, float maxW, int maxLinhas) {
    ArrayList<String> linhas = new ArrayList<String>();
    String[] palavras = splitTokens(texto, " \n\r\t");
    String linhaAtual = "";

    for (int i = 0; i < palavras.length; i++) {
      String tentativa = linhaAtual.length() == 0 ? palavras[i] : linhaAtual + " " + palavras[i];

      if (textWidth(tentativa) <= maxW) {
        linhaAtual = tentativa;
        continue;
      }

      if (linhaAtual.length() == 0) {
        linhas.add(encurtarComReticencias(palavras[i], maxW));
      } else {
        linhas.add(linhaAtual);
        linhaAtual = palavras[i];
      }

      if (linhas.size() == maxLinhas) {
        linhas.set(linhas.size() - 1, adicionarReticencias(linhas.get(linhas.size() - 1), maxW));
        return linhas;
      }
    }

    if (linhaAtual.length() > 0) {
      if (linhas.size() < maxLinhas) {
        linhas.add(encurtarComReticencias(linhaAtual, maxW));
      } else {
        linhas.set(linhas.size() - 1, adicionarReticencias(linhas.get(linhas.size() - 1), maxW));
      }
    }

    if (linhas.size() == 0) {
      linhas.add("...");
    }

    return linhas;
  }

  String adicionarReticencias(String texto, float maxW) {
    String textoLimpo = texto;

    if (textoLimpo.endsWith("...")) {
      return encurtarComReticencias(textoLimpo, maxW);
    }

    while (textoLimpo.length() > 0 && textWidth(textoLimpo + "...") > maxW) {
      textoLimpo = textoLimpo.substring(0, textoLimpo.length() - 1);
    }

    if (textoLimpo.length() == 0) {
      return "...";
    }

    return textoLimpo + "...";
  }

  String encurtarComReticencias(String texto, float maxW) {
    if (textWidth(texto) <= maxW) {
      return texto;
    }

    String resultado = texto;

    while (resultado.length() > 0 && textWidth(resultado + "...") > maxW) {
      resultado = resultado.substring(0, resultado.length() - 1);
    }

    if (resultado.length() == 0) {
      return "...";
    }

    return resultado + "...";
  }

  void desenharBotaoFechar() {
    if (isCloseHovered()) {
      fill(255, 50, 50);
    } else {
      fill(200, 80, 80);
    }

    noStroke();
    rect(x + w - 20, y, 20, 20, 0, 6, 0, 4);

    fill(255);
    textSize(10);
    textAlign(CENTER, CENTER);
    text("X", x + w - 10, y + 10);
    textAlign(LEFT, BASELINE);
  }

  void desenharAlcaRedimensionar() {
    if (isResizeHovered()) {
      fill(70, 130, 220);
    } else {
      fill(110, 150, 210);
    }

    noStroke();
    rect(x + w - 18, y + h - 18, 18, 18, 6, 0, 6, 0);

    stroke(255);
    strokeWeight(2);
    line(x + w - 13, y + h - 5, x + w - 5, y + h - 13);
    line(x + w - 9, y + h - 5, x + w - 5, y + h - 9);
    noStroke();
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }

  boolean isCloseHovered() {
    return mouseX >= x + w - 20 && mouseX <= x + w && mouseY >= y && mouseY <= y + 20;
  }

  boolean isResizeHovered() {
    return mouseX >= x + w - 18 && mouseX <= x + w && mouseY >= y + h - 18 && mouseY <= y + h;
  }

  boolean isDetailHovered() {
    return mouseX >= x && mouseX <= x + DETAIL_BUTTON_W && mouseY >= y + h/2 - 18 && mouseY <= y + h/2 + 18;
  }

  boolean isMouseSobreCampoDetalhe(int indice) {
    return detalheLabelX[indice] >= 0 &&
      mouseX >= detalheLabelX[indice] &&
      mouseX <= detalheLabelX[indice] + detalheLabelW[indice] &&
      mouseY >= detalheLabelY[indice] &&
      mouseY <= detalheLabelY[indice] + detalheLabelH[indice];
  }

  boolean alternarCampoDetalheSobMouse() {
    if (!detalhesVisiveis) {
      return false;
    }

    for (int i = 0; i < TOTAL_CAMPOS_DETALHE; i++) {
      if (isMouseSobreCampoDetalhe(i)) {
        camposDetalheVisiveis[i] = !camposDetalheVisiveis[i];
        return true;
      }
    }

    return false;
  }

  void alternarDetalhes() {
    if (!detalhesVisiveis) {
      originalW = w;
      originalH = h;
      tamanhoOriginalSalvo = true;
      detalhesVisiveis = true;
      x = constrain(x, 8, max(8, width - MIN_DETAIL_W - 8));
      y = constrain(y, 8, max(8, height - MIN_DETAIL_H - 8));
      redimensionar(max(w, MIN_DETAIL_W), max(h, MIN_DETAIL_H));
    } else {
      detalhesVisiveis = false;

      if (tamanhoOriginalSalvo) {
        w = originalW;
        h = originalH;
      }
    }
  }

  void redimensionar(float novaLargura, float novaAltura) {
    float minW = detalhesVisiveis ? MIN_DETAIL_W : MIN_W;
    float minH = detalhesVisiveis ? MIN_DETAIL_H : MIN_H;
    float maxW = max(minW, width - x - 8);
    float maxH = max(minH, height - y - 8);

    w = constrain(novaLargura, minW, maxW);
    h = constrain(novaAltura, minH, maxH);
  }
}

void desenharCardsAtivos() {
  for (Card c : cardsAtivos) {
    c.desenhar();
  }
}

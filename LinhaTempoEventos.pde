class LinhaTempoEventos {
  final float BAR_H = 175;
  final float EVENT_W = 180;
  final float EVENT_H = 72;
  final float GROUP_GAP = 42;
  final float CARD_GAP = 12;
  final int TOTAL_BLOCOS_POPUP = 6;

  ArrayList<Evento> eventosFonte;
  ArrayList<Integer> decadas = new ArrayList<Integer>();
  ArrayList<Boolean> decadasVisiveis = new ArrayList<Boolean>();
  ArrayList<EventoHit> hitsEventos = new ArrayList<EventoHit>();

  float scrollX = 0;
  float conteudoW = 0;
  boolean arrastando = false;
  boolean arrastou = false;
  float dragStartX;
  float scrollStartX;
  Evento eventoPressionado = null;

  boolean escondida = false;
  boolean filtroAberto = false;
  boolean filtroScrollArrastando = false;
  float filtroScrollY = 0;
  float filtroScrollStartY = 0;
  float filtroMouseStartY = 0;
  Evento eventoSelecionado = null;
  float[] popupScrollY = new float[TOTAL_BLOCOS_POPUP];
  float[] popupBlocoX = new float[TOTAL_BLOCOS_POPUP];
  float[] popupBlocoY = new float[TOTAL_BLOCOS_POPUP];
  float[] popupBlocoW = new float[TOTAL_BLOCOS_POPUP];
  float[] popupBlocoH = new float[TOTAL_BLOCOS_POPUP];
  float[] popupConteudoH = new float[TOTAL_BLOCOS_POPUP];

  LinhaTempoEventos(ArrayList<Evento> eventosFonte) {
    this.eventosFonte = eventosFonte;
    prepararDecadas();
  }

  void prepararDecadas() {
    decadas.clear();
    decadasVisiveis.clear();

    for (Evento evento : eventosFonte) {
      int decada = obterDecadaEvento(evento);

      if (decada == -1 || indiceDecada(decada) != -1) {
        continue;
      }

      decadas.add(decada);
    }

    java.util.Collections.sort(decadas);

    for (int i = 0; i < decadas.size(); i++) {
      decadasVisiveis.add(Boolean.TRUE);
    }
  }

  void desenhar() {
    if (escondida) {
      desenharBotaoMostrar();
      return;
    }

    float barY = obterBarY();
    fill(250);
    stroke(215);
    strokeWeight(1);
    rect(0, barY, width, BAR_H);

    desenharControles(barY);
    desenharEventos(barY);

    if (filtroAberto) {
      desenharMenuFiltro(barY);
    }

    if (eventoSelecionado != null) {
      desenharPopupEvento();
    }
  }

  void desenharBotaoMostrar() {
    float bx = width - 48;
    float by = height - 48;

    fill(45);
    noStroke();
    rect(bx, by, 40, 40, 8);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(18);
    text("^", bx + 20, by + 20);
    textAlign(LEFT, BASELINE);
  }

  void desenharControles(float barY) {
    float filtroX = width - 108;
    float esconderX = width - 54;
    float yBtn = barY + 12;

    fill(filtroAberto ? 230 : 245);
    stroke(210);
    rect(filtroX, yBtn, 44, 30, 6);
    fill(40);
    textAlign(CENTER, CENTER);
    textSize(12);
    text("Filtro", filtroX + 22, yBtn + 15);

    fill(245);
    stroke(210);
    rect(esconderX, yBtn, 36, 30, 6);
    fill(40);
    textSize(18);
    text("-", esconderX + 18, yBtn + 13);
    textAlign(LEFT, BASELINE);
  }

  void desenharEventos(float barY) {
    hitsEventos.clear();

    float xAtual = 28 + scrollX;
    float centroY = barY + 108;
    float eventoY = centroY - EVENT_H/2;

    for (int i = 0; i < decadas.size(); i++) {
      if (!decadasVisiveis.get(i)) {
        continue;
      }

      int decada = decadas.get(i);
      ArrayList<Evento> eventosDecada = eventosDaDecada(decada);

      if (eventosDecada.size() == 0) {
        continue;
      }

      fill(35);
      noStroke();
      ellipse(xAtual + 32, centroY, 64, 64);
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(13);
      text(decada + "s", xAtual + 32, centroY);

      xAtual += 78;

      for (Evento evento : eventosDecada) {
        desenharCaixaEvento(evento, xAtual, eventoY);
        hitsEventos.add(new EventoHit(evento, xAtual, eventoY, EVENT_W, EVENT_H));
        xAtual += EVENT_W + CARD_GAP;
      }

      xAtual += GROUP_GAP;
    }

    conteudoW = max(width, xAtual - scrollX + 28);
    scrollX = constrain(scrollX, min(0, width - conteudoW), 0);
    textAlign(LEFT, BASELINE);
  }

  void desenharCaixaEvento(Evento evento, float boxX, float boxY) {
    boolean hover = mouseX >= boxX && mouseX <= boxX + EVENT_W && mouseY >= boxY && mouseY <= boxY + EVENT_H;

    fill(hover ? 255 : 248);
    stroke(hover ? 130 : 210);
    strokeWeight(1);
    rect(boxX, boxY, EVENT_W, EVENT_H, 8);

    fill(35);
    textAlign(LEFT, TOP);
    textSize(12);
    desenharTextoNegritoEvento(evento.nome, boxX + 10, boxY + 10, EVENT_W - 20, 34);

    fill(100);
    textSize(11);
    text(obterAnoEvento(evento), boxX + 10, boxY + 52);
  }

  void desenharMenuFiltro(float barY) {
    float menuW = 260;
    float menuX = width - menuW - 18;
    float menuH = obterAlturaMenuFiltro(barY);
    float menuY = obterYMenuFiltro(barY, menuH);
    float linhaH = 36;
    float listaY = menuY + 78;
    float listaH = menuH - 86;
    float conteudoH = decadas.size() * linhaH;
    float scrollMax = max(0, conteudoH - listaH);
    filtroScrollY = constrain(filtroScrollY, 0, scrollMax);

    fill(255);
    stroke(210);
    rect(menuX, menuY, menuW, menuH, 8);

    fill(35);
    textAlign(LEFT, TOP);
    textSize(13);
    text("Filtrar por decada", menuX + 14, menuY + 12);
    textAlign(RIGHT, TOP);
    text("x", menuX + menuW - 14, menuY + 12);

    stroke(225);
    line(menuX, menuY + 42, menuX + menuW, menuY + 42);

    fill(70);
    textAlign(LEFT, TOP);
    textSize(11);
    text("Selecionar todas", menuX + 14, menuY + 52);
    text("Limpar", menuX + 126, menuY + 52);

    clip(int(menuX), int(listaY), int(menuW), int(listaH));

    for (int i = 0; i < decadas.size(); i++) {
      int decada = decadas.get(i);
      float y = listaY + i * linhaH - filtroScrollY;

      if (y + linhaH < listaY || y > listaY + listaH) {
        continue;
      }

      fill(decadasVisiveis.get(i) ? 35 : 255);
      stroke(215);
      rect(menuX + 16, y + 8, 16, 16, 4);

      fill(35);
      textAlign(LEFT, TOP);
      textSize(12);
      text("Decada de " + decada, menuX + 44, y + 7);

      fill(235);
      noStroke();
      ellipse(menuX + menuW - 28, y + 16, 24, 24);
      fill(90);
      textAlign(CENTER, CENTER);
      text(contarEventosDecada(decada), menuX + menuW - 28, y + 16);
    }

    noClip();
    desenharScrollFiltro(menuX, listaY, menuW, listaH, conteudoH, scrollMax);
    textAlign(LEFT, BASELINE);
  }

  void desenharScrollFiltro(float menuX, float listaY, float menuW, float listaH, float conteudoH, float scrollMax) {
    if (scrollMax <= 0) {
      return;
    }

    float trackX = menuX + menuW - 10;
    float trackH = listaH;
    float thumbH = max(28, listaH * listaH / conteudoH);
    float thumbY = listaY + map(filtroScrollY, 0, scrollMax, 0, trackH - thumbH);

    fill(235);
    noStroke();
    rect(trackX, listaY, 5, trackH, 3);
    fill(120);
    rect(trackX, thumbY, 5, thumbH, 3);
  }

  void desenharPopupEvento() {
    fill(0, 90);
    noStroke();
    rect(0, 0, width, height);

    float popupW = min(720, width - 80);
    float popupH = min(600, height - 80);
    float px = (width - popupW) / 2;
    float py = (height - popupH) / 2;

    fill(255);
    rect(px, py, popupW, popupH, 10);
    limparAreasBlocosPopup();

    fill(235);
    noStroke();
    rect(px + 24, py + 18, 58, 24, 12);
    fill(35);
    textAlign(CENTER, CENTER);
    textSize(12);
    text(obterAnoEvento(eventoSelecionado), px + 53, py + 30);

    fill(235);
    rect(px + popupW - 54, py + 16, 34, 34, 16);
    fill(35);
    textSize(20);
    text("x", px + popupW - 37, py + 32);

    fill(20);
    textAlign(LEFT, TOP);
    textSize(22);
    desenharTextoNegritoEvento(eventoSelecionado.nome, px + 24, py + 58, popupW - 48, 48);

    stroke(225);
    line(px, py + 112, px + popupW, py + 112);

    float y = py + 138;
    desenharBlocoPopup(0, "Descricao", eventoSelecionado.descricao, px + 24, y, popupW - 48, 112);
    y += 132;

    float colW = (popupW - 64) / 2;
    desenharBlocoPopup(1, "Contexto", eventoSelecionado.contexto, px + 24, y, colW, 96);
    desenharBlocoPopup(2, "Duracao", eventoSelecionado.duracao, px + 40 + colW, y, colW, 96);
    y += 116;

    desenharBlocoPopup(3, "Localizacao geografica", eventoSelecionado.localizacao, px + 24, y, colW, 86);
    desenharBlocoPopup(4, "Instituicoes promotoras", eventoSelecionado.instituicoes, px + 40 + colW, y, colW, 86);
    y += 106;

    desenharBlocoPopup(5, "Atores historicos envolvidos", eventoSelecionado.atores, px + 24, y, popupW - 48, popupH - (y - py) - 24);

    textAlign(LEFT, BASELINE);
  }

  void desenharBlocoPopup(int indice, String titulo, String texto, float bx, float by, float bw, float bh) {
    fill(238, 239, 244);
    noStroke();
    rect(bx, by, bw, bh, 12);
    popupBlocoX[indice] = bx;
    popupBlocoY[indice] = by;
    popupBlocoW[indice] = bw;
    popupBlocoH[indice] = bh;

    fill(95);
    textAlign(LEFT, TOP);
    textSize(12);
    text(titulo, bx + 14, by + 12);

    fill(20);
    textSize(13);
    desenharTextoPopupComScroll(indice, limparSeparadores(texto), bx + 14, by + 34, bw - 28, bh - 42);
  }

  void desenharTextoPopupComScroll(int indice, String texto, float tx, float ty, float tw, float th) {
    float linhaH = 16;
    ArrayList<String> linhas = quebrarLinhasPopup(texto, tw);
    float conteudoH = max(linhaH, linhas.size() * linhaH);
    float scrollMax = max(0, conteudoH - th);
    popupConteudoH[indice] = conteudoH;
    popupScrollY[indice] = constrain(popupScrollY[indice], 0, scrollMax);

    clip(int(tx), int(ty), int(tw), int(th));

    for (int i = 0; i < linhas.size(); i++) {
      float linhaY = ty - popupScrollY[indice] + i * linhaH;

      if (linhaY + linhaH < ty || linhaY > ty + th) {
        continue;
      }

      text(linhas.get(i), tx, linhaY);
    }

    noClip();
    desenharScrollBlocoPopup(indice, tx, ty, tw, th, scrollMax);
  }

  void desenharScrollBlocoPopup(int indice, float tx, float ty, float tw, float th, float scrollMax) {
    if (scrollMax <= 0) {
      return;
    }

    float trackX = tx + tw - 5;
    float thumbH = max(18, th * th / popupConteudoH[indice]);
    float thumbY = ty + map(popupScrollY[indice], 0, scrollMax, 0, th - thumbH);

    fill(218);
    noStroke();
    rect(trackX, ty, 4, th, 2);
    fill(130);
    rect(trackX, thumbY, 4, thumbH, 2);
  }

  ArrayList<String> quebrarLinhasPopup(String texto, float maxW) {
    ArrayList<String> linhas = new ArrayList<String>();
    String[] paragrafos = split(texto, "\n");

    for (int p = 0; p < paragrafos.length; p++) {
      String[] palavras = splitTokens(paragrafos[p], " \t\r");
      String linhaAtual = "";

      for (int i = 0; i < palavras.length; i++) {
        String tentativa = linhaAtual.length() == 0 ? palavras[i] : linhaAtual + " " + palavras[i];

        if (textWidth(tentativa) <= maxW) {
          linhaAtual = tentativa;
        } else {
          if (linhaAtual.length() > 0) {
            linhas.add(linhaAtual);
          }

          linhaAtual = palavras[i];
        }
      }

      if (linhaAtual.length() > 0) {
        linhas.add(linhaAtual);
      }

      if (p < paragrafos.length - 1) {
        linhas.add("");
      }
    }

    if (linhas.size() == 0) {
      linhas.add("");
    }

    return linhas;
  }

  void limparAreasBlocosPopup() {
    for (int i = 0; i < TOTAL_BLOCOS_POPUP; i++) {
      popupBlocoX[i] = -1;
      popupBlocoY[i] = -1;
      popupBlocoW[i] = 0;
      popupBlocoH[i] = 0;
    }
  }

  boolean tratarMousePressed() {
    if (eventoSelecionado != null) {
      float popupW = min(720, width - 80);
      float popupH = min(600, height - 80);
      float px = (width - popupW) / 2;
      float py = (height - popupH) / 2;

      if (mouseButton == LEFT &&
        mouseX >= px + popupW - 54 &&
        mouseX <= px + popupW - 20 &&
        mouseY >= py + 16 &&
        mouseY <= py + 50) {
        eventoSelecionado = null;
      }

      return true;
    }

    if (escondida) {
      if (mouseButton == LEFT && mouseX >= width - 48 && mouseY >= height - 48) {
        escondida = false;
        return true;
      }

      return false;
    }

    float barY = obterBarY();
    if (filtroAberto) {
      boolean filtroTratou = tratarCliqueFiltro(barY);

      if (filtroTratou) {
        return true;
      }
    }

    if (mouseY < barY) {
      return false;
    }

    if (mouseButton == RIGHT) {
      Evento evento = eventoSobMouse();

      if (evento != null) {
        float cardX = constrain(mouseX - 90, 8, width - 190);
        float cardY = max(8, barY - 78);
        eventosMesaCards.add(new EventoMesaCard(cardX, cardY, evento));
      }

      return true;
    }

    if (mouseButton != LEFT) {
      return true;
    }

    if (clicouControles(barY)) {
      return true;
    }

    if (filtroAberto && tratarCliqueFiltro(barY)) {
      return true;
    }

    eventoPressionado = eventoSobMouse();
    arrastando = true;
    arrastou = false;
    dragStartX = mouseX;
    scrollStartX = scrollX;
    return true;
  }

  boolean tratarMouseDragged() {
    if (filtroScrollArrastando) {
      float barY = obterBarY();
      float menuH = obterAlturaMenuFiltro(barY);
      float menuY = obterYMenuFiltro(barY, menuH);
      float listaH = menuH - 86;
      float conteudoH = decadas.size() * 36;
      float scrollMax = max(0, conteudoH - listaH);
      float trackMovimento = max(1, listaH - max(28, listaH * listaH / conteudoH));
      float delta = mouseY - filtroMouseStartY;
      filtroScrollY = constrain(filtroScrollStartY + delta * scrollMax / trackMovimento, 0, scrollMax);
      return true;
    }

    if (!arrastando) {
      return false;
    }

    float delta = mouseX - dragStartX;
    if (abs(delta) > 3) {
      arrastou = true;
    }

    scrollX = scrollStartX + delta;
    return true;
  }

  void tratarMouseReleased() {
    filtroScrollArrastando = false;

    if (arrastando && !arrastou && eventoPressionado != null) {
      eventoSelecionado = eventoPressionado;
    }

    arrastando = false;
    eventoPressionado = null;
  }

  boolean clicouControles(float barY) {
    float filtroX = width - 108;
    float esconderX = width - 54;
    float yBtn = barY + 12;

    if (mouseX >= filtroX && mouseX <= filtroX + 44 && mouseY >= yBtn && mouseY <= yBtn + 30) {
      filtroAberto = !filtroAberto;
      return true;
    }

    if (mouseX >= esconderX && mouseX <= esconderX + 36 && mouseY >= yBtn && mouseY <= yBtn + 30) {
      escondida = true;
      filtroAberto = false;
      return true;
    }

    return false;
  }

  boolean tratarCliqueFiltro(float barY) {
    float menuW = 260;
    float menuX = width - menuW - 18;
    float menuH = obterAlturaMenuFiltro(barY);
    float menuY = obterYMenuFiltro(barY, menuH);
    float linhaH = 36;
    float listaY = menuY + 78;
    float listaH = menuH - 86;
    float conteudoH = decadas.size() * linhaH;
    float scrollMax = max(0, conteudoH - listaH);

    if (mouseX < menuX || mouseX > menuX + menuW || mouseY < menuY || mouseY > menuY + menuH) {
      filtroAberto = false;
      return false;
    }

    if (mouseY <= menuY + 42 && mouseX >= menuX + menuW - 36) {
      filtroAberto = false;
      return true;
    }

    if (mouseY >= menuY + 50 && mouseY <= menuY + 70) {
      if (mouseX >= menuX + 14 && mouseX <= menuX + 108) {
        selecionarTodasDecadas();
        return true;
      }

      if (mouseX >= menuX + 126 && mouseX <= menuX + 180) {
        limparDecadas();
        return true;
      }
    }

    if (scrollMax > 0 && mouseX >= menuX + menuW - 18 && mouseX <= menuX + menuW && mouseY >= listaY && mouseY <= listaY + listaH) {
      filtroScrollArrastando = true;
      filtroMouseStartY = mouseY;
      filtroScrollStartY = filtroScrollY;
      return true;
    }

    int indice = int((mouseY - listaY + filtroScrollY) / linhaH);

    if (indice >= 0 && indice < decadas.size()) {
      decadasVisiveis.set(indice, !decadasVisiveis.get(indice));
      return true;
    }

    return true;
  }

  Evento eventoSobMouse() {
    for (EventoHit hit : hitsEventos) {
      if (hit.contem(mouseX, mouseY)) {
        return hit.evento;
      }
    }

    return null;
  }

  ArrayList<Evento> eventosDaDecada(int decada) {
    ArrayList<Evento> resultado = new ArrayList<Evento>();

    for (Evento evento : eventosFonte) {
      if (obterDecadaEvento(evento) == decada) {
        resultado.add(evento);
      }
    }

    return resultado;
  }

  int indiceDecada(int decada) {
    for (int i = 0; i < decadas.size(); i++) {
      if (decadas.get(i) == decada) {
        return i;
      }
    }

    return -1;
  }

  int contarEventosDecada(int decada) {
    int total = 0;

    for (Evento evento : eventosFonte) {
      if (obterDecadaEvento(evento) == decada) {
        total++;
      }
    }

    return total;
  }

  void selecionarTodasDecadas() {
    for (int i = 0; i < decadasVisiveis.size(); i++) {
      decadasVisiveis.set(i, Boolean.TRUE);
    }
  }

  void limparDecadas() {
    for (int i = 0; i < decadasVisiveis.size(); i++) {
      decadasVisiveis.set(i, Boolean.FALSE);
    }
  }

  float obterBarY() {
    return height - BAR_H;
  }

  float obterAlturaMenuFiltro(float barY) {
    float alturaDesejada = 86 + min(6, max(1, decadas.size())) * 36;
    return min(alturaDesejada, max(130, barY - 18));
  }

  float obterYMenuFiltro(float barY, float menuH) {
    return max(10, barY - menuH - 8);
  }

  void abrirPopup(Evento evento) {
    eventoSelecionado = evento;

    for (int i = 0; i < TOTAL_BLOCOS_POPUP; i++) {
      popupScrollY[i] = 0;
    }
  }

  boolean tratarMouseWheel(float quantidade) {
    if (eventoSelecionado != null) {
      return tratarMouseWheelPopup(quantidade);
    }

    if (filtroAberto && tratarMouseWheelFiltro(quantidade)) {
      return true;
    }

    return false;
  }

  boolean tratarMouseWheelPopup(float quantidade) {
    for (int i = 0; i < TOTAL_BLOCOS_POPUP; i++) {
      if (mouseX >= popupBlocoX[i] &&
        mouseX <= popupBlocoX[i] + popupBlocoW[i] &&
        mouseY >= popupBlocoY[i] &&
        mouseY <= popupBlocoY[i] + popupBlocoH[i]) {
        float viewportH = max(1, popupBlocoH[i] - 42);
        float scrollMax = max(0, popupConteudoH[i] - viewportH);

        if (scrollMax > 0) {
          popupScrollY[i] = constrain(popupScrollY[i] + quantidade * 18, 0, scrollMax);
        }

        return true;
      }
    }

    return true;
  }

  boolean tratarMouseWheelFiltro(float quantidade) {
    float barY = obterBarY();
    float menuW = 260;
    float menuX = width - menuW - 18;
    float menuH = obterAlturaMenuFiltro(barY);
    float menuY = obterYMenuFiltro(barY, menuH);
    float listaY = menuY + 78;
    float listaH = menuH - 86;
    float conteudoH = decadas.size() * 36;
    float scrollMax = max(0, conteudoH - listaH);

    if (mouseX < menuX ||
      mouseX > menuX + menuW ||
      mouseY < menuY ||
      mouseY > menuY + menuH) {
      return false;
    }

    if (scrollMax > 0 && mouseY >= listaY && mouseY <= listaY + listaH) {
      filtroScrollY = constrain(filtroScrollY + quantidade * 24, 0, scrollMax);
    }

    return true;
  }
}

class EventoHit {
  Evento evento;
  float x;
  float y;
  float w;
  float h;

  EventoHit(Evento evento, float x, float y, float w, float h) {
    this.evento = evento;
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  boolean contem(float px, float py) {
    return px >= x && px <= x + w && py >= y && py <= y + h;
  }
}

String obterAnoEvento(Evento evento) {
  int ano = extrairAnoEvento(evento);

  if (ano == -1) {
    return "?";
  }

  return str(ano);
}

int extrairAnoEvento(Evento evento) {
  String[] achado = match(evento.duracao, "\\d{4}");

  if (achado != null) {
    return int(achado[0]);
  }

  return -1;
}

int obterDecadaEvento(Evento evento) {
  int ano = extrairAnoEvento(evento);

  if (ano <= 0) {
    return -1;
  }

  return (ano / 10) * 10;
}

String limparSeparadores(String texto) {
  if (texto == null) {
    return "";
  }

  return texto.replace("; 1", "\n").replace(".;", ".\n").replace("  ", " ");
}

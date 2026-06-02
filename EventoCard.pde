class EventoMesaCard {
  float x;
  float y;
  float w;
  float h;
  Evento evento;

  EventoMesaCard(float x, float y, Evento evento) {
    this.x = x;
    this.y = y;
    this.w = 180;
    this.h = 70;
    this.evento = evento;
  }

  void desenhar() {
    fill(0, 25);
    noStroke();
    rect(x + 3, y + 3, w, h, 6);

    fill(255);
    stroke(160);
    strokeWeight(1);
    rect(x, y, w, h, 6);

    fill(35);
    textAlign(LEFT, TOP);
    textSize(12);
    desenharTextoNegritoEvento(evento.nome, x + 10, y + 10, w - 20, 32);

    fill(95);
    textSize(11);
    text(obterAnoEvento(evento), x + 10, y + 48);
    textAlign(LEFT, BASELINE);
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }
}

void desenharEventoCardsMesa() {
  for (EventoMesaCard card : eventosMesaCards) {
    card.desenhar();
  }
}

boolean iniciarInteracaoComEventoCards() {
  for (int i = eventosMesaCards.size() - 1; i >= 0; i--) {
    EventoMesaCard card = eventosMesaCards.get(i);

    if (card.isMouseOver()) {
      eventoCardArrastado = card;
      eventoCardPressionado = card;
      eventoCardArrastou = false;
      eventoArrastoStartX = mouseX;
      eventoArrastoStartY = mouseY;
      eventoArrastoOffsetX = mouseX - card.x;
      eventoArrastoOffsetY = mouseY - card.y;
      trazerEventoCardParaFrente(i);
      return true;
    }
  }

  return false;
}

void arrastarEventoCardAtivo() {
  if (eventoCardArrastado == null) {
    return;
  }

  if (dist(mouseX, mouseY, eventoArrastoStartX, eventoArrastoStartY) > 3) {
    eventoCardArrastou = true;
  }

  float limiteInferior = linhaTempoEventos.obterBarY() - eventoCardArrastado.h - 4;
  eventoCardArrastado.x = constrain(mouseX - eventoArrastoOffsetX, 0, width - eventoCardArrastado.w);
  eventoCardArrastado.y = constrain(mouseY - eventoArrastoOffsetY, 0, max(0, limiteInferior));
}

void finalizarInteracaoComEventoCard() {
  if (eventoCardPressionado != null && !eventoCardArrastou) {
    linhaTempoEventos.abrirPopup(eventoCardPressionado.evento);
  }

  eventoCardArrastado = null;
  eventoCardPressionado = null;
  eventoCardArrastou = false;
}

void trazerEventoCardParaFrente(int index) {
  EventoMesaCard card = eventosMesaCards.remove(index);
  eventosMesaCards.add(card);
}

void desenharTextoNegritoEvento(String texto, float textoX, float textoY, float textoW, float textoH) {
  text(texto, textoX, textoY, textoW, textoH);
  text(texto, textoX + 0.6, textoY, textoW, textoH);
}

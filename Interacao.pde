void keyPressed() {
  if (produtos.size() == 0) {
    return;
  }

  if (keyCode == RIGHT) {
    produtoSelecionadoIndex = (produtoSelecionadoIndex + 1) % produtos.size();
  } else if (keyCode == LEFT) {
    produtoSelecionadoIndex--;

    if (produtoSelecionadoIndex < 0) {
      produtoSelecionadoIndex = produtos.size() - 1;
    }
  }
}

void mousePressed() {
  if (linhaTempoEventos.tratarMousePressed()) {
    return;
  }

  if (mouseButton == RIGHT) {
    alternarMenuSlots(mouseX, mouseY);
    return;
  }

  if (mouseButton != LEFT) {
    return;
  }

  if (!menuVisivel && iniciarInteracaoComEventoCards()) {
    return;
  }

  if (menuVisivel) {
    tratarCliqueNoMenuSlots();
  } else {
    iniciarInteracaoComCards();
  }
}

void mouseDragged() {
  if (linhaTempoEventos.tratarMouseDragged()) {
    return;
  }

  if (menuVisivel) {
    return;
  }

  if (eventoCardArrastado != null) {
    arrastarEventoCardAtivo();
  } else if (cardRedimensionado != null) {
    cardRedimensionado.redimensionar(mouseX - cardRedimensionado.x + resizeOffsetX, mouseY - cardRedimensionado.y + resizeOffsetY);
  } else if (cardArrastado != null) {
    cardArrastado.x = mouseX - arrastoOffsetX;
    cardArrastado.y = mouseY - arrastoOffsetY;
  }
}

void mouseReleased() {
  linhaTempoEventos.tratarMouseReleased();
  finalizarInteracaoComEventoCard();
  cardArrastado = null;
  cardRedimensionado = null;
}

void mouseWheel(processing.event.MouseEvent event) {
  if (linhaTempoEventos.tratarMouseWheel(event.getCount())) {
    return;
  }
}

void tratarCliqueNoMenuSlots() {
  Slot slotClicado = encontrarSlotSobMouse();

  if (slotClicado != null && slotClicado.temProduto()) {
    Produto p = produtos.get(slotClicado.indexProdutoAtribuido);
    cardsAtivos.add(new Card(slotClicado.x, slotClicado.y, slotClicado.w, slotClicado.h, p));
  }

  menuVisivel = false;
}

void iniciarInteracaoComCards() {
  for (int i = cardsAtivos.size() - 1; i >= 0; i--) {
    Card c = cardsAtivos.get(i);

    if (c.isCloseHovered()) {
      cardsAtivos.remove(i);
      return;
    }

    if (c.isResizeHovered()) {
      cardRedimensionado = c;
      resizeOffsetX = c.x + c.w - mouseX;
      resizeOffsetY = c.y + c.h - mouseY;
      trazerCardParaFrente(i);
      return;
    }

    if (c.isDetailHovered()) {
      c.alternarDetalhes();
      trazerCardParaFrente(i);
      return;
    }

    if (c.alternarCampoDetalheSobMouse()) {
      trazerCardParaFrente(i);
      return;
    }

    if (c.isMouseOver()) {
      cardArrastado = c;
      arrastoOffsetX = mouseX - c.x;
      arrastoOffsetY = mouseY - c.y;
      trazerCardParaFrente(i);
      return;
    }
  }
}

void trazerCardParaFrente(int index) {
  Card c = cardsAtivos.remove(index);
  cardsAtivos.add(c);
}

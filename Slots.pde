class Slot {
  float x;
  float y;
  float w;
  float h;
  int indexProdutoAtribuido = -1;

  Slot(float x, float y, float w, float h) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
  }

  void desenhar() {
    if (!temProduto()) {
      return;
    }

    Produto p = produtos.get(indexProdutoAtribuido);

    if (isMouseOver()) {
      fill(255);
      stroke(180);
    } else {
      fill(250);
      stroke(220);
    }

    strokeWeight(1);
    rect(x, y, w, h, 6);

    desenharConteudoInterno(p, x, y, w, h);
  }

  boolean temProduto() {
    return indexProdutoAtribuido != -1;
  }

  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + w && mouseY >= y && mouseY <= y + h;
  }
}

void inicializarSlots() {
  for (int i = 0; i < slots.length; i++) {
    slots[i] = new Slot(0, 0, 130, 100);
  }
}

void alternarMenuSlots(float x, float y) {
  menuVisivel = !menuVisivel;

  if (menuVisivel) {
    posicionarSlotsAoRedor(x, y, 50);
    sortearProdutosParaSlots();
  }
}

void desenharMenuSlots() {
  fill(0, 20);
  noStroke();
  rect(0, 0, width, height);

  for (Slot slot : slots) {
    slot.desenhar();
  }
}

Slot encontrarSlotSobMouse() {
  for (Slot slot : slots) {
    if (slot.isMouseOver()) {
      return slot;
    }
  }

  return null;
}

void posicionarSlotsAoRedor(float mx, float my, float gap) {
  float w = slots[0].w;
  float h = slots[0].h;
  float meioX = mx - w/2;
  float meioY = my - h/2;
  float distanciaEntreSlots = 12;

  // Dois slots acima, alinhados ao centro.
  slots[0].x = meioX;
  slots[0].y = my - gap - h;

  slots[1].x = meioX;
  slots[1].y = slots[0].y - h - distanciaEntreSlots;

  // Dois slots a direita, alinhados na horizontal.
  slots[2].x = mx + gap;
  slots[2].y = meioY;

  slots[3].x = slots[2].x + w + distanciaEntreSlots;
  slots[3].y = meioY;

  // Dois slots abaixo, alinhados ao centro.
  slots[4].x = meioX;
  slots[4].y = my + gap;

  slots[5].x = meioX;
  slots[5].y = slots[4].y + h + distanciaEntreSlots;

  // Dois slots a esquerda, alinhados na horizontal.
  slots[6].x = mx - gap - w;
  slots[6].y = meioY;

  slots[7].x = slots[6].x - w - distanciaEntreSlots;
  slots[7].y = meioY;

  manterSlotsDentroDaTela();
}

void manterSlotsDentroDaTela() {
  for (Slot slot : slots) {
    slot.x = constrain(slot.x, 8, width - slot.w - 8);
    slot.y = constrain(slot.y, 8, height - slot.h - 8);
  }
}

void sortearProdutosParaSlots() {
  ArrayList<Integer> indicesDisponiveis = listarIndicesProdutosDisponiveis();

  for (int i = 0; i < slots.length; i++) {
    if (indicesDisponiveis.size() == 0) {
      slots[i].indexProdutoAtribuido = -1;
      continue;
    }

    int posicaoSorteada = int(random(indicesDisponiveis.size()));
    slots[i].indexProdutoAtribuido = indicesDisponiveis.get(posicaoSorteada);
    indicesDisponiveis.remove(posicaoSorteada);
  }
}

ArrayList<Integer> listarIndicesProdutosDisponiveis() {
  ArrayList<Integer> indicesDisponiveis = new ArrayList<Integer>();

  for (int i = 0; i < produtos.size(); i++) {
    if (!produtoJaEstaNaMesa(produtos.get(i))) {
      indicesDisponiveis.add(i);
    }
  }

  return indicesDisponiveis;
}

boolean produtoJaEstaNaMesa(Produto produto) {
  for (Card c : cardsAtivos) {
    if (c.p.id == produto.id) {
      return true;
    }
  }

  return false;
}

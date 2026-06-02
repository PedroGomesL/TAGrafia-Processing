void desenharConteudoInterno(Produto p, float x, float y, float w, float h) {
  float thumbW = w - 10;
  float thumbH = h - 35;

  if (p.imagensRelacionadas.size() > 0) {
    desenharImagemProdutoCompacta(p.imagensRelacionadas.get(0), x + 5, y + 5, thumbW, thumbH);
  } else {
    fill(235);
    noStroke();
    rect(x + 5, y + 5, thumbW, thumbH, 4);
  }

  fill(40);
  textSize(10);
  textAlign(CENTER, TOP);
  text(p.nome, x + 5, y + h - 25, w - 10, 25);
  textAlign(LEFT, BASELINE);
}

void desenharImagemProdutoCompacta(PImage img, float x, float y, float maxW, float maxH) {
  float renderW = maxW;
  float renderH = (maxW / img.width) * img.height;

  if (renderH > maxH) {
    renderH = maxH;
    renderW = (maxH / img.height) * img.width;
  }

  image(img, x + (maxW - renderW)/2, y + (maxH - renderH)/2, renderW, renderH);
}

void desenharDetalheProduto(Produto p) {
  fill(30);

  textSize(28);
  text(p.nome, 50, 60);
  textSize(14);
  fill(100);
  text("ID: " + p.id + " | Ano: " + p.datacao + " | Design: " + p.autoria, 50, 90);

  if (p.imagensRelacionadas.size() > 0 && p.imagensRelacionadas.get(0) != null) {
    PImage imgPrincipal = p.imagensRelacionadas.get(0);
    image(imgPrincipal, 50, 120, 400, (400.0/imgPrincipal.width) * imgPrincipal.height);
  } else {
    fill(200);
    noStroke();
    rect(50, 120, 400, 300);
    fill(100);
    textAlign(CENTER, CENTER);
    text("Imagem Indisponivel\nou nao vinculada", 250, 270);
    textAlign(LEFT, BASELINE);
  }

  fill(30);
  textSize(16);
  text("Material: " + p.material, 500, 120);
  text("Tipo: " + p.tipo, 500, 150);
  text("Localizacao: " + p.localizacao, 500, 180);

  textSize(14);
  textLeading(20);
  text("Condicionantes:\n" + p.condicionantes, 500, 230, 450, 200);
}

void desenharProdutoFocado() {
  if (produtoFocado == null) {
    return;
  }

  fill(40);
  textSize(24);
  textAlign(CENTER, CENTER);
  text(produtoFocado.nome, width/2, 80);

  if (produtoFocado.imagensRelacionadas.size() > 0) {
    PImage img = produtoFocado.imagensRelacionadas.get(0);

    float maxH = 450;
    float maxW = 600;
    float renderW = maxW;
    float renderH = (maxW / img.width) * img.height;

    if (renderH > maxH) {
      renderH = maxH;
      renderW = (maxH / img.height) * img.width;
    }

    imageMode(CENTER);
    image(img, width/2, height/2 + 20, renderW, renderH);
    imageMode(CORNER);
  } else {
    rectMode(CENTER);
    fill(220);
    noStroke();
    rect(width/2, height/2 + 20, 400, 300, 8);
    fill(120);
    textSize(14);
    text("Imagem nao disponivel", width/2, height/2 + 20);
    rectMode(CORNER);
  }

  textAlign(LEFT, BASELINE);
}

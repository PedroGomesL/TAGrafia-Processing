import processing.javafx.*;

void settings() {
  fullScreen(FX2D);
}

void setup() {
  iniciarBancoDeDados();
  inicializarSistemaFiltros();
  inicializarVisualizacoes();

  if (bancoCarregadoComSucesso) {
    iniciarBancoDeImagens();
  }
  inicializarPainelProduto();
}

void draw() {
  background(240);
  desenharVisualizacaoAtual();
  desenharPainelProduto();
  desenharFiltroUI();
}

void mousePressed() {
  if (mouseButton == LEFT && filtroMousePressed()) {
    return;
  }
  if (mouseButton == LEFT && painelProdutoMousePressed()) {
    return;
  }
  if (mouseButton == LEFT && visualizacaoAtualMousePressed()) {
    return;
  }
}

void mouseDragged() {
  if (filtroMouseDragged()) {
    return;
  }
  if (visualizacaoAtualMouseDragged()) {
    return;
  }
}

void mouseReleased() {
  filtroMouseReleased();
  visualizacaoAtualMouseReleased();
}

void mouseWheel(processing.event.MouseEvent evento) {
  if (painelProdutoMouseWheel(evento)) {
    return;
  }
  filtroMouseWheel(evento);
}

void keyPressed() {
  if (painelProdutoKeyPressed(key, keyCode)) {
    return;
  }
  if (filtroKeyPressed(key, keyCode)) {
    return;
  }
}

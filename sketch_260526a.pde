import processing.javafx.*;

void settings() {
  fullScreen(FX2D);
}

void setup() {
  iniciarBancoDeDados();
  inicializarSistemaFiltros();
  inicializarVisualizacaoCircular();

  if (bancoCarregadoComSucesso) {
    iniciarBancoDeImagens();
  }
  inicializarPainelProduto();
}

void draw() {
  background(240);
  desenharVisualizacaoCircular();
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
  if (mouseButton == LEFT && visualizacaoCircularMousePressed()) {
    return;
  }
}

void mouseDragged() {
  if (filtroMouseDragged()) {
    return;
  }
  if (visualizacaoCircularMouseDragged()) {
    return;
  }
}

void mouseReleased() {
  filtroMouseReleased();
  visualizacaoCircularMouseReleased();
}

void mouseWheel(processing.event.MouseEvent evento) {
  if (painelProdutoMouseWheel(evento)) {
    return;
  }
  filtroMouseWheel(evento);
}

void keyPressed() {
  if (filtroKeyPressed(key, keyCode)) {
    return;
  }
}

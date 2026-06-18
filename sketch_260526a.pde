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
}

void draw() {
  background(240);
  desenharVisualizacaoCircular();
  desenharFiltroUI();
}

void mousePressed() {
  if (mouseButton == LEFT && filtroMousePressed()) {
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
  filtroMouseWheel(evento);
}

void keyPressed() {
  if (filtroKeyPressed(key, keyCode)) {
    return;
  }
}

import processing.javafx.*;
import processing.pdf.*;
import processing.svg.*;

final int LAYOUT_FILTRO_W = 255;
final int LAYOUT_VISUAL_W_BASE = 1100;
final int LAYOUT_PAINEL_PRODUTO_W = 455;
final int LAYOUT_VISUAL_W_MIN = 320;
final int LAYOUT_PAINEL_PRODUTO_W_MIN = 300;

float escalaLayout() {
  float espacoSemFiltro = max(1, width - LAYOUT_FILTRO_W);
  float larguraDesejada = LAYOUT_VISUAL_W_BASE + LAYOUT_PAINEL_PRODUTO_W;
  return min(1.0f, espacoSemFiltro / larguraDesejada);
}

float xPainelProdutoLayout() {
  return LAYOUT_FILTRO_W + larguraVisualLayout();
}

float larguraVisualLayout() {
  return max(LAYOUT_VISUAL_W_MIN, width - LAYOUT_FILTRO_W - larguraPainelProdutoLayout());
}

float larguraPainelProdutoLayout() {
  float larguraEscalada = LAYOUT_PAINEL_PRODUTO_W * escalaLayout();
  float larguraMaxima = max(LAYOUT_PAINEL_PRODUTO_W_MIN, width - LAYOUT_FILTRO_W - LAYOUT_VISUAL_W_MIN);
  return constrain(larguraEscalada, LAYOUT_PAINEL_PRODUTO_W_MIN, larguraMaxima);
}

float direitaVisualLayout() {
  return LAYOUT_FILTRO_W + larguraVisualLayout();
}

float larguraTimelineLayout() {
  return max(220, larguraVisualLayout() - 8);
}

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

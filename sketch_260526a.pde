import processing.javafx.*;
import processing.pdf.*;
import processing.svg.*;

final int LAYOUT_FILTRO_W = 255;
final int LAYOUT_VISUAL_W_BASE = 1100;
final int LAYOUT_PAINEL_PRODUTO_W = 455;
final int LAYOUT_VISUAL_W_MIN = 320;
final int LAYOUT_PAINEL_PRODUTO_W_MIN = 300;

float escalaLayout() {
  float espacoSemFiltro = max(1, espacoConteudoLayout());
  float larguraDesejada = LAYOUT_VISUAL_W_BASE + LAYOUT_PAINEL_PRODUTO_W;
  return min(1.0f, espacoSemFiltro / larguraDesejada);
}

float espacoConteudoLayout() {
  return max(0, width - LAYOUT_FILTRO_W);
}

float larguraVisualMinimaLayout() {
  float espaco = espacoConteudoLayout();
  float minimoCombinado = LAYOUT_VISUAL_W_MIN + LAYOUT_PAINEL_PRODUTO_W_MIN;
  if (espaco < minimoCombinado) {
    return constrain(espaco * 0.52f, 180, LAYOUT_VISUAL_W_MIN);
  }
  return LAYOUT_VISUAL_W_MIN;
}

float larguraPainelProdutoMinimaLayout() {
  float espaco = espacoConteudoLayout();
  float minimoCombinado = LAYOUT_VISUAL_W_MIN + LAYOUT_PAINEL_PRODUTO_W_MIN;
  if (espaco < minimoCombinado) {
    return constrain(espaco - larguraVisualMinimaLayout(), 160, LAYOUT_PAINEL_PRODUTO_W_MIN);
  }
  return LAYOUT_PAINEL_PRODUTO_W_MIN;
}

float xPainelProdutoLayout() {
  return LAYOUT_FILTRO_W + larguraVisualLayout();
}

float larguraVisualLayout() {
  return max(0, espacoConteudoLayout() - larguraPainelProdutoLayout());
}

float larguraPainelProdutoLayout() {
  float espaco = espacoConteudoLayout();
  float larguraVisualMinima = larguraVisualMinimaLayout();
  float larguraEscalada = LAYOUT_PAINEL_PRODUTO_W * escalaLayout();
  float larguraMinima = min(larguraPainelProdutoMinimaLayout(), max(0, espaco - larguraVisualMinima));
  float larguraMaxima = max(larguraMinima, espaco - larguraVisualMinima);
  return constrain(larguraEscalada, larguraMinima, larguraMaxima);
}

float direitaVisualLayout() {
  return LAYOUT_FILTRO_W + larguraVisualLayout();
}

float larguraTimelineLayout() {
  return max(0, larguraVisualLayout() - 8);
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
  desenharBotaoTemaClaroPrototipo();
  desenharFiltroUI();
}

void mousePressed() {
  if (mouseButton == LEFT && filtroMousePressed()) {
    return;
  }
  if (mouseButton == LEFT && temaClaroPrototipoMousePressed(mouseX, mouseY)) {
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

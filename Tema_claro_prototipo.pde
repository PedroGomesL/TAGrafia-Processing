boolean modoClaroPrototipo = false;

final color TEMA_FUNDO_VISUAL_ESCURO = #111111;
final color TEMA_FUNDO_VISUAL_CLARO = #F3F1EA;
final color TEMA_LINHA_VISUAL_ESCURO = #FFFFFF;
final color TEMA_LINHA_VISUAL_CLARO = #111111;
final color TEMA_TIMELINE_ESCURO = #505050;
final color TEMA_TIMELINE_CLARO = #D7D2C5;
final color TEMA_TIMELINE_HACHURA_ESCURO = #202020;
final color TEMA_TIMELINE_HACHURA_CLARO = #B08A00;

color temaCorFundoVisualPrototipo() {
  return modoClaroPrototipo ? TEMA_FUNDO_VISUAL_CLARO : TEMA_FUNDO_VISUAL_ESCURO;
}

color temaCorLinhaVisualPrototipo() {
  return modoClaroPrototipo ? TEMA_LINHA_VISUAL_CLARO : TEMA_LINHA_VISUAL_ESCURO;
}

color temaCorTextoVisualPrototipo() {
  return temaCorLinhaVisualPrototipo();
}

color temaCorTimelineFundoPrototipo() {
  return modoClaroPrototipo ? TEMA_TIMELINE_CLARO : TEMA_TIMELINE_ESCURO;
}

color temaCorTimelineHachuraPrototipo() {
  return modoClaroPrototipo ? TEMA_TIMELINE_HACHURA_CLARO : TEMA_TIMELINE_HACHURA_ESCURO;
}

void desenharBotaoTemaClaroPrototipo() {
  float cx = temaClaroBotaoCentroX();
  float cy = temaClaroBotaoCentroY();
  float d = temaClaroBotaoDiametro();

  pushStyle();
  stroke(modoClaroPrototipo ? #FFFFFF : #000000);
  strokeWeight(max(1, 1.2f * escalaLayout()));
  fill(modoClaroPrototipo ? #111111 : #FFFFFF);
  ellipse(cx, cy, d, d);

  if (modoClaroPrototipo) {
    noStroke();
    fill(#FFFFFF);
    ellipse(cx - d * 0.08f, cy, d * 0.42f, d * 0.42f);
    fill(#111111);
    ellipse(cx + d * 0.08f, cy - d * 0.04f, d * 0.42f, d * 0.42f);
  } else {
    stroke(#000000);
    strokeWeight(max(1, 1.1f * escalaLayout()));
    noFill();
    ellipse(cx, cy, d * 0.34f, d * 0.34f);
    for (int i = 0; i < 8; i++) {
      float a = i * TWO_PI / 8.0f;
      line(cx + cos(a) * d * 0.26f, cy + sin(a) * d * 0.26f, cx + cos(a) * d * 0.39f, cy + sin(a) * d * 0.39f);
    }
  }
  popStyle();
}

boolean temaClaroPrototipoMousePressed(float mx, float my) {
  if (!clicouBotaoTemaClaroPrototipo(mx, my)) {
    return false;
  }

  modoClaroPrototipo = !modoClaroPrototipo;
  return true;
}

boolean clicouBotaoTemaClaroPrototipo(float mx, float my) {
  float d = temaClaroBotaoDiametro();
  return dist(mx, my, temaClaroBotaoCentroX(), temaClaroBotaoCentroY()) <= d * 0.75f;
}

float temaClaroBotaoCentroX() {
  return botaoVisualizacaoX() + 16;
}

float temaClaroBotaoCentroY() {
  return botaoVisualizacaoY() + botaoVisualizacaoH() + 14;
}

float temaClaroBotaoDiametro() {
  return 14;
}

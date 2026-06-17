import processing.javafx.*;

ArrayList<Produto> produtos = new ArrayList<Produto>();
ArrayList<Evento> eventos = new ArrayList<Evento>();
ArrayList<Escola> escolas = new ArrayList<Escola>();
ArrayList<ImagemProduto> bancoImagens = new ArrayList<ImagemProduto>();
ArrayList<EventoMesaCard> eventosMesaCards = new ArrayList<EventoMesaCard>();

int produtoSelecionadoIndex = 0;
boolean menuVisivel = false;
Produto produtoFocado = null;
LinhaTempoEventos linhaTempoEventos;

Slot[] slots = new Slot[8];
ArrayList<Card> cardsAtivos = new ArrayList<Card>();
Card cardArrastado = null;
Card cardRedimensionado = null;
EventoMesaCard eventoCardArrastado = null;
EventoMesaCard eventoCardPressionado = null;
float arrastoOffsetX;
float arrastoOffsetY;
float resizeOffsetX;
float resizeOffsetY;
float eventoArrastoOffsetX;
float eventoArrastoOffsetY;
float eventoArrastoStartX;
float eventoArrastoStartY;
boolean eventoCardArrastou = false;

void setup() {
  size(1024, 768, FX2D);

  carregarBancosDeDados();
  carregarBancoDeImagens();
  inicializarSlots();
  linhaTempoEventos = new LinhaTempoEventos(eventos);
}

void draw() {
  background(240);

  desenharMensagemInicial();
  desenharCardsAtivos();
  desenharEventoCardsMesa();

  if (menuVisivel) {
    desenharMenuSlots();
  }

  linhaTempoEventos.desenhar();
}

void desenharMensagemInicial() {
  if (cardsAtivos.size() > 0 || menuVisivel) {
    return;
  }

  fill(150);
  textSize(16);
  textAlign(CENTER, CENTER);
  text("Clique com o botao DIREITO em qualquer lugar para abrir o menu.\nArraste os cards para organizar sua mesa.", width/2, height/2);
  textAlign(LEFT, BASELINE);
}

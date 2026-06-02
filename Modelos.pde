class Produto {
  int id;
  String nome;
  String tipo;
  String material;
  String datacao;
  String localizacao;
  String autoria;
  String condicionantes;
  String numeroExemplares;
  String tecnicaComposicao;
  String materiais;
  String estetico;
  String tecnicasConstrucao;

  ArrayList<PImage> imagensRelacionadas;

  Produto(TableRow row) {
    this.id = row.getInt("ID");
    this.nome = row.getString("Nome");
    this.tipo = row.getString("Tipo");
    this.material = row.getString("Material");
    this.datacao = row.getString("Datação");
    this.localizacao = row.getString("Localização Geográfica");
    this.autoria = row.getString("Autoria");
    this.condicionantes = row.getString("Condicionantes Industriais/Econômicos");
    this.numeroExemplares = row.getString("Número de exemplares");
    this.tecnicaComposicao = row.getString("Técnica de Composição");
    this.materiais = row.getString("Materiais");
    this.estetico = row.getString("Estético");
    this.tecnicasConstrucao = row.getString("Técnicas de construção/Funcionalidades");
    this.imagensRelacionadas = new ArrayList<PImage>();
  }
}

class Evento {
  int id;
  String nome;
  String contexto;
  String duracao;
  String localizacao;
  String atores;
  String instituicoes;
  String descricao;

  Evento(TableRow row) {
    this.id = row.getInt("ID");
    this.nome = row.getString("Nome / Título do Evento");
    this.contexto = row.getString("Contexto");
    this.duracao = row.getString("Duração");
    this.localizacao = row.getString("Localização Geográfica");
    this.atores = row.getString("Atores Históricos Envolvidos");
    this.instituicoes = row.getString("Instituições Promotoras");
    this.descricao = row.getString("Descrição");
  }
}

class Escola {
  int id;
  String escola;
  String contexto;
  String fases;
  String principaisNomes;
  String metodologia;
  String materiaisUsados;
  String principaisObras;

  Escola(TableRow row) {
    this.id = row.getInt("id");
    this.escola = row.getString("Escola");
    this.contexto = row.getString("Contexto");
    this.fases = row.getString("Fases");
    this.principaisNomes = row.getString("Principais nomes");
    this.metodologia = row.getString("Metodologia de Ensino");
    this.materiaisUsados = row.getString("Materiais usados");
    this.principaisObras = row.getString("Principais obras");
  }
}

class ImagemProduto {
  String idBanco;
  int idProduto;
  PImage img;

  ImagemProduto(int idProduto, int indiceImagem, String extensao) {
    this.idProduto = idProduto;

    String idFormatado = nf(idProduto, 2);
    String indiceFormatado = nf(indiceImagem, 2);
    this.idBanco = idFormatado + "_" + indiceFormatado;
    this.img = loadImage("Banco de imagens/" + this.idBanco + extensao);
  }
}

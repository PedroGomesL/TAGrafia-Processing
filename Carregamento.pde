void carregarBancosDeDados() {
  carregarProdutos();
  carregarEventos();
  carregarEscolas();
}

void carregarProdutos() {
  println("Iniciando leitura de Produtos...");
  Table tabProdutos = loadTable("Produtos.csv", "header, csv");

  if (tabProdutos == null) {
    println("> Erro ao carregar Produtos.csv");
    return;
  }

  for (TableRow row : tabProdutos.rows()) {
    produtos.add(new Produto(row));
  }

  println("> Produtos carregados com sucesso!");
}

void carregarEventos() {
  println("Iniciando leitura de Eventos...");
  Table tabEventos = loadTable("Eventos_contexto.csv", "header, csv");

  if (tabEventos == null) {
    println("> Erro ao carregar Eventos_contexto.csv");
    return;
  }

  for (TableRow row : tabEventos.rows()) {
    eventos.add(new Evento(row));
  }

  println("> Eventos carregados com sucesso!");
}

void carregarEscolas() {
  println("Iniciando leitura de Escolas...");
  Table tabEscolas = loadTable("Escolas.csv", "header, csv");

  if (tabEscolas == null) {
    println("> Erro ao carregar Escolas.csv");
    return;
  }

  for (TableRow row : tabEscolas.rows()) {
    escolas.add(new Escola(row));
  }

  println("> Escolas carregadas com sucesso!");
}

void carregarBancoDeImagens() {
  println("Iniciando varredura automatica do Banco de Imagens...");
  int totalImagensEncontradas = 0;

  for (Produto p : produtos) {
    totalImagensEncontradas += carregarImagensDoProduto(p);
  }

  println("> Sucesso! Varredura concluida. Total de imagens vinculadas: " + totalImagensEncontradas);
}

int carregarImagensDoProduto(Produto produto) {
  int total = 0;
  int indice = 1;

  while (true) {
    String caminhoRelativo = buscarCaminhoImagemProduto(produto.id, indice);

    if (caminhoRelativo == null) {
      return total;
    }

    PImage img = loadImage(caminhoRelativo);
    produto.imagensRelacionadas.add(img);
    total++;
    indice++;
  }
}

String buscarCaminhoImagemProduto(int idProduto, int indiceImagem) {
  String idFormatado = nf(idProduto, 2);
  String indiceFormatado = nf(indiceImagem, 2);
  String[] separadores = { "_", "." };
  String[] extensoes = { ".jpg", ".jpeg", ".png" };

  for (String separador : separadores) {
    for (String extensao : extensoes) {
      String nomeArquivo = idFormatado + separador + indiceFormatado + extensao;
      String caminhoRelativo = "Banco de imagens/" + nomeArquivo;
      java.io.File arquivo = new java.io.File(dataPath(caminhoRelativo));

      if (arquivo.exists()) {
        return caminhoRelativo;
      }
    }
  }

  return null;
}

void vincularImagensAosProdutos() {
  println("Vinculando imagens aos produtos...");

  for (ImagemProduto imgBanco : bancoImagens) {
    Produto produto = buscarProdutoPorId(imgBanco.idProduto);

    if (produto != null) {
      produto.imagensRelacionadas.add(imgBanco.img);
    }
  }
}

Produto buscarProdutoPorId(int idProduto) {
  for (Produto p : produtos) {
    if (p.id == idProduto) {
      return p;
    }
  }

  return null;
}

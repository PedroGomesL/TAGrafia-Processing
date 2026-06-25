import java.text.Normalizer;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import processing.event.MouseEvent;

SistemaFiltros sistemaFiltros;
FiltroInterface filtroInterface;

void inicializarSistemaFiltros() {
  sistemaFiltros = new SistemaFiltros();
  sistemaFiltros.carregarProdutosDosTSV();
  filtroInterface = new FiltroInterface(sistemaFiltros);
  filtroInterface.carregarAssets();
  println(sistemaFiltros.resumo());
}

void desenharFiltroUI() {
  if (filtroInterface != null) {
    filtroInterface.desenhar();
  }
}

boolean filtroMousePressed() {
  return filtroInterface != null && filtroInterface.mousePressed(mouseX, mouseY);
}

boolean filtroMouseDragged() {
  return filtroInterface != null && filtroInterface.mouseDragged(mouseX, mouseY);
}

void filtroMouseReleased() {
  if (filtroInterface != null) {
    filtroInterface.mouseReleased();
  }
}

void filtroMouseWheel(MouseEvent evento) {
  if (filtroInterface != null) {
    filtroInterface.mouseWheel(mouseX, mouseY, evento.getCount());
  }
}

boolean filtroKeyPressed(char tecla, int codigo) {
  return filtroInterface != null && filtroInterface.keyPressed(tecla, codigo);
}

class SistemaFiltros {
  final String DIM_MATERIAL = "material";
  final String DIM_ESTETICO = "estetico";
  final String DIM_TECNICAS = "tecnicas";
  final String DIM_TIPO_OBRA = "tipo_obra";

  ArrayList<DimensaoFiltro> dimensoes = new ArrayList<DimensaoFiltro>();
  ArrayList<ProdutoFiltrado> produtos = new ArrayList<ProdutoFiltrado>();

  HashMap<String, DimensaoFiltro> dimensaoPorId = new HashMap<String, DimensaoFiltro>();
  HashMap<String, TagFiltro> tagsPorChave = new HashMap<String, TagFiltro>();
  HashSet<String> tagsSelecionadas = new HashSet<String>();

  SistemaFiltros() {
    inicializarTaxonomiaPadrao();
  }

  void carregarProdutosDosTSV() {
    produtos.clear();
    zerarOcorrencias();

    carregarProdutosDeArquivo("Produtos internacionais.tsv", "internacional");
    carregarProdutosDeArquivo("Produtos brasileiros.tsv", "brasileiro");

    ordenarTaxonomiaAlfabeticamente();
  }

  void carregarProdutosDeArquivo(String arquivo, String origem) {
    Table tabela = loadTable(arquivo, "header, tsv");
    if (tabela == null) {
      println("Tabela nao encontrada: " + arquivo);
      return;
    }

    int colunaId = indiceColuna(tabela, "ID", 0);
    int colunaNome = indiceColuna(tabela, "Nome", 1);
    int colunaTipo = indiceColuna(tabela, "Tipo", 2);
    int colunaMateriais = indiceColuna(tabela, "Materiais", max(0, tabela.getColumnCount() - 3));
    int colunaEstetico = indiceColuna(tabela, "Estético", max(0, tabela.getColumnCount() - 2));
    int colunaTecnicas = indiceColuna(tabela, "Técnicas de construção/Funcionalidades", max(0, tabela.getColumnCount() - 1));

    for (int i = 0; i < tabela.getRowCount(); i++) {
      TableRow linha = tabela.getRow(i);
      ProdutoFiltrado produto = new ProdutoFiltrado(
        textoCelula(linha, colunaId),
        textoCelula(linha, colunaNome),
        origem,
        linha
      );

      adicionarTagsDoProduto(produto, DIM_TIPO_OBRA, textoCelula(linha, colunaTipo));
      adicionarTagsDoProduto(produto, DIM_TIPO_OBRA, tipoProdutoInferidoPeloNome(produto.nome));
      adicionarTagsDoProduto(produto, DIM_MATERIAL, textoCelula(linha, colunaMateriais));
      adicionarTagsDoProduto(produto, DIM_ESTETICO, textoCelula(linha, colunaEstetico));
      adicionarTagsDoProduto(produto, DIM_TECNICAS, textoCelula(linha, colunaTecnicas));

      produtos.add(produto);
    }
  }

  void adicionarTagsDoProduto(ProdutoFiltrado produto, String dimensaoId, String valorDaCelula) {
    ArrayList<String> tags = separarTags(valorDaCelula);
    HashSet<String> tagsUnicasDoProduto = new HashSet<String>();

    for (String tagBruta : tags) {
      TagFiltro tag = obterOuCriarTagObservada(dimensaoId, tagBruta);
      if (tag == null) {
        continue;
      }

      String chave = tag.chave();
      if (!tagsUnicasDoProduto.contains(chave) && !produto.possuiTag(tag)) {
        tagsUnicasDoProduto.add(chave);
        tag.ocorrencias++;
        tag.encontradaNosDados = true;
        produto.adicionarTag(tag);
      }
    }
  }

  String tipoProdutoInferidoPeloNome(String nome) {
    String texto = normalizarBusca(nome);
    if (texto.length() == 0) {
      return "";
    }

    if (contemAlgum(texto, new String[] {"cadeira", "poltrona", "sofa", "banco", "banqueta", "pufe", "chaise"})) {
      return "Assento";
    }
    if (contemAlgum(texto, new String[] {"mesa", "escrivaninha", "bancada"})) {
      return "Mesa";
    }
    if (contemAlgum(texto, new String[] {"luminaria", "lampada", "abajur"})) {
      return "Iluminação";
    }
    if (contemAlgum(texto, new String[] {"cartaz", "poster", "selo", "revista", "livro", "capa", "tipografia"})) {
      return "Comunicação gráfica";
    }
    if (contemAlgum(texto, new String[] {"radio", "telefone", "camera", "barbeador", "calculadora", "aspirador", "processador"})) {
      return "Equipamento";
    }
    if (contemAlgum(texto, new String[] {"onibus", "chevrolet", "ford", "carro", "trem", "metro", "bicicleta", "aviao"})) {
      return "Transporte";
    }
    if (contemAlgum(texto, new String[] {"edificio", "casa", "pavilhao", "fachada", "escola", "igreja"})) {
      return "Arquitetura";
    }
    if (contemAlgum(texto, new String[] {"vaso", "jarra", "decanter", "copo", "prato", "talher", "panela", "garrafa"})) {
      return "Utensílio";
    }
    if (contemAlgum(texto, new String[] {"tapecaria", "tecido", "textil", "vestido"})) {
      return "Têxtil";
    }
    return "";
  }

  ArrayList<ProdutoFiltrado> produtosFiltrados() {
    return produtosFiltrados(false);
  }

  ArrayList<ProdutoFiltrado> produtosFiltradosComTodasAsTags() {
    return produtosFiltrados(true);
  }

  ArrayList<ProdutoFiltrado> produtosVisiveisParaVisualizacoes() {
    ArrayList<ProdutoFiltrado> resultado = new ArrayList<ProdutoFiltrado>();
    ArrayList<TagFiltro> tagsTipoProduto = tagsSelecionadasDaDimensao(DIM_TIPO_OBRA);
    ArrayList<TagFiltro> tagsGerais = tagsSelecionadasExcetoTipoProduto();

    for (ProdutoFiltrado produto : produtos) {
      if (!produtoPossuiTodasAsRestricoesDeTipo(produto, tagsTipoProduto)) {
        continue;
      }
      if (tagsGerais.size() == 0 || produtoPossuiAlgumaTag(produto, tagsGerais)) {
        resultado.add(produto);
      }
    }

    return resultado;
  }

  ArrayList<TagFiltro> tagsSelecionadasExcetoTipoProduto() {
    ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
    for (DimensaoFiltro dimensao : dimensoes) {
      if (!dimensao.id.equals(DIM_TIPO_OBRA)) {
        resultado.addAll(tagsSelecionadasDaDimensao(dimensao.id));
      }
    }
    return resultado;
  }

  boolean produtoPossuiTodasAsRestricoesDeTipo(ProdutoFiltrado produto, ArrayList<TagFiltro> tagsTipoProduto) {
    if (tagsTipoProduto.size() == 0) {
      return true;
    }
    return produtoPossuiAlgumaTag(produto, tagsTipoProduto);
  }

  boolean produtoPossuiAlgumaTag(ProdutoFiltrado produto, ArrayList<TagFiltro> tags) {
    for (TagFiltro tag : tags) {
      if (produto.possuiTag(tag)) {
        return true;
      }
    }
    return false;
  }

  ArrayList<ProdutoFiltrado> produtosFiltrados(boolean exigirTodasAsTagsNaDimensao) {
    ArrayList<ProdutoFiltrado> resultado = new ArrayList<ProdutoFiltrado>();

    for (ProdutoFiltrado produto : produtos) {
      if (produtoPassaNoFiltro(produto, exigirTodasAsTagsNaDimensao)) {
        resultado.add(produto);
      }
    }

    return resultado;
  }

  boolean produtoPassaNoFiltro(ProdutoFiltrado produto, boolean exigirTodasAsTagsNaDimensao) {
    if (tagsSelecionadas.size() == 0) {
      return true;
    }

    for (DimensaoFiltro dimensao : dimensoes) {
      ArrayList<TagFiltro> selecionadasNaDimensao = tagsSelecionadasDaDimensao(dimensao.id);
      if (selecionadasNaDimensao.size() == 0) {
        continue;
      }

      if (exigirTodasAsTagsNaDimensao) {
        for (TagFiltro tag : selecionadasNaDimensao) {
          if (!produto.possuiTag(tag)) {
            return false;
          }
        }
      } else {
        boolean possuiAlguma = false;
        for (TagFiltro tag : selecionadasNaDimensao) {
          if (produto.possuiTag(tag)) {
            possuiAlguma = true;
            break;
          }
        }
        if (!possuiAlguma) {
          return false;
        }
      }
    }

    return true;
  }

  void selecionarTag(String dimensaoId, String tagRotulo) {
    TagFiltro tag = encontrarTag(dimensaoId, tagRotulo);
    if (tag != null) {
      tagsSelecionadas.add(tag.chave());
    }
  }

  void removerTag(String dimensaoId, String tagRotulo) {
    TagFiltro tag = encontrarTag(dimensaoId, tagRotulo);
    if (tag != null) {
      tagsSelecionadas.remove(tag.chave());
    }
  }

  void alternarTag(String dimensaoId, String tagRotulo) {
    TagFiltro tag = encontrarTag(dimensaoId, tagRotulo);
    if (tag == null) {
      return;
    }

    if (tagsSelecionadas.contains(tag.chave())) {
      tagsSelecionadas.remove(tag.chave());
    } else {
      tagsSelecionadas.add(tag.chave());
    }
  }

  boolean tagSelecionada(TagFiltro tag) {
    return tag != null && tagsSelecionadas.contains(tag.chave());
  }

  void limparSelecao() {
    tagsSelecionadas.clear();
  }

  int contarProdutosComTag(TagFiltro tag) {
    if (tag == null) {
      return 0;
    }

    int total = 0;
    for (ProdutoFiltrado produto : produtos) {
      if (produto.possuiTag(tag)) {
        total++;
      }
    }
    return total;
  }

  int contarProdutosComTagNoResultadoAtual(TagFiltro tag) {
    if (tag == null) {
      return 0;
    }

    int total = 0;
    ArrayList<ProdutoFiltrado> base = produtosFiltrados();
    for (ProdutoFiltrado produto : base) {
      if (produto.possuiTag(tag)) {
        total++;
      }
    }
    return total;
  }

  DimensaoFiltro dimensao(String dimensaoId) {
    return dimensaoPorId.get(normalizarId(dimensaoId));
  }

  TagFiltro encontrarTag(String dimensaoId, String tagRotulo) {
    String chave = chaveTag(dimensaoId, tagRotulo);
    return tagsPorChave.get(chave);
  }

  ArrayList<CategoriaFiltro> categoriasDaDimensao(String dimensaoId) {
    DimensaoFiltro dimensao = dimensao(dimensaoId);
    if (dimensao == null) {
      return new ArrayList<CategoriaFiltro>();
    }
    return dimensao.categorias;
  }

  ArrayList<TagFiltro> tagsDaCategoria(CategoriaFiltro categoria, boolean apenasComDados) {
    ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
    if (categoria == null) {
      return resultado;
    }

    for (TagFiltro tag : categoria.tags) {
      if (!apenasComDados || tag.ocorrencias > 0) {
        resultado.add(tag);
      }
    }
    return resultado;
  }

  ArrayList<TagFiltro> tagsDisponiveis(String dimensaoId, boolean apenasComDados) {
    ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
    for (CategoriaFiltro categoria : categoriasDaDimensao(dimensaoId)) {
      resultado.addAll(tagsDaCategoria(categoria, apenasComDados));
    }
    return resultado;
  }

  ArrayList<TagFiltro> tagsSelecionadasDaDimensao(String dimensaoId) {
    ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
    DimensaoFiltro dimensao = dimensao(dimensaoId);
    if (dimensao == null) {
      return resultado;
    }

    for (CategoriaFiltro categoria : dimensao.categorias) {
      for (TagFiltro tag : categoria.tags) {
        if (tagsSelecionadas.contains(tag.chave())) {
          resultado.add(tag);
        }
      }
    }
    return resultado;
  }

  ArrayList<String> separarTags(String valor) {
    ArrayList<String> resultado = new ArrayList<String>();
    valor = limparTexto(valor);

    if (valor.length() == 0) {
      return resultado;
    }

    String[] partes = valor.split(",");
    for (String parte : partes) {
      String tag = limparTag(parte);
      if (tag.length() > 0) {
        resultado.add(tag);
      }
    }
    return resultado;
  }

  void inicializarTaxonomiaPadrao() {
    criarDimensao(DIM_MATERIAL, "Material");
    criarDimensao(DIM_ESTETICO, "Estético");
    criarDimensao(DIM_TECNICAS, "Técnicas de construção/Funcionalidades");
    criarDimensao(DIM_TIPO_OBRA, "Tipo de produto");

    inicializarMateriais();
    inicializarEsteticas();
    inicializarTecnicas();
    grupo(DIM_TIPO_OBRA, "Tipo de produto", "Tipos de produtos e obras identificados na base de dados.", new String[] {});
  }

  void inicializarMateriais() {
    grupo(DIM_MATERIAL, "Metal", "Inclui todos os tipos de metais e ligas metálicas", new String[] {
      "Aço", "Alumínio", "Bronze", "Chumbo", "Cobre", "Ferro", "Ferro fundido", "Latão",
      "Magnésio", "Metal", "Ouro", "Prata", "Zinco"
    });

    grupo(DIM_MATERIAL, "Plástico e Polímeros", "Inclui plásticos, borrachas e materiais sintéticos similares", new String[] {
      "ABS", "Acrílico", "Baquelite", "Borracha", "Catalin", "EPS (Isopor)", "Espuma",
      "Melamina", "Película adesiva", "Plástico", "Policarbonato", "Polietileno",
      "Polipropileno", "Poliuretano", "PVC", "Resina", "Vinil"
    });

    grupo(DIM_MATERIAL, "Cerâmica e Vidro", "Materiais modelados, cozidos ou vitrificados", new String[] {
      "Argila", "Cerâmica", "Fibra de vidro", "Porcelana", "Vidro"
    });

    grupo(DIM_MATERIAL, "Pedra e Materiais de Construção", "Minerais e compósitos voltados para estrutura e alvenaria", new String[] {
      "Alvenaria", "Concreto", "Estuque", "Gesso", "Mosaico", "Mármore", "Pedra",
      "Pedra preciosa", "Tijolo"
    });

    grupo(DIM_MATERIAL, "Madeira e Fibras Naturais", "Materiais de origem botânica e orgânica rígida", new String[] {
      "Elementos naturais", "Fibras naturais", "Madeira", "Palhinha", "Vime"
    });

    grupo(DIM_MATERIAL, "Tecido, Couro e Tapeçaria", "Materiais têxteis, de origem animal ou tramas flexíveis", new String[] {
      "Couro", "Couro sintético", "Crina", "Estofado", "Fibra", "Lã", "Seda", "Tecido", "Tela"
    });

    grupo(DIM_MATERIAL, "Componentes e Peças", "Módulos pré-fabricados, mecanismos e sistemas", new String[] {
      "Componentes de relojoaria", "Componentes eletromecânicos", "Componentes eletromecânicos e radiológicos",
      "Componentes eletrônicos", "Componentes elétricos", "Componentes mecânicos",
      "Componentes ópticos e mecânicos", "Filtro de ar", "Motor elétrico"
    });

    grupo(DIM_MATERIAL, "Papel, Mídia e Informação", "Suportes de comunicação, celulose e registros visuais", new String[] {
      "Fotografia", "Meios digitais", "Papel", "Tipografia"
    });

    grupo(DIM_MATERIAL, "Acabamentos e Adesivos", "Materiais de tratamento de superfície e fixação", new String[] {
      "Cola", "Esmalte", "Tinta", "Verniz"
    });

    grupo(DIM_MATERIAL, "Químicos e Materiais Diversos", "Elementos fluidos ou em estado particulado isolado", new String[] {
      "Fluidos", "Grafite"
    });
  }

  void inicializarEsteticas() {
    grupo(DIM_ESTETICO, "Forma e Geometria", "Formatos base, polígonos e características de contorno geral", new String[] {
      "Assimétrico", "Cilíndrico", "Circular", "Curvilíneo", "Cúbico", "Esférico", "Espiral",
      "Geométrico", "Irregular", "Ortogonal", "Oval", "Prismático", "Semicircular",
      "Simétrico", "Superfície curva"
    });

    grupo(DIM_ESTETICO, "Linhas e Contornos", "Traços, silhuetas e o fluxo visual das bordas", new String[] {
      "Contorno espesso", "Contorno fluido", "Fluido", "Linear", "Linhas contínuas",
      "Silhueta contrastante", "Sinuoso"
    });

    grupo(DIM_ESTETICO, "Estrutura e Composição", "Organização das partes, eixos espaciais e arranjos construtivos", new String[] {
      "Abóbada curva", "Arco", "Articulado", "Camadas", "Contraste formal", "Contínuo",
      "Empilhável", "Entrelaçado", "Envolvente", "Espaço negativo", "Estrutura aparente",
      "Estrutural", "Fragmentado", "Horizontal", "Modular", "Padronizado", "Sem pernas",
      "Sobreposição", "Telhado curvo", "Tensionado", "Unificado", "Vazado", "Vertical"
    });

    grupo(DIM_ESTETICO, "Volume, Dimensão e Proporção", "Escala, percepção de tamanho e ocupação no espaço", new String[] {
      "Bidimensional", "Escala distorcida", "Monumental", "Proporcional", "Tridimensional"
    });

    grupo(DIM_ESTETICO, "Cor, Luz e Aparência", "Paletas cromáticas e interação com a luz", new String[] {
      "Contraste cromático", "Cor sólida", "Cores vivas", "Dourado", "Monocromático",
      "Policromático", "Preto", "Reflexivo", "Tons pastéis", "Translúcido"
    });

    grupo(DIM_ESTETICO, "Textura e Materialidade", "Sensação tátil e características físicas aparentes", new String[] {
      "Bruto", "Contraste material", "Liso", "Metálico", "Texturizado", "Vidro"
    });

    grupo(DIM_ESTETICO, "Estilo, Movimento e Conceito", "Correntes estéticas, intenções de design e linguagens visuais", new String[] {
      "Abstrato", "Aerodinâmico", "Conceitual", "Decorativo", "Dinâmico", "Discreto",
      "Distópico", "Escultural", "Figurativo", "Irônico", "Kitsch", "Minimalista",
      "Ornamental", "Ready-made", "Transicional"
    });

    grupo(DIM_ESTETICO, "Natureza, Biologia e Anatomia", "Formas inspiradas em organismos vivos e elementos naturais", new String[] {
      "Anatômico", "Antropomórfico", "Biomórfico", "Botânico", "Floral", "Orgânico", "Zoomórfico"
    });

    grupo(DIM_ESTETICO, "Função, Mídia e Temática", "Usos específicos, suportes de mídia e temas direcionados", new String[] {
      "Caligráfico", "Comemoração", "Digital", "Ergonômico", "Filatelia", "Fotográfico",
      "Funcional", "Gráfico", "Industrial", "Mecânico", "Selo", "Tipográfico", "Utilitário"
    });
  }

  void inicializarTecnicas() {
    grupo(DIM_TECNICAS, "Acabamento e Tratamento de Superfície", "Técnicas de finalização, pintura, polimento e aplicação de revestimentos externos", new String[] {
      "Acabamento", "Acabamento em alto brilho", "Acabamento manual", "Aplicação de laminado",
      "Banho metálico", "Colagem de laminado", "Cromagem", "Douramento", "Esmaltação",
      "Esmaltação em pó", "Pintura", "Pintura epóxi", "Pintura esmaltada", "Pintura gestual",
      "Pintura lacada", "Pintura mecânica", "Pintura unificada", "Polimento",
      "Polimento manual", "Revestimento", "Revestimento de laminado", "Revestimento na massa",
      "Textura em relevo", "Zincagem"
    });

    grupo(DIM_TECNICAS, "Arquitetura e Construção Civil", "Sistemas construtivos, estruturação de edificações, isolamento e elementos espaciais", new String[] {
      "Acústica", "Alvenaria de pedra", "Alvenaria estrutural", "Alvenaria portante",
      "Arco catenário", "Claraboia", "Cofragem", "Cofragem helicoidal",
      "Concretagem em balanço", "Concreto projetado", "Construção cenográfica",
      "Construção contínua", "Construção de abóbadas", "Construção em concreto",
      "Construção in loco", "Escoramento", "Estrutura desmontável", "Estrutura em balanço",
      "Estrutura em concreto", "Estrutura em espiral", "Estrutura envidraçada",
      "Estrutura espacial", "Estrutura fixa", "Estrutura metálica", "Estrutura metálica aparente",
      "Estrutura tensionada", "Estruturação de mansardas", "Estuque", "Fachada autoportante",
      "Fachada-cortina", "Fundição em concreto", "Fundição in loco de concreto", "Iluminação",
      "Iluminação zenital", "Integração arquitetônica", "Isolamento acústico",
      "Modelagem arquitetônica", "Modelagem de estuque", "Planejamento urbano",
      "Planta aberta", "Planta livre", "Remodelação estrutural"
    });

    grupo(DIM_TECNICAS, "Artes Plásticas, Cerâmica e Vidro", "Técnicas escultóricas, trabalho com barro, pedras, vitrais e artes finas", new String[] {
      "Baixo-relevo", "Corte de vidro", "Cozimento", "Envidraçamento", "Escultura",
      "Escultura em pedra", "Incisão", "Modelagem", "Modelagem orgânica", "Moldagem de vidro",
      "Mosaico (Trencadís)", "Múltiplas queimas", "Sopro de vidro", "Trencadís (mosaico)",
      "Usinagem de mármore", "Vitral Tiffany", "Vitrificação"
    });

    grupo(DIM_TECNICAS, "Artesanato, Costura e Tapeçaria", "Trabalhos manuais têxteis, estofaria e confecção de tecidos", new String[] {
      "Bordado", "Costura", "Costura invisível", "Costura oculta", "Estofamento",
      "Estofamento artesanal", "Estofamento esticado", "Estofamento manual",
      "Estofamento tradicional", "Fabricação artesanal", "Tecelagem"
    });

    grupo(DIM_TECNICAS, "Conceitos e Metodologia", "Teorias, planejamento, ergonomia, intenções projetuais e processos criativos base", new String[] {
      "Alteração de escala", "Conceitual", "Construção geométrica", "Construção manual",
      "Construção modular", "Crítica social", "Desenho", "Desenho estrutural", "Desenho técnico",
      "Design aninhável", "Design corporativo", "Design de mostradores", "Design de sistemas",
      "Design integrado", "Ergonomia adaptável", "Escala distorcida", "Escala exagerada",
      "Fabrico sob medida", "Interface lógica ergonômica", "Padronização", "Portátil",
      "Postura fixa", "Postura flexível", "Preenchimento volumétrico", "Produção semi-industrial",
      "Produção seriada", "Produção teórica", "Ready-made", "Redesign", "Suspensão"
    });

    grupo(DIM_TECNICAS, "Corte, Dobra e Conformação de Materiais", "Processos físicos de alteração geométrica, extração, termodeformação e furação", new String[] {
      "Corte", "Corte mecânico", "Corte tridimensional", "Corte térmico", "Curvatura a frio",
      "Curvatura de madeira", "Curvatura de madeira a vapor", "Curvatura de metal",
      "Curvatura ergonômica", "Curvatura térmica", "Dobra", "Dobra a frio", "Dobra de chapa",
      "Dobra de tubos", "Dobra mecânica", "Dobradura", "Dobrável", "Extrusão",
      "Microperfuração", "Perfuração estrutural", "Prensagem", "Prensagem térmica", "Recorte",
      "Tensionamento"
    });

    grupo(DIM_TECNICAS, "Design Gráfico, Digital e Tipografia", "Composição visual, interface, arte final, mídias impressas, softwares e litografia", new String[] {
      "Colagem digital", "Composição digital", "Composição tipográfica", "Criação tipográfica",
      "Cromolitografia", "Desconstrução de grid", "Design de interface", "Design digital",
      "Design gráfico", "Design tipográfico", "Design vetorial", "Editoração eletrônica",
      "Estêncil", "Fotocomposição", "Fotomontagem", "Impressão", "Impressão 3D",
      "Impressão de segurança", "Impressão em múltiplas folhas", "Impressão fotomecânica",
      "Impressão gráfica", "Impressão offset", "Impressão plana", "Impressão seriada",
      "Litografia", "Litogravura", "Malha gráfica (grid)", "Manipulação de software",
      "Manipulação de texto", "Manipulação tipográfica", "Modelação 3D", "Modelação algorítmica",
      "Padronização tipográfica", "Planejamento visual", "Projeção", "Reprodução gráfica",
      "Serigrafia", "Simulação", "Simulação de fluidos", "Sobreposição de imagens",
      "Sobreposição gráfica", "Texturização visual", "Transferência fotográfica", "Xilogravura"
    });

    grupo(DIM_TECNICAS, "Engenharia, Mecânica e Sistemas", "Ramos da engenharia, componentes articulados, motorização, circuitos e automação", new String[] {
      "Articulação mecânica", "Base de contrapeso", "Base giratória", "Eixo pivotante",
      "Eletrificação embutida", "Engenharia aeronáutica", "Engenharia automotiva",
      "Engenharia de chassi", "Engenharia de produto", "Engenharia de sistemas",
      "Engenharia de transporte", "Engenharia de tração", "Engenharia estrutural",
      "Engenharia térmica", "Engenharia óptica", "Equipamento elétrico", "Fixação elétrica",
      "Fixação mecânica", "Funcionamento mecânico", "Instalação elétrica",
      "Integração de comandos", "Integração elétrica", "Integração monobloco",
      "Mecanismo conversível", "Montagem eletromecânica", "Montagem eletrônica",
      "Montagem elétrica", "Montagem mecânica", "Refrigeração", "Sistema de engrenagens",
      "Sistema mecânico", "Sistema rolante", "Sistematização de comandos", "Sistematização de interface"
    });

    grupo(DIM_TECNICAS, "Marcenaria e Carpintaria", "Trabalho com madeira, estruturação, entalhe e acabamento em peças botânicas", new String[] {
      "Carpintaria", "Entalhe", "Entalhe em madeira", "Escultura em madeira", "Grelha de madeira",
      "Marcenaria", "Marcenaria artesanal", "Marcenaria de precisão", "Marcenaria estrutural",
      "Marcenaria industrial", "Marcenaria integrada", "Marcenaria modular", "Marchetaria",
      "Moldagem de madeira", "Moldagem em madeira", "Torneamento de madeira", "Torneamento esférico"
    });

    grupo(DIM_TECNICAS, "Metalurgia, Joalheria e Usinagem", "Processos de fundição, forjamento, usinagem e manipulação de metais e joias", new String[] {
      "Cravação", "Eletroformação", "Esmaltação plique-à-jour", "Estampagem",
      "Estampagem de metal", "Forjamento", "Forjamento artesanal",
      "Forjamento de metal a alta temperatura", "Fundição", "Fundição de alumínio",
      "Fundição de precisão", "Injeção de magnésio a alta pressão", "Moldagem de metal",
      "Moldagem em aço fundido", "Ourivesaria", "Soldadura de alta frequência", "Soldagem",
      "Usinagem", "Usinagem de latão", "Usinagem de metal"
    });

    grupo(DIM_TECNICAS, "Moldagem, Injeção e Termoplásticos", "Técnicas de injeção, compressão, aplicação de espumas e conformação de polímeros/fibras", new String[] {
      "Aplicação de espuma", "Compressão a vácuo", "Injeção de plástico", "Injeção de poliuretano",
      "Insuflação pneumática", "Laminação", "Moldagem", "Moldagem a frio", "Moldagem a quente",
      "Moldagem a vapor", "Moldagem artesanal", "Moldagem de espuma", "Moldagem de fibra",
      "Moldagem de fibra de vidro", "Moldagem de polímeros", "Moldagem de precisão",
      "Moldagem estrutural", "Moldagem manual", "Moldagem manual de espuma",
      "Moldagem por injeção", "Moldagem por injeção a alta pressão", "Reforço de fibra de vidro",
      "Sopro de PET"
    });

    grupo(DIM_TECNICAS, "Montagem, Encaixe e Estruturação", "Processos de união de partes, construção modular e justaposição de elementos", new String[] {
      "Assemblage", "Colagem", "Colagem a frio", "Componentes intercambiáveis",
      "Composição em camadas", "Composição híbrida", "Composição volumétrica", "Empilhamento",
      "Encaixe", "Encaixe angular", "Encaixe articulado", "Encaixe diagonal", "Encaixe invisível",
      "Encaixe modular", "Encaixe oblíquo", "Justaposição", "Modularidade",
      "Modularidade estrutural", "Modulação espacial", "Montagem artesanal", "Montagem de blocos",
      "Montagem de eixo", "Montagem estrutural", "Montagem industrial", "Montagem modular",
      "Montagem pré-fabricada", "Montagem sobre base", "Pré-fabricação", "Sistema modular"
    });
  }

  void criarDimensao(String id, String rotulo) {
    DimensaoFiltro dimensao = new DimensaoFiltro(id, rotulo);
    dimensoes.add(dimensao);
    dimensaoPorId.put(id, dimensao);
  }

  void grupo(String dimensaoId, String rotulo, String descricao, String[] tags) {
    DimensaoFiltro dimensao = dimensao(dimensaoId);
    if (dimensao == null) {
      return;
    }

    CategoriaFiltro categoria = new CategoriaFiltro(dimensao, rotulo, descricao);
    dimensao.categorias.add(categoria);

    for (String rotuloTag : tags) {
      criarTag(categoria, rotuloTag);
    }
  }

  TagFiltro criarTag(CategoriaFiltro categoria, String rotuloTag) {
    rotuloTag = rotuloCanonicoTag(categoria.dimensao.id, rotuloTag);
    String chave = chaveTag(categoria.dimensao.id, rotuloTag);
    TagFiltro existente = tagsPorChave.get(chave);
    if (existente != null) {
      return existente;
    }

    TagFiltro tag = new TagFiltro(categoria.dimensao, categoria, limparTag(rotuloTag));
    categoria.tags.add(tag);
    tagsPorChave.put(tag.chave(), tag);
    return tag;
  }

  TagFiltro obterOuCriarTagObservada(String dimensaoId, String rotuloTag) {
    rotuloTag = rotuloCanonicoTag(dimensaoId, rotuloTag);
    String chave = chaveTag(dimensaoId, rotuloTag);
    TagFiltro tag = tagsPorChave.get(chave);
    if (tag != null) {
      return tag;
    }

    DimensaoFiltro dimensao = dimensao(dimensaoId);
    if (dimensao == null) {
      return null;
    }

    CategoriaFiltro categoria = categoriaParaTagObservada(dimensao, rotuloTag);
    tag = new TagFiltro(dimensao, categoria, limparTag(rotuloTag));
    categoria.tags.add(tag);
    tagsPorChave.put(tag.chave(), tag);
    return tag;
  }

  String rotuloCanonicoTag(String dimensaoId, String rotuloTag) {
    String tag = normalizarBusca(rotuloTag);
    if (tag.length() == 0) {
      return "";
    }

    if (dimensaoId.equals(DIM_TIPO_OBRA)) {
      if (contemAlgum(tag, new String[] {"cadeira", "poltrona", "sofa", "banco", "banqueta", "chaise", "assento"})) {
        return "Assento";
      }
      if (contemAlgum(tag, new String[] {"mesa", "escrivaninha", "bancada"})) {
        return "Mesa";
      }
      if (contemAlgum(tag, new String[] {"luminaria", "lampada", "abajur", "iluminacao", "design de iluminacao"})) {
        return "Iluminação";
      }
      if (contemAlgum(tag, new String[] {"cartaz", "poster", "selo", "capa", "revista", "livro", "identidade visual", "logotipo",
        "comunicacao visual", "design grafico", "obra grafica", "ilustracao", "tipografia"})) {
        return "Comunicação gráfica";
      }
      if (contemAlgum(tag, new String[] {"radio", "toca", "barbeador", "calculadora", "computador", "telefone", "aparelho", "aspirador",
        "processador", "eletrodomestico", "eletronicos", "equipamento de escritorio", "equipamento publico", "equipamento urbano"})) {
        return "Equipamento";
      }
      if (contemAlgum(tag, new String[] {"onibus", "automovel", "carro", "trem", "metro", "motocicleta", "bicicleta", "veiculo",
        "mobilidade", "transporte", "transportes"})) {
        return "Transporte";
      }
      if (contemAlgum(tag, new String[] {"edificio", "pavilhao", "casa", "fachada", "arquitetura", "urbanismo", "projeto arquitetonico",
        "componente arquitetonico", "interiores"})) {
        return "Arquitetura";
      }
      if (contemAlgum(tag, new String[] {"vaso", "decanter", "jarra", "copo", "prato", "servico", "utensilio", "cozinha"})) {
        return "Utensílio";
      }
      if (contemAlgum(tag, new String[] {"mobiliario", "mobiliário"})) {
        return "Mobiliário";
      }
      if (contemAlgum(tag, new String[] {"textil", "tecido", "artigo textil", "artes decorativas"})) {
        return "Têxtil";
      }
      if (contemAlgum(tag, new String[] {"artes plasticas", "pintura", "escultura"})) {
        return "Artes plásticas";
      }
      if (contemAlgum(tag, new String[] {"joalheria"})) {
        return "Joalheria";
      }
      if (contemAlgum(tag, new String[] {"material de construcao"})) {
        return "Material de construção";
      }
      if (contemAlgum(tag, new String[] {"vestuario"})) {
        return "Vestuário";
      }
    }

    if (dimensaoId.equals(DIM_ESTETICO)) {
      if (contemAlgum(tag, new String[] {"curvilineo", "ondular", "curvo", "sinuoso"})) {
        return "Curvilíneo";
      }
      if (contemAlgum(tag, new String[] {"contorno fluido", "fluido"})) {
        return "Fluido";
      }
      if (contemAlgum(tag, new String[] {"linhas limpas", "linhas continuas", "linear"})) {
        return "Linear";
      }
      if (contemAlgum(tag, new String[] {"minimalismo", "minimalista"})) {
        return "Minimalista";
      }
      if (contemAlgum(tag, new String[] {"design ortogonal", "ortogonal"})) {
        return "Ortogonal";
      }
      if (contemAlgum(tag, new String[] {"forma escultural", "escultural"})) {
        return "Escultural";
      }
      if (contemAlgum(tag, new String[] {"geometrico", "design geometrico", "geometria"})) {
        return "Geométrico";
      }
      if (contemAlgum(tag, new String[] {"forma circular"})) {
        return "Circular";
      }
      if (contemAlgum(tag, new String[] {"calota", "semiesfer"})) {
        return "Semicircular";
      }
      if (contemAlgum(tag, new String[] {"rede de fio", "trama", "tranc", "entrelac"})) {
        return "Entrelaçado";
      }
      if (contemAlgum(tag, new String[] {"botone", "textur", "canelado"})) {
        return "Texturizado";
      }
      if (contemAlgum(tag, new String[] {"translucidez", "translucido"})) {
        return "Translúcido";
      }
      if (contemAlgum(tag, new String[] {"design organico", "organico", "ecologico"})) {
        return "Orgânico";
      }
      if (contemAlgum(tag, new String[] {"pes de metal", "metalico"})) {
        return "Metálico";
      }
      if (contemAlgum(tag, new String[] {"material", "contraste material"})) {
        return "Contraste material";
      }
    }

    if (dimensaoId.equals(DIM_TECNICAS)) {
      if (contemAlgum(tag, new String[] {"postura fixa", "postura flexivel", "ergonom", "inclinacao livre"})) {
        return "Ergonomia";
      }
      if (contemAlgum(tag, new String[] {"encaixe", "travamento", "pino"})) {
        return "Encaixe";
      }
      if (contemAlgum(tag, new String[] {"desmontavel", "flat-pack", "aninhavel", "dobravel", "estrutura desmontavel"})) {
        return "Design desmontável";
      }
      if (contemAlgum(tag, new String[] {"usinagem cnc", "fresadora", "controle numerico", "usinagem"})) {
        return "Usinagem";
      }
      if (contemAlgum(tag, new String[] {"moldagem por injecao", "injecao", "monobloco"})) {
        return "Moldagem por injeção";
      }
      if (contemAlgum(tag, new String[] {"curvatura de madeira", "madeira prensada"})) {
        return "Curvatura de madeira";
      }
      if (contemAlgum(tag, new String[] {"curvatura", "dobra", "dobradura"})) {
        return "Dobra e curvatura";
      }
      if (contemAlgum(tag, new String[] {"producao em massa", "producao seriada", "seriada", "semi-industrial"})) {
        return "Produção seriada";
      }
      if (contemAlgum(tag, new String[] {"colagem", "cola"})) {
        return "Colagem";
      }
      if (contemAlgum(tag, new String[] {"tensionamento", "tensionadas", "tensionado"})) {
        return "Tensionamento";
      }
      if (contemAlgum(tag, new String[] {"pintura", "lacada", "epoxi", "esmaltada"})) {
        return "Pintura";
      }
      if (contemAlgum(tag, new String[] {"acabamento", "revestimento", "polimento", "cromagem", "douramento", "zincagem",
        "banho metalico", "esmaltacao", "laminado", "laminacao"})) {
        return "Acabamento";
      }
      if (contemAlgum(tag, new String[] {"corte", "recorte", "microperfuracao", "perfuracao"})) {
        return "Corte";
      }
      if (contemAlgum(tag, new String[] {"estofamento"})) {
        return "Estofamento";
      }
      if (contemAlgum(tag, new String[] {"costura"})) {
        return "Costura";
      }
      if (contemAlgum(tag, new String[] {"fundicao"})) {
        return "Fundição";
      }
      if (contemAlgum(tag, new String[] {"estampagem"})) {
        return "Estampagem";
      }
      if (contemAlgum(tag, new String[] {"soldagem", "soldadura"})) {
        return "Soldagem";
      }
      if (contemAlgum(tag, new String[] {"forjamento"})) {
        return "Forjamento";
      }
      if (contemAlgum(tag, new String[] {"extrusao", "prensagem", "sopro de pet", "sopro de vidro", "insuflacao"})) {
        return "Conformação";
      }
      if (contemAlgum(tag, new String[] {"montagem"})) {
        return "Montagem";
      }
      if (contemAlgum(tag, new String[] {"moldagem"})) {
        return "Moldagem";
      }
      if (contemAlgum(tag, new String[] {"modelagem", "modelacao"})) {
        return "Modelagem";
      }
      if (contemAlgum(tag, new String[] {"marcenaria"})) {
        return "Marcenaria";
      }
      if (contemAlgum(tag, new String[] {"impressao", "litografia", "litogravura", "serigrafia", "xilogravura"})) {
        return "Impressão";
      }
      if (contemAlgum(tag, new String[] {"fotomontagem", "fotocomposicao", "sobreposicao grafica", "sobreposicao de imagens"})) {
        return "Composição gráfica";
      }
      if (contemAlgum(tag, new String[] {"padronizacao"})) {
        return "Padronização";
      }
      if (contemAlgum(tag, new String[] {"modularidade", "sistema modular", "construcao modular", "modulacao"})) {
        return "Modularidade";
      }
      if (contemAlgum(tag, new String[] {"tecelagem"})) {
        return "Tecelagem";
      }
      if (contemAlgum(tag, new String[] {"cofragem"})) {
        return "Cofragem";
      }
      if (contemAlgum(tag, new String[] {"alvenaria"})) {
        return "Alvenaria";
      }
      if (contemAlgum(tag, new String[] {"estrutura aparente", "estrutura separada", "estrutura fixa"})) {
        return "Estrutura fixa";
      }
    }

    return limparTag(rotuloTag);
  }

  boolean contemAlgum(String texto, String[] termos) {
    for (String termo : termos) {
      if (texto.indexOf(termo) >= 0) {
        return true;
      }
    }
    return false;
  }

  CategoriaFiltro categoriaParaTagObservada(DimensaoFiltro dimensao, String rotuloTag) {
    if (dimensao.id.equals(DIM_TIPO_OBRA) && dimensao.categorias.size() > 0) {
      return dimensao.categorias.get(0);
    }

    String tag = normalizarBusca(rotuloTag);

    if (dimensao.id.equals(DIM_MATERIAL)) {
      if (tag.indexOf("aco") >= 0 || tag.indexOf("aluminio") >= 0 || tag.indexOf("bronze") >= 0 ||
        tag.indexOf("chumbo") >= 0 || tag.indexOf("cobre") >= 0 || tag.indexOf("ferro") >= 0 ||
        tag.indexOf("latao") >= 0 || tag.indexOf("magnesio") >= 0 || tag.indexOf("metal") >= 0 ||
        tag.indexOf("ouro") >= 0 || tag.indexOf("prata") >= 0 || tag.indexOf("zinco") >= 0) {
        return categoriaPorRotulo(dimensao, "Metal");
      }
      if (tag.indexOf("abs") >= 0 || tag.indexOf("acrilico") >= 0 || tag.indexOf("baquelite") >= 0 ||
        tag.indexOf("borracha") >= 0 || tag.indexOf("catalin") >= 0 || tag.indexOf("isopor") >= 0 ||
        tag.indexOf("espuma") >= 0 || tag.indexOf("melamina") >= 0 || tag.indexOf("plastico") >= 0 ||
        tag.indexOf("policarbonato") >= 0 || tag.indexOf("polietileno") >= 0 ||
        tag.indexOf("polipropileno") >= 0 || tag.indexOf("poliuretano") >= 0 || tag.indexOf("pvc") >= 0 ||
        tag.indexOf("resina") >= 0 || tag.indexOf("vinil") >= 0) {
        return categoriaPorRotulo(dimensao, "Plástico e Polímeros");
      }
      if (tag.indexOf("ceramica") >= 0 || tag.indexOf("argila") >= 0 || tag.indexOf("porcelana") >= 0 ||
        tag.indexOf("vidro") >= 0) {
        return categoriaPorRotulo(dimensao, "Cerâmica e Vidro");
      }
      if (tag.indexOf("alvenaria") >= 0 || tag.indexOf("concreto") >= 0 || tag.indexOf("estuque") >= 0 ||
        tag.indexOf("gesso") >= 0 || tag.indexOf("mosaico") >= 0 || tag.indexOf("marmore") >= 0 ||
        tag.indexOf("pedra") >= 0 || tag.indexOf("tijolo") >= 0) {
        return categoriaPorRotulo(dimensao, "Pedra e Materiais de Construção");
      }
      if (tag.indexOf("madeira") >= 0 || tag.indexOf("pinus") >= 0 || tag.indexOf("teca") >= 0 ||
        tag.indexOf("jacaranda") >= 0 || tag.indexOf("freijo") >= 0 || tag.indexOf("carvalho") >= 0 ||
        tag.indexOf("palha") >= 0 || tag.indexOf("palhinha") >= 0 || tag.indexOf("vime") >= 0 ||
        tag.indexOf("bambu") >= 0 || tag.indexOf("lascas") >= 0 || tag.indexOf("ripas") >= 0) {
        return categoriaPorRotulo(dimensao, "Madeira e Fibras Naturais");
      }
      if (tag.indexOf("couro") >= 0 || tag.indexOf("tecido") >= 0 || tag.indexOf("textil") >= 0 ||
        tag.indexOf("estof") >= 0 || tag.indexOf("fibra") >= 0 || tag.indexOf("la ") >= 0 ||
        tag.equals("la") || tag.indexOf("seda") >= 0 || tag.indexOf("tela") >= 0 || tag.indexOf("crina") >= 0) {
        return categoriaPorRotulo(dimensao, "Tecido, Couro e Tapeçaria");
      }
      if (tag.indexOf("componente") >= 0 || tag.indexOf("motor") >= 0 || tag.indexOf("filtro") >= 0 ||
        tag.indexOf("parafuso") >= 0 || tag.indexOf("prego") >= 0) {
        return categoriaPorRotulo(dimensao, "Componentes e Peças");
      }
      if (tag.indexOf("papel") >= 0 || tag.indexOf("fotografia") >= 0 || tag.indexOf("digital") >= 0 ||
        tag.indexOf("tipografia") >= 0) {
        return categoriaPorRotulo(dimensao, "Papel, Mídia e Informação");
      }
      if (tag.indexOf("cola") >= 0 || tag.indexOf("esmalte") >= 0 || tag.indexOf("tinta") >= 0 ||
        tag.indexOf("verniz") >= 0) {
        return categoriaPorRotulo(dimensao, "Acabamentos e Adesivos");
      }
      return categoriaPorRotulo(dimensao, "Químicos e Materiais Diversos");
    }

    if (dimensao.id.equals(DIM_ESTETICO)) {
      if (tag.indexOf("cilind") >= 0 || tag.indexOf("circular") >= 0 || tag.indexOf("curv") >= 0 ||
        tag.indexOf("geometric") >= 0 || tag.indexOf("ortogonal") >= 0 || tag.indexOf("esfer") >= 0 ||
        tag.indexOf("oval") >= 0 || tag.indexOf("simetric") >= 0 || tag.indexOf("assim") >= 0) {
        return categoriaPorRotulo(dimensao, "Forma e Geometria");
      }
      if (tag.indexOf("linha") >= 0 || tag.indexOf("contorno") >= 0 || tag.indexOf("sinu") >= 0 ||
        tag.indexOf("silhueta") >= 0 || tag.indexOf("fluido") >= 0) {
        return categoriaPorRotulo(dimensao, "Linhas e Contornos");
      }
      if (tag.indexOf("estrutura") >= 0 || tag.indexOf("modular") >= 0 || tag.indexOf("camada") >= 0 ||
        tag.indexOf("vazado") >= 0 || tag.indexOf("vertical") >= 0 || tag.indexOf("horizontal") >= 0 ||
        tag.indexOf("aparente") >= 0 || tag.indexOf("pes palito") >= 0 || tag.indexOf("sem pernas") >= 0) {
        return categoriaPorRotulo(dimensao, "Estrutura e Composição");
      }
      if (tag.indexOf("monumental") >= 0 || tag.indexOf("bidimensional") >= 0 || tag.indexOf("tridimensional") >= 0 ||
        tag.indexOf("escala") >= 0 || tag.indexOf("propor") >= 0) {
        return categoriaPorRotulo(dimensao, "Volume, Dimensão e Proporção");
      }
      if (tag.indexOf("cor") >= 0 || tag.indexOf("crom") >= 0 || tag.indexOf("preto") >= 0 ||
        tag.indexOf("dourado") >= 0 || tag.indexOf("transluc") >= 0 || tag.indexOf("pastel") >= 0 ||
        tag.indexOf("reflex") >= 0) {
        return categoriaPorRotulo(dimensao, "Cor, Luz e Aparência");
      }
      if (tag.indexOf("textur") >= 0 || tag.indexOf("liso") >= 0 || tag.indexOf("bruto") >= 0 ||
        tag.indexOf("material") >= 0 || tag.indexOf("metalico") >= 0 || tag.indexOf("vidro") >= 0) {
        return categoriaPorRotulo(dimensao, "Textura e Materialidade");
      }
      if (tag.indexOf("organico") >= 0 || tag.indexOf("biom") >= 0 || tag.indexOf("floral") >= 0 ||
        tag.indexOf("botan") >= 0 || tag.indexOf("anatom") >= 0 || tag.indexOf("antrop") >= 0 ||
        tag.indexOf("zoom") >= 0) {
        return categoriaPorRotulo(dimensao, "Natureza, Biologia e Anatomia");
      }
      if (tag.indexOf("ergon") >= 0 || tag.indexOf("funcional") >= 0 || tag.indexOf("industrial") >= 0 ||
        tag.indexOf("graf") >= 0 || tag.indexOf("tipograf") >= 0 || tag.indexOf("digital") >= 0 ||
        tag.indexOf("util") >= 0 || tag.indexOf("mecan") >= 0) {
        return categoriaPorRotulo(dimensao, "Função, Mídia e Temática");
      }
      return categoriaPorRotulo(dimensao, "Estilo, Movimento e Conceito");
    }

    if (dimensao.id.equals(DIM_TECNICAS)) {
      if (tag.indexOf("pint") >= 0 || tag.indexOf("acabamento") >= 0 || tag.indexOf("polimento") >= 0 ||
        tag.indexOf("revest") >= 0 || tag.indexOf("crom") >= 0 || tag.indexOf("zinc") >= 0 ||
        tag.indexOf("esmalt") >= 0 || tag.indexOf("dour") >= 0) {
        return categoriaPorRotulo(dimensao, "Acabamento e Tratamento de Superfície");
      }
      if (tag.indexOf("alvenaria") >= 0 || tag.indexOf("concreto") >= 0 || tag.indexOf("estrutura") >= 0 ||
        tag.indexOf("fachada") >= 0 || tag.indexOf("planta") >= 0 || tag.indexOf("arquitet") >= 0 ||
        tag.indexOf("ilumin") >= 0 || tag.indexOf("acust") >= 0) {
        return categoriaPorRotulo(dimensao, "Arquitetura e Construção Civil");
      }
      if (tag.indexOf("escultura") >= 0 || tag.indexOf("vidro") >= 0 || tag.indexOf("ceram") >= 0 ||
        tag.indexOf("mosaico") >= 0 || tag.indexOf("vitral") >= 0 || tag.indexOf("marmore") >= 0 ||
        tag.indexOf("cozimento") >= 0) {
        return categoriaPorRotulo(dimensao, "Artes Plásticas, Cerâmica e Vidro");
      }
      if (tag.indexOf("costura") >= 0 || tag.indexOf("estof") >= 0 || tag.indexOf("tecel") >= 0 ||
        tag.indexOf("bordado") >= 0 || tag.indexOf("artesanal") >= 0) {
        return categoriaPorRotulo(dimensao, "Artesanato, Costura e Tapeçaria");
      }
      if (tag.indexOf("corte") >= 0 || tag.indexOf("dobra") >= 0 || tag.indexOf("curvatura") >= 0 ||
        tag.indexOf("dobr") >= 0 || tag.indexOf("extrus") >= 0 || tag.indexOf("prensagem") >= 0 ||
        tag.indexOf("recorte") >= 0 || tag.indexOf("perfura") >= 0 || tag.indexOf("tension") >= 0) {
        return categoriaPorRotulo(dimensao, "Corte, Dobra e Conformação de Materiais");
      }
      if (tag.indexOf("graf") >= 0 || tag.indexOf("tipograf") >= 0 || tag.indexOf("impress") >= 0 ||
        tag.indexOf("litograf") >= 0 || tag.indexOf("serigraf") >= 0 || tag.indexOf("digital") >= 0 ||
        tag.indexOf("software") >= 0 || tag.indexOf("grid") >= 0 || tag.indexOf("3d") >= 0) {
        return categoriaPorRotulo(dimensao, "Design Gráfico, Digital e Tipografia");
      }
      if (tag.indexOf("engenharia") >= 0 || tag.indexOf("mecan") >= 0 || tag.indexOf("eletr") >= 0 ||
        tag.indexOf("sistema") >= 0 || tag.indexOf("eixo") >= 0 || tag.indexOf("girator") >= 0 ||
        tag.indexOf("refriger") >= 0 || tag.indexOf("chassi") >= 0) {
        return categoriaPorRotulo(dimensao, "Engenharia, Mecânica e Sistemas");
      }
      if (tag.indexOf("madeira") >= 0 || tag.indexOf("marcen") >= 0 || tag.indexOf("carpint") >= 0 ||
        tag.indexOf("entalhe") >= 0 || tag.indexOf("torneamento") >= 0 || tag.indexOf("marchet") >= 0) {
        return categoriaPorRotulo(dimensao, "Marcenaria e Carpintaria");
      }
      if (tag.indexOf("metal") >= 0 || tag.indexOf("sold") >= 0 || tag.indexOf("fund") >= 0 ||
        tag.indexOf("forja") >= 0 || tag.indexOf("usin") >= 0 || tag.indexOf("estamp") >= 0 ||
        tag.indexOf("ourives") >= 0 || tag.indexOf("crava") >= 0) {
        return categoriaPorRotulo(dimensao, "Metalurgia, Joalheria e Usinagem");
      }
      if (tag.indexOf("mold") >= 0 || tag.indexOf("injec") >= 0 || tag.indexOf("lamina") >= 0 ||
        tag.indexOf("espuma") >= 0 || tag.indexOf("fibra") >= 0 || tag.indexOf("sopro") >= 0 ||
        tag.indexOf("compress") >= 0) {
        return categoriaPorRotulo(dimensao, "Moldagem, Injeção e Termoplásticos");
      }
      if (tag.indexOf("montagem") >= 0 || tag.indexOf("encaixe") >= 0 || tag.indexOf("colagem") >= 0 ||
        tag.indexOf("modular") >= 0 || tag.indexOf("empilh") >= 0 || tag.indexOf("pre-fabric") >= 0 ||
        tag.indexOf("prefabric") >= 0 || tag.indexOf("justap") >= 0 || tag.indexOf("composi") >= 0) {
        return categoriaPorRotulo(dimensao, "Montagem, Encaixe e Estruturação");
      }
      return categoriaPorRotulo(dimensao, "Conceitos e Metodologia");
    }

    return dimensao.categoriaSemAgrupamento();
  }

  CategoriaFiltro categoriaPorRotulo(DimensaoFiltro dimensao, String rotulo) {
    for (CategoriaFiltro categoria : dimensao.categorias) {
      if (normalizarBusca(categoria.rotulo).equals(normalizarBusca(rotulo))) {
        return categoria;
      }
    }
    return dimensao.categoriaSemAgrupamento();
  }

  void zerarOcorrencias() {
    for (String chave : tagsPorChave.keySet()) {
      TagFiltro tag = tagsPorChave.get(chave);
      tag.ocorrencias = 0;
      tag.encontradaNosDados = false;
    }

    for (DimensaoFiltro dimensao : dimensoes) {
      CategoriaFiltro semAgrupamento = dimensao.semAgrupamento;
      if (semAgrupamento == null) {
        continue;
      }

      for (int i = semAgrupamento.tags.size() - 1; i >= 0; i--) {
        TagFiltro tag = semAgrupamento.tags.get(i);
        tagsPorChave.remove(tag.chave());
      }
      semAgrupamento.tags.clear();
    }
  }

  void ordenarTaxonomiaAlfabeticamente() {
    for (DimensaoFiltro dimensao : dimensoes) {
      Collections.sort(dimensao.categorias, new Comparator<CategoriaFiltro>() {
        public int compare(CategoriaFiltro a, CategoriaFiltro b) {
          return compararTextoOrdenacao(a.rotulo, b.rotulo);
        }
      });

      for (CategoriaFiltro categoria : dimensao.categorias) {
        ordenarTagsDaCategoria(categoria);
      }
    }
  }

  void ordenarTagsDaCategoria(CategoriaFiltro categoria) {
    Collections.sort(categoria.tags, new Comparator<TagFiltro>() {
      public int compare(TagFiltro a, TagFiltro b) {
        return compararTextoOrdenacao(a.rotulo, b.rotulo);
      }
    });
  }

  int compararTextoOrdenacao(String a, String b) {
    int comparacao = normalizarBusca(a).compareToIgnoreCase(normalizarBusca(b));
    if (comparacao != 0) {
      return comparacao;
    }
    return limparTexto(a).compareToIgnoreCase(limparTexto(b));
  }

  int indiceColuna(Table tabela, String nome, int fallback) {
    String alvo = normalizarBusca(nome);
    String[] titulos = tabela.getColumnTitles();

    for (int i = 0; i < titulos.length; i++) {
      String titulo = normalizarBusca(titulos[i]);
      if (titulo.equals(alvo)) {
        return i;
      }
    }

    for (int i = 0; i < titulos.length; i++) {
      String titulo = normalizarBusca(titulos[i]);
      if (titulo.indexOf(alvo) >= 0 || alvo.indexOf(titulo) >= 0) {
        return i;
      }
    }

    return constrain(fallback, 0, max(0, tabela.getColumnCount() - 1));
  }

  String textoCelula(TableRow linha, int coluna) {
    if (coluna < 0) {
      return "";
    }
    return limparTexto(linha.getString(coluna));
  }

  String limparTag(String valor) {
    valor = limparTexto(valor);
    while (valor.endsWith(".") || valor.endsWith(";")) {
      valor = valor.substring(0, valor.length() - 1).trim();
    }
    return valor;
  }

  String limparTexto(String valor) {
    if (valor == null) {
      return "";
    }

    valor = valor.replace('\u00A0', ' ').trim();
    if (pareceMojibake(valor)) {
      try {
        valor = new String(valor.getBytes("ISO-8859-1"), "UTF-8");
      } catch (Exception erro) {
        // Mantem o texto original caso o ambiente nao consiga recodificar.
      }
    }

    return valor.replaceAll("\\s+", " ").trim();
  }

  boolean pareceMojibake(String valor) {
    return valor.indexOf("Ã") >= 0 || valor.indexOf("Â") >= 0 || valor.indexOf("�") >= 0;
  }

  String normalizarId(String valor) {
    return normalizarBusca(valor);
  }

  String chaveTag(String dimensaoId, String rotuloTag) {
    return normalizarId(dimensaoId) + "::" + normalizarBusca(rotuloTag);
  }

  String normalizarBusca(String valor) {
    valor = limparTexto(valor);
    String normalizado = Normalizer.normalize(valor, Normalizer.Form.NFD);
    normalizado = normalizado.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    normalizado = normalizado.toLowerCase();
    normalizado = normalizado.replaceAll("[\"'`´’‘“”]", "");
    normalizado = normalizado.replaceAll("\\s+", " ").trim();
    return normalizado;
  }

  String resumo() {
    String texto = "Sistema de filtros: " + produtos.size() + " produtos carregados";
    for (DimensaoFiltro dimensao : dimensoes) {
      texto += " | " + dimensao.rotulo + ": " + dimensao.totalTags() + " tags";
    }
    return texto;
  }
}

class DimensaoFiltro {
  String id;
  String rotulo;
  ArrayList<CategoriaFiltro> categorias = new ArrayList<CategoriaFiltro>();
  CategoriaFiltro semAgrupamento;

  DimensaoFiltro(String id, String rotulo) {
    this.id = id;
    this.rotulo = rotulo;
  }

  CategoriaFiltro categoriaSemAgrupamento() {
    if (semAgrupamento == null) {
      semAgrupamento = new CategoriaFiltro(this, "Sem agrupamento", "Tags encontradas nos dados, mas ainda nao associadas a uma categoria.");
      categorias.add(semAgrupamento);
    }
    return semAgrupamento;
  }

  int totalTags() {
    int total = 0;
    for (CategoriaFiltro categoria : categorias) {
      total += categoria.tags.size();
    }
    return total;
  }
}

class CategoriaFiltro {
  DimensaoFiltro dimensao;
  String id;
  String rotulo;
  String descricao;
  ArrayList<TagFiltro> tags = new ArrayList<TagFiltro>();

  CategoriaFiltro(DimensaoFiltro dimensao, String rotulo, String descricao) {
    this.dimensao = dimensao;
    this.rotulo = rotulo;
    this.descricao = descricao;
    this.id = normalizarCategoriaId(rotulo);
  }

  void ordenarTagsPorRotulo() {
    Collections.sort(tags, new Comparator<TagFiltro>() {
      public int compare(TagFiltro a, TagFiltro b) {
        return a.rotulo.compareToIgnoreCase(b.rotulo);
      }
    });
  }

  String normalizarCategoriaId(String valor) {
    String normalizado = Normalizer.normalize(valor, Normalizer.Form.NFD);
    normalizado = normalizado.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    normalizado = normalizado.toLowerCase();
    normalizado = normalizado.replaceAll("[^a-z0-9]+", "-");
    normalizado = normalizado.replaceAll("(^-|-$)", "");
    return normalizado;
  }
}

class TagFiltro {
  DimensaoFiltro dimensao;
  CategoriaFiltro categoria;
  String rotulo;
  String id;
  int ocorrencias = 0;
  boolean encontradaNosDados = false;

  TagFiltro(DimensaoFiltro dimensao, CategoriaFiltro categoria, String rotulo) {
    this.dimensao = dimensao;
    this.categoria = categoria;
    this.rotulo = rotulo;
    this.id = normalizarTagId(rotulo);
  }

  String chave() {
    String normalizado = Normalizer.normalize(rotulo, Normalizer.Form.NFD);
    normalizado = normalizado.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    normalizado = normalizado.toLowerCase();
    normalizado = normalizado.replaceAll("[\"'`´’‘“”]", "");
    normalizado = normalizado.replaceAll("\\s+", " ").trim();
    return dimensao.id + "::" + normalizado;
  }

  String normalizarTagId(String valor) {
    String normalizado = Normalizer.normalize(valor, Normalizer.Form.NFD);
    normalizado = normalizado.replaceAll("\\p{InCombiningDiacriticalMarks}+", "");
    normalizado = normalizado.toLowerCase();
    normalizado = normalizado.replaceAll("[^a-z0-9]+", "-");
    normalizado = normalizado.replaceAll("(^-|-$)", "");
    return normalizado;
  }
}

class ProdutoFiltrado {
  String id;
  String nome;
  String origem;
  TableRow linhaOriginal;
  HashMap<String, ArrayList<TagFiltro>> tagsPorDimensao = new HashMap<String, ArrayList<TagFiltro>>();
  HashSet<String> chavesTags = new HashSet<String>();

  ProdutoFiltrado(String id, String nome, String origem, TableRow linhaOriginal) {
    this.id = id;
    this.nome = nome;
    this.origem = origem;
    this.linhaOriginal = linhaOriginal;
  }

  void adicionarTag(TagFiltro tag) {
    if (chavesTags.contains(tag.chave())) {
      return;
    }
    if (!tagsPorDimensao.containsKey(tag.dimensao.id)) {
      tagsPorDimensao.put(tag.dimensao.id, new ArrayList<TagFiltro>());
    }
    tagsPorDimensao.get(tag.dimensao.id).add(tag);
    chavesTags.add(tag.chave());
  }

  boolean possuiTag(TagFiltro tag) {
    return tag != null && chavesTags.contains(tag.chave());
  }

  ArrayList<TagFiltro> tagsDaDimensao(String dimensaoId) {
    ArrayList<TagFiltro> tags = tagsPorDimensao.get(dimensaoId);
    if (tags == null) {
      return new ArrayList<TagFiltro>();
    }
    return tags;
  }
}

class FiltroInterface {
  SistemaFiltros filtros;

  final int X = 0;
  final int Y = 0;
  final int BODY_W = 255;
  final int HEADER_W = BODY_W;
  final int HEADER_H = 56;
  final float CARD_W = BODY_W / 2.0f;
  final int CARD_H = 100;
  final int CARD_FOOTER_H = 26;
  final int BODY_H = 821;
  final int BODY_Y = HEADER_H + CARD_H * 2;
  final int CATEGORY_BAR_X = 27;
  final int CATEGORY_BAR_Y = BODY_Y + 38;
  final int CATEGORY_BAR_W = 201;
  final int CATEGORY_BAR_H = 31;
  final int SEARCH_BAR_Y = CATEGORY_BAR_Y + CATEGORY_BAR_H + 10;
  final int SEARCH_BAR_H = 31;
  final int CLEAR_BUTTON_Y = SEARCH_BAR_Y + SEARCH_BAR_H + 10;
  final int CLEAR_BUTTON_H = 28;
  final int TAG_LIST_Y = CLEAR_BUTTON_Y + CLEAR_BUTTON_H + 16;
  final int TAG_ROW_H = 36;
  final int TAG_CIRCLE_SIZE = 20;
  final int SCROLL_X = 8;
  final int SCROLL_W = 5;
  final int SCROLL_MIN_THUMB_H = 34;
  final int INDICE_TAGS_DISPONIVEIS = -2;
  final int INDICE_TODAS_TAGS = -1;
  final String ROTULO_TAGS_DISPONIVEIS = "Tags disponiveis";
  final String ROTULO_TODAS_TAGS = "Tags ativas";

  final color COR_AMARELO = #FFCB00;
  final color COR_FUNDO = #222222;
  final color COR_PRETO = #000000;
  final color COR_BRANCO = #FFFFFF;
  final color COR_LINHA_CLARA = #D9D9D9;
  final color COR_MATERIAL = #3E4AD3;
  final color COR_TECNICA = #4AD33E;
  final color COR_ESTETICO = #D33E4A;
  final color COR_TIPO_OBRA = #FFCB00;

  PFont fonteTitulo;
  PFont fonteCategoria;
  PFont fonteTexto;
  PImage iconeMaterial;
  PImage iconeTecnica;
  PImage iconeEstetico;
  PImage iconeTipoObra;
  PImage iconeLimparFiltro;

  String dimensaoAtivaId;
  HashMap<String, Integer> categoriaAtivaPorDimensao = new HashMap<String, Integer>();
  boolean seletorCategoriasAberto = false;
  boolean buscaAtiva = false;
  boolean scrollTagsArrastando = false;
  String textoBusca = "";
  float scrollTags = 0;
  float scrollTagsDragOffset = 0;

  FiltroInterface(SistemaFiltros filtros) {
    this.filtros = filtros;
    this.dimensaoAtivaId = filtros.DIM_TIPO_OBRA;
  }

  void carregarAssets() {
    fonteTitulo = createFont("New Amsterdam", 40, true);
    fonteCategoria = createFont("New Amsterdam", 23, true);
    fonteTexto = createFont("Roboto Condensed", 20, true);

    iconeMaterial = loadImage("Icones/material.png");
    iconeTecnica = loadImage("Icones/técnica.png");
    iconeEstetico = loadImage("Icones/estético.png");
    iconeTipoObra = loadImage("Icones/tipodeproduto.png");
    iconeLimparFiltro = loadImage("Icones/filter_alt_off.png");

    categoriaAtivaPorDimensao.put(filtros.DIM_MATERIAL, indiceCategoria(filtros.DIM_MATERIAL, "Plástico e Polímeros"));
    categoriaAtivaPorDimensao.put(filtros.DIM_TECNICAS, INDICE_TODAS_TAGS);
    categoriaAtivaPorDimensao.put(filtros.DIM_ESTETICO, INDICE_TODAS_TAGS);
    categoriaAtivaPorDimensao.put(filtros.DIM_TIPO_OBRA, INDICE_TODAS_TAGS);
  }

  void desenhar() {
    pushStyle();
    desenharCabecalho();
    desenharCards();
    desenharCorpo();
    popStyle();
  }

  void desenharCabecalho() {
    stroke(COR_PRETO);
    strokeWeight(2);
    fill(COR_AMARELO);
    rect(X, Y, HEADER_W, HEADER_H);

    fill(COR_PRETO);
    textFont(fonteTitulo);
    textAlign(CENTER, CENTER);
    text("FILTROS", X + HEADER_W/2, Y + HEADER_H/2 - 1);
  }

  void desenharCards() {
    desenharCardFiltro(0, filtros.DIM_MATERIAL, "Material", iconeMaterial, COR_MATERIAL);
    desenharCardFiltro(1, filtros.DIM_TECNICAS, "Técnica", iconeTecnica, COR_TECNICA);
    desenharCardFiltro(2, filtros.DIM_ESTETICO, "Estético", iconeEstetico, COR_ESTETICO);
    desenharCardFiltro(3, filtros.DIM_TIPO_OBRA, "Tipo de produto", iconeTipoObra, COR_TIPO_OBRA);
  }

  void desenharCardFiltro(int indice, String dimensaoId, String rotulo, PImage icone, color corAtiva) {
    int col = indice % 2;
    int row = indice / 2;
    float cardX = X + col * CARD_W;
    float cardY = Y + HEADER_H + row * CARD_H;
    boolean ativo = dimensaoAtivaId.equals(dimensaoId);

    stroke(COR_PRETO);
    strokeWeight(2);
    fill(ativo ? COR_AMARELO : COR_BRANCO);
    rect(cardX, cardY, CARD_W, CARD_H - CARD_FOOTER_H);

    if (icone != null) {
      desenharImagemCentralizada(icone, cardX + CARD_W/2, cardY + (CARD_H - CARD_FOOTER_H)/2, 70, 58);
    }

    fill(ativo ? corAtiva : COR_PRETO);
    rect(cardX, cardY + CARD_H - CARD_FOOTER_H, CARD_W, CARD_FOOTER_H);

    fill(ativo && corAtiva == COR_TIPO_OBRA ? COR_PRETO : COR_BRANCO);
    textFont(fonteTexto);
    textSize(tamanhoTextoAjustado(rotulo, fonteTexto, 18, 10, CARD_W - 24));
    desenharTextoCentralizado(rotulo, cardX + CARD_W/2, cardY + CARD_H - CARD_FOOTER_H/2 + 1);
  }

  void desenharCorpo() {
    noStroke();
    fill(COR_FUNDO);
    rect(X, BODY_Y, BODY_W, alturaCorpo());

    if (!dimensaoAtivaEhTipoProduto()) {
      desenharBarraCategoria();
    }
    desenharBarraBusca();
    desenharBotaoLimparTags();
    if (seletorCategoriasAberto) {
      desenharSeletorCategorias();
    } else {
      desenharListaTags();
    }
  }

  void desenharBarraCategoria() {
    String rotulo = rotuloCategoriaAtiva();

    noStroke();
    fill(COR_BRANCO);
    rect(X + CATEGORY_BAR_X, CATEGORY_BAR_Y, CATEGORY_BAR_W, CATEGORY_BAR_H, CATEGORY_BAR_H/2);

    fill(COR_PRETO);
    textFont(fonteCategoria);
    textSize(tamanhoTextoAjustado(rotulo.toUpperCase(), fonteCategoria, 22, 12, CATEGORY_BAR_W - 22));
    textAlign(CENTER, CENTER);
    text(rotulo.toUpperCase(), X + CATEGORY_BAR_X + CATEGORY_BAR_W/2, CATEGORY_BAR_Y + CATEGORY_BAR_H/2 - 1);
  }

  void desenharBarraBusca() {
    int y = yBarraBusca();
    noStroke();
    fill(COR_BRANCO);
    rect(X + CATEGORY_BAR_X, y, CATEGORY_BAR_W, SEARCH_BAR_H, SEARCH_BAR_H/2);

    textFont(fonteTexto);
    textSize(14);
    textAlign(LEFT, CENTER);
    fill(textoBusca.length() == 0 ? color(90) : COR_PRETO);

    String texto = textoBusca.length() == 0 ? "Pesquisar" : textoBusca;
    text(texto, X + CATEGORY_BAR_X + 13, y + SEARCH_BAR_H/2 - 1);

    if (buscaAtiva && frameCount % 60 < 30) {
      float cursorX = X + CATEGORY_BAR_X + 13 + textWidth(textoBusca);
      stroke(COR_PRETO);
      strokeWeight(1);
      line(cursorX + 2, y + 8, cursorX + 2, y + SEARCH_BAR_H - 8);
    }
  }

  void desenharBotaoLimparTags() {
    int y = yBotaoLimparTags();
    boolean ativo = filtros.tagsSelecionadas.size() > 0;
    noStroke();
    fill(ativo ? COR_BRANCO : color(105));
    rect(X + CATEGORY_BAR_X, y, CATEGORY_BAR_W, CLEAR_BUTTON_H, CLEAR_BUTTON_H/2);

    if (iconeLimparFiltro != null) {
      tint(COR_PRETO, ativo ? 255 : 120);
      desenharImagemCentralizada(iconeLimparFiltro, X + CATEGORY_BAR_X + CATEGORY_BAR_W/2, y + CLEAR_BUTTON_H/2, 22, 22);
      noTint();
    }
  }

  void desenharSeletorCategorias() {
    ArrayList<CategoriaFiltro> categorias = categoriasVisiveisDaDimensao();
    int listaY = yListaCategorias();
    int linhaH = 34;
    int totalOpcoes = totalOpcoesCategoria(categorias);

    noStroke();
    fill(COR_BRANCO);
    rect(X, listaY - 6, BODY_W, max(0, limiteInferiorPainel() - listaY + 6));

    for (int i = 0; i < totalOpcoes; i++) {
      int yLinha = listaY + i * linhaH;
      if (yLinha > height) {
        break;
      }

      int indiceCategoria = indiceCategoriaDaOpcao(i);
      String rotuloOpcao = rotuloCategoriaDaOpcao(i, categorias);
      boolean ativa = indiceCategoria == indiceCategoriaAtiva();
      noStroke();
      if (ativa) {
        fill(COR_AMARELO);
        rect(X + 13, yLinha + linhaH - 6, BODY_W - 26, 3);
      }

      stroke(COR_PRETO);
      strokeWeight(1);
      line(X + 13, yLinha + linhaH - 3, X + BODY_W - 13, yLinha + linhaH - 3);

      fill(COR_PRETO);
      noStroke();
      textFont(fonteCategoria);
      textSize(tamanhoTextoAjustado(rotuloOpcao, fonteCategoria, 18, 10, BODY_W - 30));
      textAlign(LEFT, BASELINE);
      text(rotuloOpcao, X + 18, baselineCentral(yLinha + linhaH/2));
    }
  }

  void desenharListaTags() {
    ArrayList<TagFiltro> tags = tagsParaExibir();
    int listaFim = limiteInferiorPainel();
    int listaY = yListaTags();
    clip(X, listaY, BODY_W, max(0, listaFim - listaY));

    float yBase = listaY - scrollTags;
    for (int i = 0; i < tags.size(); i++) {
      float yLinha = yBase + i * TAG_ROW_H;
      if (yLinha + TAG_ROW_H < listaY || yLinha > listaFim) {
        continue;
      }

      if (i % 2 == 1) {
        noStroke();
        fill(COR_LINHA_CLARA, 62);
        rect(X, yLinha, BODY_W, TAG_ROW_H);
      }

      desenharTag(tags.get(i), yLinha);
    }

    noClip();
    desenharScrollTags(tags.size());
  }

  void desenharScrollTags(int totalTags) {
    if (maxScrollTags(totalTags) <= 0) {
      return;
    }

    float trackX = X + SCROLL_X;
    float trackY = yListaTags();
    float trackH = alturaListaTagsVisivel();
    float thumbH = alturaThumbTags(totalTags);
    float thumbY = yThumbTags(totalTags);

    noStroke();
    fill(COR_LINHA_CLARA, 55);
    rect(trackX, trackY, SCROLL_W, trackH, SCROLL_W/2);

    fill(COR_BRANCO);
    rect(trackX, thumbY, SCROLL_W, thumbH, SCROLL_W/2);
  }

  void desenharTag(TagFiltro tag, float yLinha) {
    color corTipo = corDimensao(tag.dimensao.id);
    boolean selecionada = filtros.tagSelecionada(tag);
    float cx = X + CATEGORY_BAR_X + TAG_CIRCLE_SIZE/2;
    float cy = yLinha + TAG_ROW_H/2;
    float textoX = X + CATEGORY_BAR_X + TAG_CIRCLE_SIZE + 10;

    stroke(COR_BRANCO);
    strokeWeight(2);
    fill(selecionada ? corTipo : COR_FUNDO);
    ellipse(cx, cy, TAG_CIRCLE_SIZE, TAG_CIRCLE_SIZE);

    fill(COR_BRANCO);
    textFont(fonteTexto);
    textSize(tamanhoTextoAjustado(tag.rotulo, fonteTexto, 15, 9, BODY_W - textoX - 10));
    desenharTextoAlinhadoAoCirculo(tag.rotulo, textoX, cy);
  }

  boolean mousePressed(float mx, float my) {
    if (!dentroDoPainel(mx, my)) {
      seletorCategoriasAberto = false;
      buscaAtiva = false;
      scrollTagsArrastando = false;
      return false;
    }

    if (clicouCard(mx, my)) {
      return true;
    }

    if (clicouBarraBusca(mx, my)) {
      buscaAtiva = true;
      seletorCategoriasAberto = false;
      return true;
    }

    if (clicouBotaoLimparTags(mx, my)) {
      boolean tinhaTipoSelecionado = tipoProdutoLimitandoTags();
      filtros.limparSelecao();
      if (tinhaTipoSelecionado) {
        resetarCategoriasDependentesDoTipo();
      }
      textoBusca = "";
      scrollTags = 0;
      buscaAtiva = false;
      seletorCategoriasAberto = false;
      return true;
    }

    if (clicouBarraCategoria(mx, my)) {
      seletorCategoriasAberto = !seletorCategoriasAberto;
      buscaAtiva = false;
      return true;
    }

    if (seletorCategoriasAberto) {
      if (clicouOpcaoCategoria(mx, my)) {
        return true;
      }
      seletorCategoriasAberto = false;
      return true;
    }

    if (clicouScrollTags(mx, my)) {
      return true;
    }

    if (clicouTag(mx, my)) {
      return true;
    }

    return true;
  }

  boolean clicouCard(float mx, float my) {
    if (mx < X || mx > X + BODY_W || my < HEADER_H || my > HEADER_H + CARD_H * 2) {
      return false;
    }

    int col = mx < X + CARD_W ? 0 : 1;
    int row = int((my - HEADER_H) / CARD_H);
    int indice = row * 2 + col;

    if (indice == 0) {
      trocarDimensao(filtros.DIM_MATERIAL);
    } else if (indice == 1) {
      trocarDimensao(filtros.DIM_TECNICAS);
    } else if (indice == 2) {
      trocarDimensao(filtros.DIM_ESTETICO);
    } else if (indice == 3) {
      trocarDimensao(filtros.DIM_TIPO_OBRA);
    }

    return true;
  }

  boolean clicouBarraCategoria(float mx, float my) {
    if (dimensaoAtivaEhTipoProduto()) {
      return false;
    }
    return mx >= X + CATEGORY_BAR_X && mx <= X + CATEGORY_BAR_X + CATEGORY_BAR_W &&
      my >= CATEGORY_BAR_Y && my <= CATEGORY_BAR_Y + CATEGORY_BAR_H;
  }

  boolean clicouBarraBusca(float mx, float my) {
    int y = yBarraBusca();
    return mx >= X + CATEGORY_BAR_X && mx <= X + CATEGORY_BAR_X + CATEGORY_BAR_W &&
      my >= y && my <= y + SEARCH_BAR_H;
  }

  boolean clicouBotaoLimparTags(float mx, float my) {
    int y = yBotaoLimparTags();
    return mx >= X + CATEGORY_BAR_X && mx <= X + CATEGORY_BAR_X + CATEGORY_BAR_W &&
      my >= y && my <= y + CLEAR_BUTTON_H;
  }

  boolean clicouOpcaoCategoria(float mx, float my) {
    ArrayList<CategoriaFiltro> categorias = categoriasVisiveisDaDimensao();
    int listaY = yListaCategorias();
    int linhaH = 34;

    int totalOpcoes = totalOpcoesCategoria(categorias);
    for (int i = 0; i < totalOpcoes; i++) {
      int yLinha = listaY + i * linhaH;
      if (mx >= X + 16 && mx <= X + BODY_W - 16 && my >= yLinha && my <= yLinha + linhaH - 4) {
        categoriaAtivaPorDimensao.put(dimensaoAtivaId, indiceCategoriaDaOpcao(i));
        scrollTags = 0;
        seletorCategoriasAberto = false;
        return true;
      }
    }

    return false;
  }

  boolean clicouScrollTags(float mx, float my) {
    if (seletorCategoriasAberto || maxScrollTags() <= 0 || !dentroListaTags(mx, my)) {
      return false;
    }

    float trackX = X + SCROLL_X;
    if (mx < trackX - 6 || mx > trackX + SCROLL_W + 6) {
      return false;
    }

    int totalTags = tagsParaExibir().size();
    float thumbY = yThumbTags(totalTags);
    float thumbH = alturaThumbTags(totalTags);

    if (my >= thumbY && my <= thumbY + thumbH) {
      scrollTagsDragOffset = my - thumbY;
    } else {
      scrollTagsDragOffset = thumbH/2;
    }

    scrollTagsArrastando = true;
    atualizarScrollArrastado(my);
    return true;
  }

  boolean clicouTag(float mx, float my) {
    int listaY = yListaTags();
    if (my < listaY || my > limiteInferiorPainel()) {
      return false;
    }

    ArrayList<TagFiltro> tags = tagsParaExibir();
    int indice = floor((my - listaY + scrollTags) / TAG_ROW_H);
    if (indice < 0 || indice >= tags.size()) {
      return false;
    }

    TagFiltro tag = tags.get(indice);
    filtros.alternarTag(tag.dimensao.id, tag.rotulo);
    if (tag.dimensao.id.equals(filtros.DIM_TIPO_OBRA)) {
      resetarCategoriasDependentesDoTipo();
    }
    return true;
  }

  void mouseWheel(float mx, float my, float quantidade) {
    if (!dentroListaTags(mx, my) || seletorCategoriasAberto) {
      return;
    }

    scrollTags = constrain(scrollTags + quantidade * 26, 0, maxScrollTags());
  }

  boolean mouseDragged(float mx, float my) {
    if (!scrollTagsArrastando) {
      return false;
    }

    atualizarScrollArrastado(my);
    return true;
  }

  void mouseReleased() {
    scrollTagsArrastando = false;
  }

  void atualizarScrollArrastado(float my) {
    int totalTags = tagsParaExibir().size();
    float maxScroll = maxScrollTags(totalTags);
    if (maxScroll <= 0) {
      scrollTags = 0;
      return;
    }

    float trackY = yListaTags();
    float trackH = alturaListaTagsVisivel();
    float thumbH = alturaThumbTags(totalTags);
    float maxThumbY = max(1, trackH - thumbH);
    float localY = constrain(my - scrollTagsDragOffset - trackY, 0, maxThumbY);

    scrollTags = map(localY, 0, maxThumbY, 0, maxScroll);
  }

  boolean keyPressed(char tecla, int codigo) {
    if (!buscaAtiva) {
      return false;
    }

    if (tecla == BACKSPACE) {
      if (textoBusca.length() > 0) {
        textoBusca = textoBusca.substring(0, textoBusca.length() - 1);
        scrollTags = 0;
      }
      return true;
    }

    if (tecla == DELETE) {
      textoBusca = "";
      scrollTags = 0;
      return true;
    }

    if (tecla == ENTER || tecla == RETURN) {
      buscaAtiva = false;
      return true;
    }

    if (tecla >= 32 && tecla != CODED) {
      textoBusca += tecla;
      scrollTags = 0;
      return true;
    }

    return true;
  }

  void trocarDimensao(String dimensaoId) {
    dimensaoAtivaId = dimensaoId;
    if (!categoriaAtivaPorDimensao.containsKey(dimensaoId)) {
      categoriaAtivaPorDimensao.put(dimensaoId, 0);
    }
    if (dimensaoAtivaEhTipoProduto()) {
      categoriaAtivaPorDimensao.put(dimensaoId, INDICE_TODAS_TAGS);
    }
    seletorCategoriasAberto = false;
    buscaAtiva = false;
    scrollTagsArrastando = false;
    textoBusca = "";
    scrollTags = 0;
  }

  CategoriaFiltro categoriaAtiva() {
    ArrayList<CategoriaFiltro> categorias = categoriasVisiveisDaDimensao();
    if (categorias.size() == 0) {
      return null;
    }

    if (indiceCategoriaAtiva() < 0) {
      return null;
    }

    int indice = constrain(indiceCategoriaAtiva(), 0, categorias.size() - 1);
    return categorias.get(indice);
  }

  String rotuloCategoriaAtiva() {
    if (indiceCategoriaAtiva() == INDICE_TAGS_DISPONIVEIS) {
      return ROTULO_TAGS_DISPONIVEIS;
    }
    if (indiceCategoriaAtiva() == INDICE_TODAS_TAGS) {
      return ROTULO_TODAS_TAGS;
    }

    CategoriaFiltro categoria = categoriaAtiva();
    return categoria == null ? "" : categoria.rotulo;
  }

  int indiceCategoriaAtiva() {
    Integer indice = categoriaAtivaPorDimensao.get(dimensaoAtivaId);
    return indice == null ? 0 : indice;
  }

  boolean mostraOpcaoTagsDisponiveis() {
    return tipoProdutoLimitandoTags() && !dimensaoAtivaEhTipoProduto();
  }

  int totalOpcoesCategoria(ArrayList<CategoriaFiltro> categorias) {
    return categorias.size() + (mostraOpcaoTagsDisponiveis() ? 2 : 1);
  }

  int indiceCategoriaDaOpcao(int indiceOpcao) {
    if (mostraOpcaoTagsDisponiveis()) {
      if (indiceOpcao == 0) {
        return INDICE_TAGS_DISPONIVEIS;
      }
      if (indiceOpcao == 1) {
        return INDICE_TODAS_TAGS;
      }
      return indiceOpcao - 2;
    }

    return indiceOpcao == 0 ? INDICE_TODAS_TAGS : indiceOpcao - 1;
  }

  String rotuloCategoriaDaOpcao(int indiceOpcao, ArrayList<CategoriaFiltro> categorias) {
    int indiceCategoria = indiceCategoriaDaOpcao(indiceOpcao);
    if (indiceCategoria == INDICE_TAGS_DISPONIVEIS) {
      return ROTULO_TAGS_DISPONIVEIS;
    }
    if (indiceCategoria == INDICE_TODAS_TAGS) {
      return ROTULO_TODAS_TAGS;
    }
    return categorias.get(indiceCategoria).rotulo;
  }

  int yBarraBusca() {
    return dimensaoAtivaEhTipoProduto() ? CATEGORY_BAR_Y : SEARCH_BAR_Y;
  }

  int yBotaoLimparTags() {
    return yBarraBusca() + SEARCH_BAR_H + 10;
  }

  int yListaCategorias() {
    return yBotaoLimparTags() + CLEAR_BUTTON_H + 12;
  }

  int yListaTags() {
    return yBotaoLimparTags() + CLEAR_BUTTON_H + 16;
  }

  ArrayList<CategoriaFiltro> categoriasVisiveisDaDimensao() {
    ArrayList<CategoriaFiltro> resultado = new ArrayList<CategoriaFiltro>();
    if (dimensaoAtivaEhTipoProduto()) {
      return resultado;
    }

    ArrayList<CategoriaFiltro> categorias = filtros.categoriasDaDimensao(dimensaoAtivaId);
    boolean filtrarPorTipo = tipoProdutoLimitandoTags() && !dimensaoAtivaId.equals(filtros.DIM_TIPO_OBRA);
    HashSet<String> chavesPermitidas = filtrarPorTipo ? chavesTagsDoTipoSelecionado(dimensaoAtivaId) : null;

    for (CategoriaFiltro categoria : categorias) {
      if (categoria.rotulo.equals("Sem agrupamento") && categoria.tags.size() == 0) {
        continue;
      }
      if (filtrarPorTipo && !categoriaTemTagsPermitidas(categoria, chavesPermitidas)) {
        continue;
      }
      resultado.add(categoria);
    }

    return resultado;
  }

  boolean categoriaTemTagsPermitidas(CategoriaFiltro categoria, HashSet<String> chavesPermitidas) {
    if (categoria == null || chavesPermitidas == null) {
      return false;
    }

    for (TagFiltro tag : categoria.tags) {
      if (chavesPermitidas.contains(tag.chave())) {
        return true;
      }
    }
    return false;
  }

  ArrayList<TagFiltro> tagsParaExibir() {
    String busca = filtros.normalizarBusca(textoBusca);
    if (busca.length() > 0) {
      ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
      ArrayList<TagFiltro> tags = tagsBaseParaBusca();

      for (TagFiltro tag : tags) {
        if (filtros.normalizarBusca(tag.rotulo).indexOf(busca) >= 0) {
          resultado.add(tag);
        }
      }

      return resultado;
    }

    if (dimensaoAtivaEhTipoProduto()) {
      return tagsTipoProdutoOrdenadasPorQuantidade();
    }

    if (indiceCategoriaAtiva() == INDICE_TAGS_DISPONIVEIS) {
      return tagsDisponiveisNoContexto();
    }
    if (indiceCategoriaAtiva() == INDICE_TODAS_TAGS) {
      return filtros.tagsSelecionadasDaDimensao(dimensaoAtivaId);
    }

    CategoriaFiltro categoria = categoriaAtiva();
    if (categoria == null) {
      return new ArrayList<TagFiltro>();
    }
    ArrayList<TagFiltro> tags = filtros.tagsDaCategoria(categoria, false);
    return filtrarTagsPorContexto(tags);
  }

  ArrayList<TagFiltro> tagsBaseParaBusca() {
    if (dimensaoAtivaEhTipoProduto()) {
      return tagsTipoProdutoOrdenadasPorQuantidade();
    }
    return tagsDisponiveisNoContexto();
  }

  ArrayList<TagFiltro> tagsTipoProdutoOrdenadasPorQuantidade() {
    ArrayList<TagFiltro> tags = filtros.tagsDisponiveis(filtros.DIM_TIPO_OBRA, true);
    Collections.sort(tags, new Comparator<TagFiltro>() {
      public int compare(TagFiltro a, TagFiltro b) {
        if (a.ocorrencias != b.ocorrencias) {
          return b.ocorrencias - a.ocorrencias;
        }
        return filtros.compararTextoOrdenacao(a.rotulo, b.rotulo);
      }
    });
    return tags;
  }

  ArrayList<TagFiltro> tagsDisponiveisNoContexto() {
    return filtrarTagsPorContexto(filtros.tagsDisponiveis(dimensaoAtivaId, false));
  }

  ArrayList<TagFiltro> filtrarTagsPorContexto(ArrayList<TagFiltro> tags) {
    if (!tipoProdutoLimitandoTags() || dimensaoAtivaId.equals(filtros.DIM_TIPO_OBRA)) {
      return tags;
    }

    HashSet<String> chavesPermitidas = chavesTagsDoTipoSelecionado(dimensaoAtivaId);
    ArrayList<TagFiltro> resultado = new ArrayList<TagFiltro>();
    for (TagFiltro tag : tags) {
      if (chavesPermitidas.contains(tag.chave())) {
        resultado.add(tag);
      }
    }
    return resultado;
  }

  boolean tipoProdutoLimitandoTags() {
    return filtros.tagsSelecionadasDaDimensao(filtros.DIM_TIPO_OBRA).size() > 0;
  }

  boolean dimensaoAtivaEhTipoProduto() {
    return dimensaoAtivaId.equals(filtros.DIM_TIPO_OBRA);
  }

  void resetarCategoriasDependentesDoTipo() {
    int indiceInicial = tipoProdutoLimitandoTags() ? INDICE_TAGS_DISPONIVEIS : INDICE_TODAS_TAGS;
    categoriaAtivaPorDimensao.put(filtros.DIM_MATERIAL, indiceInicial);
    categoriaAtivaPorDimensao.put(filtros.DIM_TECNICAS, indiceInicial);
    categoriaAtivaPorDimensao.put(filtros.DIM_ESTETICO, indiceInicial);
    scrollTags = 0;
  }

  HashSet<String> chavesTagsDoTipoSelecionado(String dimensaoId) {
    HashSet<String> chaves = new HashSet<String>();
    ArrayList<TagFiltro> tiposSelecionados = filtros.tagsSelecionadasDaDimensao(filtros.DIM_TIPO_OBRA);

    for (ProdutoFiltrado produto : filtros.produtos) {
      boolean passaTipo = false;
      for (TagFiltro tipo : tiposSelecionados) {
        if (produto.possuiTag(tipo)) {
          passaTipo = true;
          break;
        }
      }
      if (!passaTipo) {
        continue;
      }
      for (TagFiltro tag : produto.tagsDaDimensao(dimensaoId)) {
        chaves.add(tag.chave());
      }
    }

    return chaves;
  }

  int indiceCategoria(String dimensaoId, String rotulo) {
    ArrayList<CategoriaFiltro> categorias = filtros.categoriasDaDimensao(dimensaoId);
    for (int i = 0; i < categorias.size(); i++) {
      if (categorias.get(i).rotulo.equals(rotulo)) {
        return i;
      }
    }
    return 0;
  }

  boolean dentroDoPainel(float mx, float my) {
    return mx >= X && mx <= X + BODY_W && my >= Y && my <= limiteInferiorPainel();
  }

  boolean dentroListaTags(float mx, float my) {
    return mx >= X && mx <= X + BODY_W && my >= yListaTags() && my <= limiteInferiorPainel();
  }

  int alturaListaTagsVisivel() {
    return max(0, limiteInferiorPainel() - yListaTags());
  }

  int alturaCorpo() {
    return max(0, height - BODY_Y);
  }

  int limiteInferiorPainel() {
    return height;
  }

  int maxScrollTags() {
    return maxScrollTags(tagsParaExibir().size());
  }

  int maxScrollTags(int totalTags) {
    return max(0, totalTags * TAG_ROW_H - alturaListaTagsVisivel());
  }

  float alturaThumbTags(int totalTags) {
    float visibleH = alturaListaTagsVisivel();
    float contentH = max(1, totalTags * TAG_ROW_H);
    return constrain(visibleH * (visibleH / contentH), SCROLL_MIN_THUMB_H, visibleH);
  }

  float yThumbTags(int totalTags) {
    float trackY = yListaTags();
    float trackH = alturaListaTagsVisivel();
    float thumbH = alturaThumbTags(totalTags);
    float maxThumbY = max(1, trackH - thumbH);
    float maxScroll = max(1, maxScrollTags(totalTags));
    return trackY + map(scrollTags, 0, maxScroll, 0, maxThumbY);
  }

  color corDimensaoAtiva() {
    return corDimensao(dimensaoAtivaId);
  }

  color corDimensao(String dimensaoId) {
    if (dimensaoId.equals(filtros.DIM_MATERIAL)) {
      return COR_MATERIAL;
    }
    if (dimensaoId.equals(filtros.DIM_TECNICAS)) {
      return COR_TECNICA;
    }
    if (dimensaoId.equals(filtros.DIM_ESTETICO)) {
      return COR_ESTETICO;
    }
    return COR_TIPO_OBRA;
  }

  void desenharImagemCentralizada(PImage img, float cx, float cy, float maxW, float maxH) {
    float escala = min(maxW / img.width, maxH / img.height);
    float w = img.width * escala;
    float h = img.height * escala;
    image(img, cx - w/2, cy - h/2, w, h);
  }

  void desenharTextoCentralizado(String texto, float centroX, float centroY) {
    textAlign(CENTER, BASELINE);
    text(texto, centroX, baselineCentral(centroY));
  }

  void desenharTextoAlinhadoAoCirculo(String texto, float xTexto, float centroY) {
    textAlign(LEFT, BASELINE);
    text(texto, xTexto, baselineCentral(centroY));
  }

  float baselineCentral(float centroY) {
    return centroY + (textAscent() - textDescent()) / 2.0f;
  }

  float tamanhoTextoAjustado(String texto, PFont fonte, float tamanhoMaximo, float tamanhoMinimo, float larguraMaxima) {
    float tamanho = tamanhoMaximo;
    textFont(fonte);
    textSize(tamanho);

    while (textWidth(texto) > larguraMaxima && tamanho > tamanhoMinimo) {
      tamanho -= 1;
      textSize(tamanho);
    }

    return tamanho;
  }
}

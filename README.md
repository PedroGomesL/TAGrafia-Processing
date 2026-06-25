# Sistema de Visualização Dinâmica de Obras de Design

Este repositório contém o código-fonte de um sistema de visualização dinâmica de dados focado na história do design. O projeto abrange 245 obras cadastradas e permite a exploração interativa por meio de diferentes visualizações.

## Funcionalidades

O sistema oferece diversas formas de interação com o acervo de design:

*   **Três modos de visualização:** Linha do tempo, Bolhas e Circular.
*   **Filtros de dados:** Busca e categorização por tipo de obra, materiais, aspectos estéticos e técnicas de construção.
*   **Detalhes das obras:** Interface lateral com informações completas e imagens de cada produto selecionado.
*   **Exportação:** Opção para salvar a visualização atual nos formatos PDF, JPG e SVG.

## Tecnologias Utilizadas

*   **[Processing](https://processing.org/):** Linguagem de programação e ambiente de desenvolvimento (baseado em Java) para a criação das lógicas de visualização e interface gráfica.
*   **Arquivos TSV:** Estruturação leve e em formato de texto para a base de dados.

## Estrutura de Dados

A base de dados do projeto divide as informações em quatro arquivos principais no formato `.tsv` (Valores Separados por Tabulação):

1.  Escolas
2.  Eventos e contexto histórico
3.  Produtos brasileiros
4.  Produtos internacionais

As imagens das obras dividem-se em dois diretórios específicos: um para o banco de imagens com obras nacionais e outro para as obras internacionais.

## Como Executar o Projeto

Para testar o sistema localmente, siga os passos abaixo:

1.  Faça o download e a instalação da IDE do [Processing](https://processing.org/download).
2.  Clone este repositório para a sua máquina local (`git clone <link-do-repositorio>`) ou faça o download em zip.
3.  Abra a pasta do projeto e execute o arquivo principal `.pde` com o Processing.
4.  Pressione o botão "Run" (Executar) na IDE.

## Limitações da Versão Atual

*   **Tela de Correlação:** Atualmente, a funcionalidade de correlação sugere apenas obras similares. A capacidade de sugerir e relacionar eventos, contextos históricos ou escolas de design não integra o escopo desta versão.
*   **Visualização Geográfica:** A proposta de visualização em formato de mapa-múndi não foi implementada na versão final e permanece como sugestão para trabalhos futuros.

## Autor e orientador

**Pedro Henrique Gomes Lima**
**José Neto de Faria"**
Bacharelado em Design Digital – Universidade Federal do Ceará (UFC)

# Estratégia de Expansão de uma Distribuidora de Combustíveis

## Contexto

Este projeto simula o cenário de uma distribuidora de combustíveis (fictícia) regional, de médio-grande porte, com atuação consolidada em Minas Gerais.

A empresa opera com duas bases logísticas de distribuição:

- Base principal em Betim (MG), abastecida pela Refinaria Gabriel Passos (REGAP)
- Base secundária em Oliveira (MG), também abastecida pela REGAP

A operação é estruturada ao longo de um eixo logístico principal, utilizando as rodovias BR-381 e BR-262 como corredores de distribuição.

O modelo operacional segue o fluxo:
`Refinaria → Base de distribuição → Postos nos municípios atendidos`

## Área de Atuação Atual

A empresa possui atuação consolidada nas seguintes regiões:

### Região Intermediária de Belo Horizonte

- Região Imediata de Belo Horizonte: [Belo Horizonte, Contagem, Betim, Mateus Leme, Ribeirão das Neves, Juatuba]

### Região Intermediária de Divinópolis

- Região Imediata de Pará de Minas: [Pará de Minas, Igaratinga]
- Região Imediata de Oliveira: [Itaguara, Carmópolis de Minas, Oliveira]
- Região Imediata de Divinópolis: [Itatiaiuçu, Itaúna, Divinópolis, São Gonçalo do Pará, Nova Serrana]

### Região Intermediária de Varginha

- Região Imediata de Lavras: [Lavras, Santo Antônio do Amparo, Perdões]
- Região Imediata de Três Corações: [Três Corações, Carmo da Cachoeira]
- Região Imediata de Varginha: [Varginha]

Além disso, a empresa atende postos localizados ao longo das rodovias BR-381 e BR-262.

## Problema de Negócio

A empresa busca ampliar sua área de atuação a partir das bases logísticas existentes em **Betim** e **Oliveira**.

O objetivo da análise é identificar **quais novos mercados apresentam maior potencial de expansão considerando a capacidade logística atual da empresa**.

A análise busca responder:

- Quais municípios apresentam maior potencial de mercado?
- Quais desses municípios são logisticamente acessíveis a partir das bases atuais?
- Quais regiões e eixos de expansão concentram as melhores oportunidades?
- Até onde a estrutura atual permite expandir a atuação de forma adequada?

## Hipóteses de Expansão

Para delimitar o universo de mercados analisados, a empresa considera quatro eixos rodoviários como possíveis direções de expansão.

Os eixos representam regiões nas quais a empresa pretende avaliar a existência de novos mercados, considerando tanto o potencial dos municípios quanto sua conexão logística com as bases atuais.

### Hipótese 1 — Expansão Oeste

**Eixo principal: BR-262**

Avaliação de municípios conectados ao corredor da BR-262 e às principais rodovias de acesso, em direção ao oeste de Minas Gerais.

### Hipótese 2 — Expansão Sudoeste

**Eixo principal: BR-381**

Avaliação de municípios conectados ao corredor da BR-381, em direção ao Sul de Minas e, potencialmente, ao estado de São Paulo.

### Hipótese 3 — Expansão Sudeste

**Eixo principal: BR-499**

Avaliação de municípios conectados ao eixo da BR-499 e às rodovias de acesso ao sudeste de Minas Gerais.

### Hipótese 4 — Expansão Noroeste

**Eixo principal: BR-040**

Avaliação de municípios conectados ao corredor da BR-040 e às regiões atendidas por seus principais acessos.

---

## Fontes de Dados

Os dados foram obtidos a partir de fontes públicas oficiais:

Bases utilizadas:

- **ANP (Agência Nacional do Petróleo)**

  - Vendas de combustíveis por município (gasolina, diesel, etanol)
- **IBGE (Instituo Brasileiro de Geografia e Estatística)**

  - PIB dos municípios (total, per capita e composição setorial)
  - Mapas de regiões
  - Códigos dos municípios e regiões
- **SENATRAN (Secretaria Nacional de Trânsito)**

  - Frota de veículos por tipo e município (dados de dezembro de cada ano como proxy anual)
- **GitHub: kelvins/municípios-brasileiros**

  - Coordenadas geográficas dos municípios brasileiros

## Métricas e Scores Analíticos

O projeto utiliza métricas derivadas para representar demanda, perfil econômico e viabilidade logística dos municípios analisados.

As métricas incluem:

- Volume total de combustíveis vendidos
- Intensidade de consumo por veículo
- Crescimento histórico de vendas e frota
- Participação setorial do VAB municipal
- PIB per capita relativo ao estado
- Distância logística até as bases operacionais

A partir das métricas, são calculados três scores dimensionais:

- `Score de Demanda`: Mede o potencial de consumo e intensidade de mercado.
- `Score Econômico`: Avalia a qualificação econômica dos municípios com base em renda e perfil produtivo.
- `Score Logístico`: Representa a acessibilidade do município a partir da estrutura atual, considerando a distância até a base de atendimento.

Os scores são posteriormente consolidados em:
- `Score Final`: Atratividade do município para expansão a partir da estrutura atual.

---

## Estrutura do Projeto

```text
analise-expansao-combustiveis/
├── dados/
│   ├── brutos/               # Dados originais das fontes
│   ├── intermediarios/       # Dados limpos e padronizados
│   ├── modelados/            # Dados modelados, prontos para BI
│   ├── dominio/              # Dados de domínio do projeto
│   └── banco_dados.duckdb    # Banco de dados local
│
├── sql/
│   ├── 1-metricas/           # Cálculo de métricas
│   ├── 2-pontuacoes/         # Cálculo dos scores
│   ├── 3-tabelas-analiticas/ # Consolidação das tabelas finais
│   └── ddl                   # Esquema SQL
│
└── src/
    ├── arquivos/             # Leitura e escrita de arquivos
    ├── bd/                   # Realiza operações ligadas ao BD
    ├── configs/              # Configurações estáticas e mapeamentos
    ├── pipelines/            # Fluxos de tratamento de dados
    ├── transformadores/      # Funções utilitárias de transformação
    ├── utils/                # Funções utilitárias gerais
    └── main.py               # Ponto de entrada da aplicação
```

## Pipeline de Dados

1. Coleta de dados:
   - Frota (SENATRAN)
   - PIB municipal (IBGE)
   - Vendas e preços (ANP)
   - Coordenadas dos municípios (Rep. Github)

2. Tratamento (Python):
   - Limpeza e padronização
   - Consolidação de séries históricas

3. Modelagem Analítica (SQL | DuckDB):
   - Criação de métricas derivadas
   - Construção de scores dimensionais
   - Consolidação das tabelas analíticas

4. Análise e Visualização:
   - Exploração dos resultados
   - Mapas e indicadores no Data Studio
   - Avaliação de cenários de expansão

## Ferramentas Utilizadas

- SQL
- Duck DB
- Python (Pandas)
- Looker Studio (Data Studio)

---

## Como executar

```bash
git clone <URL_DO_REPOSITORIO>
cd <NOME_DO_REPOSITORIO>

# Criar virtual environment (venv)
python3 -m venv .venv

# Ativar a virtual environment:

# Linux / macOS
source .venv/bin/activate

# Windows
.venv\Scripts\activate

# Instalar dependências
pip install -r requirements.txt
```

## Observações

- Dados de PIB disponíveis até 2023 (anos posteriores tratados como ausência ou proxy)
- PIB a preços correntes (não ajustado pela inflação)

## Possíveis Extensões

Uma evolução natural do projeto seria avaliar a expansão da própria estrutura logística.

Caso os resultados indiquem mercados relevantes além do alcance das bases atuais, uma etapa posterior poderia investigar a implantação de uma **nova base de distribuição**, considerando:

- localização estratégica em relação aos mercados potenciais;
- proximidade e acesso aos principais eixos rodoviários;
- área potencial de atendimento;
- alternativas de abastecimento pela **REGAP** e **REPLAN**.

Essa extensão permitiria evoluir a análise de uma decisão de **expansão a partir da rede atual** para uma decisão de **expansão da própria rede logística**.

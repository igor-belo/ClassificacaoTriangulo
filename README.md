# Classificação de Triângulos - API Delphi + Horse

Este projeto é uma aplicação REST desenvolvida com **Delphi + Horse + FireDAC**, com o objetivo de classificar triângulos a partir de três lados informados. A API também registra os dados em um banco de dados PostgreSQL e conta com **testes automatizados**.

---

## Finalidade

A aplicação recebe os lados de um triângulo, valida se eles formam um triângulo válido e classifica como:

- **Equilátero**: todos os lados iguais
- **Isósceles**: dois lados iguais
- **Escaleno**: todos os lados diferentes
- **Invalido**: lados que não formam um triângulo

Todos os registros (inclusive inválidos) são salvos no banco de dados com o tipo correspondente **sem acentos**, mas exibidos corretamente na interface.

---

## Testes automatizados

Os testes utilizam **DUnit** e estão organizados em units separadas por categoria (`Post`, `Get`, `Configuração`). Ao executar os testes, um log completo é salvo no arquivo:

```
tests_results.txt
```

Este arquivo contém:

- Resumo dos testes (quantos passaram, falharam, etc)
- Detalhes por teste: nome, método, rota, JSON enviado, resultado esperado e obtido
- Data/hora de cada execução

---

## Requisitos

- Delphi 10+ (usando FireDAC)
- PostgreSQL (porta padrão: `5432`)
- Bibliotecas:
  - [`Horse`](https://github.com/HashLoad/horse)
  - [`Horse.Jhonson`](https://github.com/HashLoad/horse-jhonson) (para JSON)
  - FireDAC

---

## Instalação e configuração

1. Clone este repositório.
2. Configure o arquivo `connection.ini` na pasta do executável com os dados do PostgreSQL:

```ini
[BD]
Host=localhost
Database=TRIANGULOS
Usuario=[Usuário do postgres]
Senha=[Senha do usuário do postgres]
```

>  Se o banco de dados não existir, o sistema perguntará se deseja criá-lo automaticamente.

3. Compile e execute a aplicação Delphi principal (`ClassificacaoTriangulo.dpr`).

---

## Rotas da API

### 🔹 `POST /triangulos`

Cria um novo triângulo.

#### Corpo (JSON):

```json
{
  "lado_a": 5,
  "lado_b": 5,
  "lado_c": 5
}
```

#### Resposta:

```json
{
  "lado_a": "5",
  "lado_b": "5",
  "lado_c": "5",
  "tipo": "Equilátero",
  "datahora": "12/05/2025 16:00:00"
}
```

---

### 🔹 `GET /triangulos`

Retorna lista de triângulos.

#### Filtros disponíveis (query params):

- `id`
- `tipo`
- `data_inicio`
- `data_fim`
- `pagina` (paginação)

#### Exemplo:

```
GET /triangulos?tipo=Escaleno&pagina=1
```

---

### 🔹 `GET /triangulos/contagem`

Retorna a contagem de triângulos por tipo.

#### Resposta:

```json
{
  "Equilatero": "5",
  "Escaleno": "3",
  "Invalido": "2",
  "total_geral": "10"
}
```

---

## Executar testes

1. Na interface principal, clique em **Executar Testes**.
2. Um arquivo chamado `tests_results.txt` será gerado na pasta do executável com todos os resultados.

---

##  Autor

**Igor Belo - Desenvolvedor Delphi/Python** 

---

##  Licença

Este projeto é open-source e livre para uso didático e acadêmico.

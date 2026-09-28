# AvaliacaoCartSys

Sistema desktop em Delphi para gestão de clientes, produtos e vendas, com integração a uma API REST de financeiro. A aplicação usa a arquitetura VCL do Delphi e se comunica com uma API backend em .NET para listar, criar, atualizar, excluir e consultar dados de negócio.

## Visão geral

O projeto foi estruturado como um ERP de cadastro e controle operacional, incluindo:

- Cadastro, listagem, edição e exclusão de clientes
- Cadastro, listagem, edição e exclusão de produtos
- Gestão de vendas e itens da venda
- Controle de status da venda
- Geração de confirmação em PDF
- Comunicação com API externa via HTTP/JSON

A interface principal é um menu lateral com acesso aos módulos de cadastro e listagem de clientes, produtos e vendas.

## Tecnologias utilizadas

- Delphi / RAD Studio com VCL
- Indy para requisições HTTP
- JSON para troca de dados com a API
- Arquitetura orientada a controllers e serviços
- API REST de referência em .NET com contrato OpenAPI

## Estrutura do projeto

```text
AvaliacaoCartSys/
??? AvaliacaoCartSys.dpr              # ponto de entrada da aplicação
??? AvaliacaoCartSys.dproj            # projeto Delphi
??? definition.json                   # especificação OpenAPI/Swagger da API
??? controller/                       # controladores dos módulos
?   ??? ClienteController.pas
?   ??? ProdutoController.pas
?   ??? VendaController.pas
??? services/                         # clientes HTTP, DTOs, interfaces e exceções
?   ??? API/
?   ??? HttpClient/
?   ??? API.Response.Base.pas
??? view/                             # formulários da interface VCL
?   ??? View.Principal.pas
?   ??? View.Cadastro.Cliente.pas
?   ??? View.Cadastro.Produto.pas
?   ??? View.Cadastro.Venda.pas
?   ??? View.Listagem.Cliente.pas
?   ??? View.Listagem.Produto.pas
?   ??? View.Listagem.Venda.pas
?   ??? ...
??? model/                            # modelos/domain do sistema
??? bin/                              # executável gerado
??? dcu/                              # arquivos de compilação
??? images/                           # recursos visuais
??? __history/                        # backups do Delphi
??? __recovery/                       # recuperação de arquivos
??? README.md                         # documentação do projeto
```

## Arquitetura da aplicação

O fluxo principal da aplicação segue este padrão:

1. A interface VCL em `view/` abre os formulários e eventos.
2. Os módulos de `controller/` encapsulam as operações de negócio.
3. A camada de `services/API` envia/recebe JSON para a API backend.
4. A API retorna DTOs e dados em formato JSON.
5. A tela atualiza a interface com os dados recebidos.

Exemplo de integração:

- `ClienteController` -> `FinanceiroApiClient` -> `/api/Cliente`
- `ProdutoController` -> `FinanceiroApiClient` -> `/api/Produto`
- `VendaController` -> `FinanceiroApiClient` -> `/api/Venda`, `/api/VendaItens`, `/api/Pagamento`

## Funcionalidades disponíveis

### Clientes
- Listar todos os clientes
- Obter cliente por ID
- Incluir novo cliente
- Atualizar cliente
- Excluir cliente

### Produtos
- Listar todos os produtos
- Obter produto por ID
- Incluir novo produto
- Atualizar produto
- Excluir produto

### Vendas
- Listar vendas
- Incluir venda
- Editar venda
- Cancelar venda
- Pagar venda
- Adicionar, editar e excluir itens da venda
- Gerar confirmação em PDF

## Requisitos

Para compilar e executar este projeto, você precisa de:

- Windows
- Embarcadero Delphi / RAD Studio 13 com suporte a VCL
- A API Financeiro em execução
- Acesso à URL base da API

## Dependência da API

A aplicação está configurada para consumir a API na URL padrão:

```text
https://localhost:7263
```

Essa base é usada nos controllers:

```pas
constructor TClienteController.Create(const ABaseUrl: string = 'https://localhost:7263');
constructor TProdutoController.Create(const ABaseUrl: string = 'https://localhost:7263');
constructor TVendaController.Create(const ABaseUrl: string = 'https://localhost:7263');
```

Se a sua API estiver em outra porta ou host, ajuste a URL no construtor correspondente.

## Como executar

### 1. Prepare a API backend

Certifique-se de que a API backend da aplicação Financeiro está disponível e acessível em `https://localhost:7263`.

### 2. Abra o projeto no Delphi

- Abra o arquivo `AvaliacaoCartSys.dproj` no RAD Studio.
- Compile o projeto.
- Execute a aplicação.

### 3. Use o sistema

A tela principal oferece o menu com opções para:

- Clientes
- Produtos
- Vendas

## Observações importantes

- O projeto foi desenvolvido para ambiente Windows, utilizando VCL.
- A comunicação com o backend é feita por HTTP com autenticação/validação de status HTTP e parsing de JSON.
- A aplicação fecha arquivos PDF temporários no encerramento do formulário principal.
- A especificação da API está descrita em `definition.json`, o que facilita integração e documentação.

## Conclusão

Este projeto representa uma aplicação desktop de gestão financeira/operacional, integrando interface Delphi com API REST de negócio. Ele fornece um fluxo completo de cadastro e operações para clientes, produtos e vendas, com foco em funcionamento prático e manutenção por camadas.

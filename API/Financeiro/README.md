# Financeiro API

Descrição
---------
Financeiro API é um serviço REST para gerenciamento de clientes, produtos, vendas e pagamentos. Gera PDFs (confirmação de pedido e comprovante de pagamento) usando QuestPDF e envia comprovantes por e‑mail via SMTP.

Pré-requisitos
--------------
- .NET 10 SDK
- Banco Firebird (configurar connection string em appsettings.json)
- Acesso a servidor SMTP para envio de e-mails

Configuração
------------
Edite o arquivo `Financeiro.API/appsettings.json` e configure as seções:

- ConnectionStrings: `DefaultConnection` (Firebird)
- Smtp: host, port, user, password, enableSsl, from

Exemplo:

```
"Smtp": {
  "Host": "smtp.exemplo.com",
  "Port": 587,
  "User": "usuario@exemplo.com",
  "Password": "sua-senha",
  "EnableSsl": true,
  "From": "remetente@exemplo.com"
}
```

Build e execução
-----------------
No Visual Studio: abra a solução `Financeiro.slnx` e execute o projeto `Financeiro.API`.
Ou pela CLI:

dotnet build
dotnet run --project Financeiro.API/Financeiro.API.csproj

Endpoints principais
--------------------
Base path: /api

Cliente
- POST /api/cliente
  - Cria cliente
  - Body: ClientePostDTO
- PUT /api/cliente
  - Atualiza cliente
- DELETE /api/cliente/{id}
- GET /api/cliente/{id}
- GET /api/cliente

Produto
- POST /api/produto
- PUT /api/produto
- DELETE /api/produto/{id}
- GET /api/produto
- GET /api/produto/{id}

Venda
- POST /api/venda
  - Cria venda (VendaPostDTO). Ex.: itens, clienteId, status
- PUT /api/venda
  - Atualiza venda (VendaPutDTO). Se o status for alterado para Pago, o sistema:
	1) Define pagoEm na venda
	2) Cria um Pagamento com Tipo aleatório e valor igual ao total da venda
	3) Atualiza o Pagamento para PagamentoStatus.Pago
	4) Gera comprovante em PDF e tenta enviar por e‑mail para o cliente (se tiver)
- DELETE /api/venda/{id}
- GET /api/venda/{id}
- GET /api/venda
- POST /api/venda/{vendaId}/itens
- PUT /api/venda/itens
- DELETE /api/venda/itens/{id}
- GET /api/vendas/{id}/confirmacao-pdf (retorna PDF confirmação de pedido)

Pagamento
- POST /api/pagamento
  - Cria pagamento (PagamentoPostDTO)
- PUT /api/pagamento
  - Atualiza status do pagamento (PagamentoPutDTO). Se Status = Pago, o campo CompletedAt é preenchido.
- DELETE /api/pagamento/{id}
- GET /api/pagamento/{id}
- GET /api/pagamento

Modelos (DTOs) relevantes
-------------------------
- ClientePostDTO / ClientePutDTO / ClienteGetDTO
- ProdutoPostDTO / ProdutoPutDTO / ProdutoGetDTO
- VendaPostDTO / VendaPutDTO / VendaGetDTO
- VendaItemPostDTO / VendaItemGetDTO
- PagamentoPostDTO: { VendaId, Valor, Type }
- PagamentoPutDTO: { Id, Status, CompletedAt, TransacaoId }

Geração de PDF
--------------
- Implementado em Financeiro.Infra.Reports/QuestPdfGenerator.cs
- Métodos disponíveis:
  - GenerateOrderConfirmationAsync(VendaGetDTO venda) => byte[] (PDF)
  - GeneratePaymentReceiptAsync(PagamentoGetDTO pagamento) => byte[] (PDF)

Envio de e-mail
---------------
- Implementado em Financeiro.Infra.Reports/SmtpEmailSender.cs
- Interface: Financeiro.Application.Interfaces.IEmailSender
- Lê configuração em `Smtp` no appsettings.json
- Método: SendEmailAsync(string to, string subject, string htmlBody, IEnumerable<(string FileName, byte[] Content)>? attachments = null)

Comportamento automático de envio
---------------------------------
Ao atualizar uma venda para o status Pago o fluxo gera e envia automaticamente o comprovante de pagamento para o e‑mail do cliente (se cadastrado). O envio é envolvido em try/catch para não bloquear a atualização da venda em caso de falha no envio.

Dependências e DI
------------------
Os serviços são registrados em `Financeiro.Infra.Ioc/DependencyInjection.cs`. Serviços importantes:
- IPdfGenerator -> QuestPdfGenerator
- IEmailSender -> SmtpEmailSender

Observações
-----------
- Em produção, considere usar MailKit/MimeKit em vez de System.Net.Mail para maior controle e compatibilidade.
- Logging e tratamento de erros no envio de e‑mail podem ser melhorados (atualmente silenciado no fluxo da venda).
- Testes automatizados não foram fornecidos neste README; recomenda‑se adicionar testes para os serviços críticos.

Contato / manutenção
--------------------
Repositório: https://github.com/Elnisky/ERP (clone já presente no workspace)

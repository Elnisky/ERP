using Financeiro.Application.DTOs.Venda;
using Financeiro.Application.DTOs.Pagamento;
using Financeiro.Application.Interfaces;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using System.Threading.Tasks;

namespace Financeiro.Infra.Reports
{
    public class QuestPdfGenerator : IPdfGenerator
    {
        public Task<byte[]> GenerateOrderConfirmationAsync(VendaGetDTO venda)
        {
            var doc = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(20);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(12));

                    page.Header().Text("Confirmação de Pedido").FontSize(20).Bold();

                    page.Content().Column(column =>
                    {
                        column.Item().Text($"Pedido: {venda.Id}");
                        column.Item().Text($"Cliente: {venda.Cliente?.Nome}");
                        column.Item().Text($"Data: {venda.CriadoEm:yyyy-MM-dd HH:mm}");
                        column.Item().Text($"Status: {venda.Status}");
                        column.Item().Text($"Total: R$ {venda.Total:0.00}");

                        column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);

                        if (venda.Itens != null)
                        {
                            column.Item().Text("Itens:").Bold();
                            foreach (var item in venda.Itens)
                            {
                                column.Item().Text($"- ProdutoId: {item.ProdutoId}  Quantidade: {item.Quantidade}  Valor Unit.: R$ {item.ValorUnitario:0.00}  Total: R$ {item.ValorTotal:0.00}");
                            }
                        }
                    });

                    page.Footer().AlignCenter().Text(x =>
                    {
                        x.Span("Gerado por Financeiro API");
                    });
                });
            });

            var bytes = doc.GeneratePdf();
            return Task.FromResult(bytes);
        }

        public Task<byte[]> GeneratePaymentReceiptAsync(PagamentoGetDTO pagamento)
        {
            var doc = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Size(PageSizes.A4);
                    page.Margin(20);
                    page.PageColor(Colors.White);
                    page.DefaultTextStyle(x => x.FontSize(12));

                    page.Header().Column(header =>
                    {
                        header.Item().Text("Comprovante de Pagamento").FontSize(18).Bold();
                        header.Item().Text($"Pagamento ID: {pagamento.Id}").FontSize(10);
                    });

                    page.Content().Column(column =>
                    {
                        column.Spacing(5);
                        column.Item().Text($"Venda ID: {pagamento.VendaId}");
                        column.Item().Text($"Data do Registro: {pagamento.CriadoEm:yyyy-MM-dd HH:mm}");
                        column.Item().Text($"Data de Conclusão: {(pagamento.CompletedAt.HasValue ? pagamento.CompletedAt.Value.ToString("yyyy-MM-dd HH:mm") : "-")}");
                        column.Item().Text($"Valor: R$ {pagamento.Valor:0.00}");
                        column.Item().Text($"Tipo: {pagamento.Type}");
                        column.Item().Text($"Status: {pagamento.Status}");

                        column.Item().LineHorizontal(1).LineColor(Colors.Grey.Lighten2);

                        column.Item().Text("Observações:").Bold();
                        column.Item().Text("Este é um comprovante gerado automaticamente pelo sistema. Não responder.");
                    });

                    page.Footer().AlignCenter().Text(x =>
                    {
                        x.Span("Gerado por Financeiro API - ");
                        x.Span(DateTime.Now.ToString("yyyy-MM-dd HH:mm UTC")).SemiBold();
                    });
                });
            });

            var bytes = doc.GeneratePdf();
            return Task.FromResult(bytes);
        }
    }
}

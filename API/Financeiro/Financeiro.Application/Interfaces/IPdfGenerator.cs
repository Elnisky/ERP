using System.Threading.Tasks;
using Financeiro.Application.DTOs.Venda;
using Financeiro.Application.DTOs.Pagamento;

namespace Financeiro.Application.Interfaces
{
    public interface IPdfGenerator
    {
        Task<byte[]> GenerateOrderConfirmationAsync(VendaGetDTO venda);
        Task<byte[]> GeneratePaymentReceiptAsync(PagamentoGetDTO pagamento);
    }
}

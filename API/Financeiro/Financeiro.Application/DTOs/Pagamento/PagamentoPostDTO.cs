using System.ComponentModel.DataAnnotations;
using Financeiro.Domain.Entities;

namespace Financeiro.Application.DTOs.Pagamento
{
    public class PagamentoPostDTO
    {
        [Required(ErrorMessage = "O campo VendaId é obrigatório.")]
        public int VendaId { get; set; }

        [Required(ErrorMessage = "O campo Valor é obrigatório.")]
        public decimal Valor { get; set; }

        [Required(ErrorMessage = "O campo Type é obrigatório.")]
        public TipoPagamento Type { get; set; }
    }
}

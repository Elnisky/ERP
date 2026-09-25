using System;
using Financeiro.Domain.Entities;

namespace Financeiro.Application.DTOs.Pagamento
{
    public class PagamentoGetDTO
    {
        public int Id { get; set; }
        public int VendaId { get; set; }
        public DateTime CriadoEm { get; set; }
        public DateTime? CompletedAt { get; set; }
        public decimal Valor { get; set; }
        public TipoPagamento Type { get; set; }
        public PagamentoStatus Status { get; set; }
    }
}

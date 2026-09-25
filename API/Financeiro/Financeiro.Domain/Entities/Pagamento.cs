using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Entities
{
    public enum TipoPagamento
    {
        Dinheiro,
        CartaoCredito,
        CartaoDebito,
        Pix
    }

    public enum PagamentoStatus
    {
        Pendente,
        Pago,
        Cancelado
    }

    public class Pagamento
    {
        public int Id { get; set; }
        public int VendaId { get; set; }
        public Venda Venda { get; set; }
        public DateTime CriadoEm { get; set; } = DateTime.UtcNow;
        public DateTime? CompletedAt { get; set; }
        public decimal Valor { get; set; }
        public TipoPagamento Type { get; set; }
        public PagamentoStatus Status { get; set; } = PagamentoStatus.Pendente;
        public string TransacaoId{ get; set; } 
    }

}

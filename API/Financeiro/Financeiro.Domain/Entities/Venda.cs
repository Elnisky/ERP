using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Net.ServerSentEvents;
using System.Text;

namespace Financeiro.Domain.Entities
{
    public enum StatusVenda
    {
        Orcamento = 0,
        PagamentoPendente = 1,
        Pago = 2,
        Cancelado = 3
    }

    public class Venda
    {
        public int Id { get; set; }

        public DateTime CriadoEm { get; set; } = DateTime.UtcNow;

        public DateTime? PagoEm { get; set; }

        public int ClienteId { get; set; }

        public Cliente Cliente { get; set; }

        public StatusVenda Status { get; set; } = StatusVenda.Orcamento;

        public decimal Total { get; set; }

        public ICollection<VendaItem> VendaItens { get; set; }

        public ICollection<Pagamento> Pagamentos { get; set; }
    }
}

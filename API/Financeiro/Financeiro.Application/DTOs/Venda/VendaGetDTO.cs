using Financeiro.Domain.Entities;
using Financeiro.Application.DTOs.Cliente;
using Financeiro.Application.DTOs.VendaItem;
using Financeiro.Application.DTOs.Pagamento;
using System;
using System.Collections.Generic;

namespace Financeiro.Application.DTOs.Venda
{
    public class VendaGetDTO
    {
        public int Id { get; set; }
        public DateTime CriadoEm { get; set; }
        public DateTime? PagoEm { get; set; }
        public int ClienteId { get; set; }
        public StatusVenda Status { get; set; }
        public decimal Total { get; set; }
        public ClienteGetDTO Cliente { get; set; }
        public List<VendaItemGetDTO> Itens { get; set; }
        public List<PagamentoGetDTO> Pagamentos { get; set; }
    }
}

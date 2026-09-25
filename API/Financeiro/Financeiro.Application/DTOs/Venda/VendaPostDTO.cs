using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using Financeiro.Domain.Entities;
using Financeiro.Application.DTOs.VendaItem;

namespace Financeiro.Application.DTOs.Venda
{
    public class VendaPostDTO
    {
        [Required(ErrorMessage = "O campo ClienteId é obrigatório.")]
        public int ClienteId { get; set; }

        public StatusVenda Status { get; set; } = StatusVenda.Orcamento;

        public List<VendaItemPostDTO> Itens { get; set; }
    }
}

using System;
using System.ComponentModel.DataAnnotations;
using Financeiro.Domain.Entities;

namespace Financeiro.Application.DTOs.Pagamento
{
    public class PagamentoPutDTO
    {
        [Required(ErrorMessage = "O campo identificador do pagamento é obrigatório.")]
        public int Id { get; set; }

        public PagamentoStatus Status { get; set; }

        public DateTime? CompletedAt { get; set; }

        public string TransacaoId { get; set; }
    }
}

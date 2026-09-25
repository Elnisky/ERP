using System;
using System.ComponentModel.DataAnnotations;
using Financeiro.Domain.Entities;

namespace Financeiro.Application.DTOs.Venda
{
    public class VendaPutDTO
    {
        [Required(ErrorMessage = "O campo identificador da venda é obrigatório.")]
        public int Id { get; set; }

        public StatusVenda Status { get; set; }

        public DateTime? PagoEm { get; set; }
    }
}

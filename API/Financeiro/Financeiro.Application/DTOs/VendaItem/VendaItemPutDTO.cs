using System.ComponentModel.DataAnnotations;

namespace Financeiro.Application.DTOs.VendaItem
{
    public class VendaItemPutDTO
    {
        [Required(ErrorMessage = "O campo identificador do item é obrigatório.")]
        public int Id { get; set; }

        [Required(ErrorMessage = "O campo Quantidade é obrigatório.")]
        public int Quantidade { get; set; }

        [Required(ErrorMessage = "O campo ValorUnitario é obrigatório.")]
        public decimal ValorUnitario { get; set; }
    }
}

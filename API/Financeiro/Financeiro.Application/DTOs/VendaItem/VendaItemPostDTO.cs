using System.ComponentModel.DataAnnotations;

namespace Financeiro.Application.DTOs.VendaItem
{
    public class VendaItemPostDTO
    {
        [Required(ErrorMessage = "O campo VendaId é obrigatório.")]
        public int VendaId { get; set; }

        [Required(ErrorMessage = "O campo ProdutoId é obrigatório.")]
        public int ProdutoId { get; set; }

        [Required(ErrorMessage = "O campo Quantidade é obrigatório.")]
        public int Quantidade { get; set; }

        [Required(ErrorMessage = "O campo ValorUnitario é obrigatório.")]
        public decimal ValorUnitario { get; set; }
    }
}

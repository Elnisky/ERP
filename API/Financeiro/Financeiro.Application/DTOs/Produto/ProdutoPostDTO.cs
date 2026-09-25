using System.ComponentModel.DataAnnotations;

namespace Financeiro.Application.DTOs.Produto
{
    public class ProdutoPostDTO
    {
        [Required(ErrorMessage = "O campo Nome é obrigatório.")]
        [MaxLength(200, ErrorMessage = "O campo Nome deve ter no máximo 200 caracteres.")]
        public string Nome { get; set; }

        [Required(ErrorMessage = "O campo Preco é obrigatório.")]
        public decimal Preco { get; set; }

        [Required(ErrorMessage = "O campo QuantidadeEstoque é obrigatório.")]
        public int QuantidadeEstoque { get; set; }
    }
}

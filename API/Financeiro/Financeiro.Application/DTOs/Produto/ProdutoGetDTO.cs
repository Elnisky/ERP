using System;

namespace Financeiro.Application.DTOs.Produto
{
    public class ProdutoGetDTO
    {
        public int Id { get; set; }
        public string Nome { get; set; }
        public decimal Preco { get; set; }
        public int QuantidadeEstoque { get; set; }
    }
}

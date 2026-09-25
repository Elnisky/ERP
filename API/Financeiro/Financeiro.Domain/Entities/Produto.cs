using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Entities
{
    public class Produto
    {
        public int Id { get; set; }
        public string Nome { get; set; }
        public decimal Preco { get; set; }
        public int QuantidadeEstoque { get; set; }
        public ICollection<VendaItem> VendaItens { get; set; }
    }

}

using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Entities
{
    public class VendaItem
    {
        public int Id { get; set; }
        public int VendaId { get; set; }
        public Venda Venda { get; set; }
        public int ProdutoId { get; set; }
        public Produto Produto { get; set; }
        public int Quantidade { get; set; }
        public decimal ValorUnitario { get; set; }
        public decimal ValorTotal { get; set; } // Quantidade * ValorUnitario
    }
}

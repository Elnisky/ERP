using System;
using System.Collections.Generic;
using System.Text;
using Financeiro.Application.DTOs.Venda;

namespace Financeiro.Application.DTOs.Cliente
{
    public class ClienteGetDTO
    {
        public int Id { get; set; }
        public string Nome { get; set; }
        public string Cpf { get; set; }
        public string Email { get; set; }
        public string Telefone { get; set; }
        public DateTime DataCadastro { get; set; }
        public List<VendaGetDTO> Vendas { get; set; }
    }
}

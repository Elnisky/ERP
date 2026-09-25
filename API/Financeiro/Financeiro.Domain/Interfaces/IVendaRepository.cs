using Financeiro.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Interfaces
{
    public interface IVendaRepository
    {
        Task<Venda> GetByIdAsync(int id);
        Task<List<Venda>> GetAllAsync();
        Task<Venda> AddAsync(Venda venda);
        Task<Venda> UpdateAsync(Venda venda);
        Task<Venda> DeleteAsync(int id);
    }
}

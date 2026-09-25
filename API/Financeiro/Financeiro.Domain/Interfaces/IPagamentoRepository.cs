using Financeiro.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Interfaces
{
    public interface IPagamentoRepository
    {
        Task<Pagamento> GetByIdAsync(int id);
        Task<List<Pagamento>> GetAllAsync();
        Task<Pagamento> AddAsync(Pagamento pagamento);
        Task<Pagamento> UpdateAsync(Pagamento pagamento);
        Task<Pagamento> DeleteAsync(int id);
    }
}

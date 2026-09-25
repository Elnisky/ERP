using Financeiro.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Interfaces
{
    public interface IVendaItemRepository
    {
        Task<VendaItem> GetByIdAsync(int id);
        Task<List<VendaItem>> GetAllAsync();
        Task<VendaItem> AddAsync(VendaItem vendaItem);
        Task<VendaItem> UpdateAsync(VendaItem vendaItem);
        Task<VendaItem> DeleteAsync(VendaItem vendaItem);
    }
}

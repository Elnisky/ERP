using Financeiro.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Interfaces
{
    public interface IClienteRepository
    {
        Task<Cliente> GetByIdAsync(int id);
        Task<List<Cliente>> GetAllAsync();
        Task<Cliente> AddAsync(Cliente cliente);
        Task<Cliente> UpdateAsync(Cliente cliente);
        Task<Cliente> DeleteAsync(int id);
    }
}

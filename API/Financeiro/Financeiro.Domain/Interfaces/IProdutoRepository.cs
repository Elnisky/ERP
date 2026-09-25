using Financeiro.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Domain.Interfaces
{
    public interface IProdutoRepository
    {
        Task<Produto> GetByIdAsync(int id);
        Task<List<Produto>> GetAllAsync();
        Task<Produto> AddAsync(Produto produto);
        Task<Produto> UpdateAsync(Produto produto);
        Task<Produto> DeleteAsync(int id);
    }
}

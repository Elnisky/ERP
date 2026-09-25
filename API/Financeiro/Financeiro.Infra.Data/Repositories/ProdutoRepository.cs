using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using Financeiro.Infra.Data.Context;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.Repositories
{
    public class ProdutoRepository: IProdutoRepository
    {
        private readonly ApplicationDbContext _context;
        public ProdutoRepository(ApplicationDbContext context)
        {
            _context = context;
        }   
        public async Task<Produto> AddAsync(Produto produto)
        {
            _context.Produto.Add(produto);
            await _context.SaveChangesAsync();
            return produto;
        }

        public async Task<Produto> DeleteAsync(int id)
        {
            var produto = await _context.Produto.FindAsync(id);
            if (produto == null)
            {
                return null;
            }
            _context.Produto.Remove(produto);
            await _context.SaveChangesAsync();
            return produto;
        }

        public async Task<List<Produto>> GetAllAsync()
        {
            return await _context.Produto.ToListAsync();
        }

        public async Task<Produto> GetByIdAsync(int id)
        {
            return await _context.Produto.FindAsync(id);
        }

        public async Task<Produto> UpdateAsync(Produto produto)
        {
            _context.Produto.Update(produto);
            await _context.SaveChangesAsync();
            return produto;
        }
    }
}

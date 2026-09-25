using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using Financeiro.Infra.Data.Context;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.Repositories
{
    public class PagamentoRepository : IPagamentoRepository
    {
        private readonly ApplicationDbContext _context;
        public PagamentoRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<Pagamento> AddAsync(Pagamento pagamento)
        {
            _context.Pagamento.Add(pagamento);
            await _context.SaveChangesAsync();
            return pagamento;
        }

        public async Task<Pagamento> DeleteAsync(int id)
        {
            var pagamento = await _context.Pagamento.FindAsync(id);
            if (pagamento == null)
            {
                return null;
            }
            _context.Pagamento.Remove(pagamento);
            await _context.SaveChangesAsync();
            return pagamento;
        }

        public async Task<List<Pagamento>> GetAllAsync()
        {
            return await _context.Pagamento.ToListAsync();  
        }

        public async Task<Pagamento> GetByIdAsync(int id)
        {
            return await _context.Pagamento.FindAsync(id);
        }

        public async Task<Pagamento> UpdateAsync(Pagamento pagamento)
        {
            _context.Pagamento.Update(pagamento);
            await _context.SaveChangesAsync();
            return pagamento;
        }
    }
}

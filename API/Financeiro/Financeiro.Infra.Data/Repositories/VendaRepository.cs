using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using Financeiro.Infra.Data.Context;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.Repositories
{
    public class VendaRepository : IVendaRepository
    {
        private readonly ApplicationDbContext _context;
        public VendaRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<Venda> AddAsync(Venda venda)
        {
            _context.Venda.Add(venda);
            await _context.SaveChangesAsync();
            return venda;
        }

        public async Task<Venda> DeleteAsync(int id)
        {
            var venda = await _context.Venda.FindAsync(id);
            if (venda == null)
            {
                return null;
            }
            _context.Venda.Remove(venda);
            await _context.SaveChangesAsync();
            return venda;
        }

        public async Task<List<Venda>> GetAllAsync()
        {
            return await _context.Venda.ToListAsync();
        }

        public async Task<Venda> GetByIdAsync(int id)
        {
            return await _context.Venda
                .Include(v => v.Cliente)
                .Include(v => v.VendaItens)
                .Include(v => v.Pagamentos)
                .FirstOrDefaultAsync(v => v.Id == id);
        }

        public async Task<Venda> UpdateAsync(Venda venda)
        {
            _context.Venda.Update(venda);
            await _context.SaveChangesAsync();
            return venda;
        }
    }
}

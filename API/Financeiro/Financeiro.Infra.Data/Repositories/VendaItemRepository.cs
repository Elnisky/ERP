using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using Financeiro.Infra.Data.Context;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.Repositories
{
    public class VendaItemRepository : IVendaItemRepository
    {
        private readonly ApplicationDbContext _context;
        public VendaItemRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<VendaItem> AddAsync(VendaItem vendaItem)
        {
            _context.VendaItem.Add(vendaItem);
            await _context.SaveChangesAsync();
            return vendaItem;
        }

        public async Task<VendaItem> DeleteAsync(VendaItem vendaItem)
        {
            _context.VendaItem.Remove(vendaItem);
            await _context.SaveChangesAsync();
            return vendaItem;
        }

        public async Task<List<VendaItem>> GetAllAsync()
        {
            return await _context.VendaItem.ToListAsync();
        }

        public async Task<VendaItem> GetByIdAsync(int id)
        {
            return await _context.VendaItem.FindAsync(id);
        }

        public async Task<VendaItem> UpdateAsync(VendaItem vendaItem)
        {
            _context.VendaItem.Update(vendaItem);
            await _context.SaveChangesAsync();
            return vendaItem;
        }
    }
}

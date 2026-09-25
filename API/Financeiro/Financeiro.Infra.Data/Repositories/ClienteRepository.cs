using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using Financeiro.Infra.Data.Context;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Infra.Data.Repositories
{
    public class ClienteRepository : IClienteRepository
    {
        private readonly ApplicationDbContext _context;
        public ClienteRepository(ApplicationDbContext context)
        {
            _context = context;
        }
        public async Task<Cliente> AddAsync(Cliente cliente)
        {
            _context.Cliente.Add(cliente);
            await _context.SaveChangesAsync();
            return cliente;
        }

        public async Task<Cliente> DeleteAsync(int id)
        {
            var cliente = await _context.Cliente.FindAsync(id);
            if (cliente == null)
            {
                return null;
            }
            _context.Cliente.Remove(cliente);
            await _context.SaveChangesAsync();
            return cliente;
        }

        public async Task<List<Cliente>> GetAllAsync()
        {
            return await _context.Cliente
                .Include(c => c.Vendas)
                .ToListAsync();
        }

        public async Task<Cliente> GetByIdAsync(int id)
        {
            return await _context.Cliente
                .Include(c => c.Vendas)
                .FirstOrDefaultAsync(c => c.Id == id);
        }

        public async Task<Cliente> UpdateAsync(Cliente cliente)
        {
            _context.Cliente.Update(cliente);
            await _context.SaveChangesAsync();
            return cliente;
        }
    }
}

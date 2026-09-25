using Financeiro.Application.DTOs.Cliente;
using Financeiro.Domain.Entities;
using System;
using System.Collections.Generic;
using System.Text;

namespace Financeiro.Application.Interfaces
{
    public interface IClienteService
    {
        Task<ClienteGetDTO> GetByIdAsync(int id);
        Task<List<ClienteGetDTO>> GetAllAsync();
        Task<ClienteGetDTO> AddAsync(ClientePostDTO clientePostDTO);
        Task<ClienteGetDTO> UpdateAsync(ClientePutDTO clientePutDTO);
        Task<ClienteGetDTO> DeleteAsync(int id);
    }
}

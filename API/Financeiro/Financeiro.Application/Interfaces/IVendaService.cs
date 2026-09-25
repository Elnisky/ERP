using Financeiro.Application.DTOs.Venda;
using System.Collections.Generic;

namespace Financeiro.Application.Interfaces
{
    public interface IVendaService
    {
        Task<VendaGetDTO> GetByIdAsync(int id);
        Task<List<VendaGetDTO>> GetAllAsync();
        Task<VendaGetDTO> AddAsync(VendaPostDTO vendaPostDTO);
        Task<VendaGetDTO> UpdateAsync(VendaPutDTO vendaPutDTO);
        Task<VendaGetDTO> DeleteAsync(int id);
    }
}

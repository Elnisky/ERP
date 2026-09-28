using Financeiro.Application.DTOs.VendaItem;
using System.Collections.Generic;

namespace Financeiro.Application.Interfaces
{
    public interface IVendaItemService
    {
        Task<VendaItemGetDTO> GetByIdAsync(int id);
        Task<List<VendaItemGetDTO>> GetAllAsync();
        Task<VendaItemGetDTO> AddAsync(VendaItemPostDTO vendaItemPostDTO);
        Task<VendaItemGetDTO> UpdateAsync(VendaItemPutDTO vendaItemPutDTO);
        Task<List<VendaItemGetDTO>> UpdateManyAsync(List<VendaItemPostDTO> vendaItemPostDTOs);
        Task<VendaItemGetDTO> DeleteAsync(int id);
    }
}

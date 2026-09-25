using Financeiro.Application.DTOs.VendaItem;
using Financeiro.Application.Exceptions;
using Financeiro.Application.Interfaces;
using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Financeiro.Application.Services
{
    public class VendaItemService : IVendaItemService
    {
        private readonly IVendaItemRepository _vendaItemRepository;
        private readonly IVendaRepository _vendaRepository;

        public VendaItemService(IVendaItemRepository vendaItemRepository, IVendaRepository vendaRepository)
        {
            _vendaItemRepository = vendaItemRepository;
            _vendaRepository = vendaRepository;
        }

        public async Task<VendaItemGetDTO> AddAsync(VendaItemPostDTO vendaItemPostDTO)
        {
            var vendaItem = new VendaItem
            {
                VendaId = vendaItemPostDTO.VendaId,
                ProdutoId = vendaItemPostDTO.ProdutoId,
                Quantidade = vendaItemPostDTO.Quantidade,
                ValorUnitario = vendaItemPostDTO.ValorUnitario,
                ValorTotal = vendaItemPostDTO.Quantidade * vendaItemPostDTO.ValorUnitario
            };

            var created = await _vendaItemRepository.AddAsync(vendaItem);
            await RecalculateVendaTotal(created.VendaId);
            
            return new VendaItemGetDTO
            {
                Id = created.Id,
                VendaId = created.VendaId,
                ProdutoId = created.ProdutoId,
                Quantidade = created.Quantidade,
                ValorUnitario = created.ValorUnitario,
                ValorTotal = created.ValorTotal
            };
        }

        public async Task<VendaItemGetDTO> DeleteAsync(int id)
        {
            var vendaItem = await _vendaItemRepository.GetByIdAsync(id);
            if (vendaItem == null)
                throw new NotFoundException("Item da venda não encontrado");

            var deleted = await _vendaItemRepository.DeleteAsync(vendaItem);
            await RecalculateVendaTotal(deleted.VendaId);
            
            return new VendaItemGetDTO
            {
                Id = deleted.Id,
                VendaId = deleted.VendaId,
                ProdutoId = deleted.ProdutoId,
                Quantidade = deleted.Quantidade,
                ValorUnitario = deleted.ValorUnitario,
                ValorTotal = deleted.ValorTotal
            };
        }

        public async Task<List<VendaItemGetDTO>> GetAllAsync()
        {
            var itens = await _vendaItemRepository.GetAllAsync();
            return itens.Select(i => new VendaItemGetDTO
            {
                Id = i.Id,
                VendaId = i.VendaId,
                ProdutoId = i.ProdutoId,
                Quantidade = i.Quantidade,
                ValorUnitario = i.ValorUnitario,
                ValorTotal = i.ValorTotal
            }).ToList();
        }

        public async Task<VendaItemGetDTO> GetByIdAsync(int id)
        {
            var item = await _vendaItemRepository.GetByIdAsync(id);
            if (item == null)
                throw new NotFoundException("Item da venda não encontrado");

            return new VendaItemGetDTO
            {
                Id = item.Id,
                VendaId = item.VendaId,
                ProdutoId = item.ProdutoId,
                Quantidade = item.Quantidade,
                ValorUnitario = item.ValorUnitario,
                ValorTotal = item.ValorTotal
            };
        }

        public async Task<VendaItemGetDTO> UpdateAsync(VendaItemPutDTO vendaItemPutDTO)
        {
            var item = await _vendaItemRepository.GetByIdAsync(vendaItemPutDTO.Id);
            if (item == null)
                throw new NotFoundException("Item da venda não encontrado");

            item.Quantidade = vendaItemPutDTO.Quantidade;
            item.ValorUnitario = vendaItemPutDTO.ValorUnitario;
            item.ValorTotal = item.Quantidade * item.ValorUnitario;

            var updated = await _vendaItemRepository.UpdateAsync(item);
            await RecalculateVendaTotal(updated.VendaId);
            
            return new VendaItemGetDTO
            {
                Id = updated.Id,
                VendaId = updated.VendaId,
                ProdutoId = updated.ProdutoId,
                Quantidade = updated.Quantidade,
                ValorUnitario = updated.ValorUnitario,
                ValorTotal = updated.ValorTotal
            };
        }

        private async Task RecalculateVendaTotal(int vendaId)
        {
            var itens = await _vendaItemRepository.GetAllAsync();
            var total = itens.Where(i => i.VendaId == vendaId).Sum(i => i.ValorTotal);

            var venda = await _vendaRepository.GetByIdAsync(vendaId);
            if (venda == null)
                throw new ArgumentException("Venda não encontrada");

            venda.Total = total;
            await _vendaRepository.UpdateAsync(venda);
        }
    }
}

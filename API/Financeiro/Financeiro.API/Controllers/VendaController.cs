using Financeiro.Application.DTOs.Venda;
using Financeiro.Application.DTOs.VendaItem;
using Financeiro.Application.Interfaces;
using Financeiro.Domain.Interfaces;
using Financeiro.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Financeiro.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class VendaController : Controller
    {
        private readonly IVendaService _vendaService;
        private readonly IVendaItemService _vendaItemService;

        public VendaController(IVendaService vendaService, IVendaItemService vendaItemService)
        {
            _vendaService = vendaService;
            _vendaItemService = vendaItemService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateVenda(VendaPostDTO vendaPostDTO)
        {
            var created = await _vendaService.AddAsync(vendaPostDTO);
            if (created == null)
                return BadRequest("Erro ao criar venda.");

            return Ok(new { message = "Venda cadastrada com sucesso.", venda = created });
        }

        [HttpPut]
        public async Task<IActionResult> UpdateVenda(VendaPutDTO vendaPutDTO)
        {
            try
            {
                var updated = await _vendaService.UpdateAsync(vendaPutDTO);
                return Ok(new { message = "Venda atualizada com sucesso.", venda = updated });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteVenda(int id)
        {
            try
            {
                var deleted = await _vendaService.DeleteAsync(id);
                return Ok(new { message = "Venda excluída com sucesso.", venda = deleted });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetVendaById(int id)
        {
            try
            {
                var venda = await _vendaService.GetByIdAsync(id);
                return Ok(venda);
            }
            catch (ArgumentException ex)
            {
                return NotFound(ex.Message);
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAllVendas()
        {
            var vendas = await _vendaService.GetAllAsync();
            return Ok(vendas);
        }

        [HttpPost("{vendaId}/itens")]
        public async Task<IActionResult> AddItem(int vendaId, VendaItemPostDTO vendaItemPostDTO)
        {
            try
            {
                vendaItemPostDTO.VendaId = vendaId;
                var created = await _vendaItemService.AddAsync(vendaItemPostDTO);
                return Ok(new { message = "Item adicionado com sucesso.", item = created });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpPut("itens")]
        public async Task<IActionResult> UpdateItems([FromBody] List<VendaItemPostDTO> vendaItemPostDTOs)
        {
            try
            {
                var updated = await _vendaItemService.UpdateManyAsync(vendaItemPostDTOs);
                return Ok(new { message = "Itens atualizados com sucesso.", items = updated });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("itens/{id}")]
        public async Task<IActionResult> DeleteItem(int id)
        {
            try
            {
                var deleted = await _vendaItemService.DeleteAsync(id);
                return Ok(new { message = "Item excluído com sucesso.", item = deleted });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("{vendaId}/itens")]
        public async Task<IActionResult> GetItensByVenda(int vendaId)
        {
            var itens = await _vendaItemService.GetAllAsync();
            var itensVenda = itens.Where(i => i.VendaId == vendaId).ToList();
            return Ok(itensVenda);
        }


    }
}

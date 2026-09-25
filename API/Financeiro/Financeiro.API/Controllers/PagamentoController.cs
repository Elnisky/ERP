using Financeiro.Application.DTOs.Pagamento;
using Financeiro.Application.Interfaces;
using Financeiro.Domain.Entities;
using Microsoft.AspNetCore.Mvc;

namespace Financeiro.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class PagamentoController : Controller
    {
        private readonly IPagamentoService _pagamentoService;

        public PagamentoController(IPagamentoService pagamentoService)
        {
            _pagamentoService = pagamentoService;
        }

        [HttpPost]
        public async Task<IActionResult> CreatePagamento(PagamentoPostDTO pagamentoPostDTO)
        {
            var created = await _pagamentoService.AddAsync(pagamentoPostDTO);
            if (created == null)
                return BadRequest("Erro ao criar pagamento.");

            return Ok(new { message = "Pagamento criado com sucesso.", pagamento = created });
        }

        [HttpPut]
        public async Task<IActionResult> UpdatePagamento(PagamentoPutDTO pagamentoPutDTO)
        {
            try
            {

                var updated = await _pagamentoService.UpdateAsync(pagamentoPutDTO);
                return Ok(new { message = "Pagamento atualizado com sucesso.", pagamento = updated });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeletePagamento(int id)
        {
            try
            {
                var deleted = await _pagamentoService.DeleteAsync(id);
                return Ok(new { message = "Pagamento excluído com sucesso.", pagamento = deleted });
            }
            catch (ArgumentException ex)
            {
                return BadRequest(ex.Message);
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetPagamentoById(int id)
        {
            try
            {
                var pagamento = await _pagamentoService.GetByIdAsync(id);
                return Ok(pagamento);
            }
            catch (ArgumentException ex)
            {
                return NotFound(ex.Message);
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetAllPagamentos()
        {
            var pagamentos = await _pagamentoService.GetAllAsync();
            return Ok(pagamentos);
        }
    }
}

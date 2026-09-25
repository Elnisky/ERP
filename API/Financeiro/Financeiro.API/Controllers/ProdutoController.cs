using Financeiro.Application.DTOs.Produto;
using Financeiro.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Financeiro.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ProdutoController : Controller
    {
        private readonly IProdutoService _produtoService;
        public ProdutoController(IProdutoService produtoService)
        {
            _produtoService = produtoService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateProduto(ProdutoPostDTO produtoPostDTO)
        {
            var createdProduto = await _produtoService.AddAsync(produtoPostDTO);
            if (createdProduto == null)
            {
                return BadRequest("Erro ao criar produto.");
            }

            return Ok(new { message = "Produto cadastrado com sucesso." });
        }

        [HttpPut]
        public async Task<IActionResult> UpdateProduto(ProdutoPutDTO produtoPutDTO)
        {
            var updatedProduto = await _produtoService.UpdateAsync(produtoPutDTO);
            if (updatedProduto == null)
            {
                return BadRequest("Erro ao atualizar produto.");
            }

            return Ok(new { message = "Produto atualizado com sucesso." });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteProduto(int id)
        {
            var deletedProduto = await _produtoService.DeleteAsync(id);
            if (deletedProduto == null)
            {
                return BadRequest("Erro ao excluir produto.");
            }

            return Ok(new { message = "Produto excluído com sucesso." });
        }

        [HttpGet]
        public async Task<IActionResult> GetAllProdutos()
        {
            var produtos = await _produtoService.GetAllAsync();
            return Ok(produtos);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetProdutoById(int id)
        {
            var produto = await _produtoService.GetByIdAsync(id);
            if (produto == null)
            {
                return NotFound("Produto não encontrado.");
            }

            return Ok(produto);
        }
    }
}

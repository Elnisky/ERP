using Financeiro.Application.DTOs.Cliente;
using Financeiro.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;

namespace Financeiro.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ClienteController : Controller
    {
        private readonly IClienteService _clienteService;
        public ClienteController(IClienteService clienteService)
        {
            _clienteService = clienteService;
        }

        [HttpPost]
        public async Task<IActionResult> CreateCliente(ClientePostDTO clientePostDTO)
        {
            var createdCliente = await _clienteService.AddAsync(clientePostDTO);
            return Ok(new { message = "Cliente cadastrado com sucesso." });
        }

        [HttpPut]
        public async Task<IActionResult> UpdateCliente(ClientePutDTO clientePutDTO)
        {
            var updatedCliente = await _clienteService.UpdateAsync(clientePutDTO);
            return Ok(new { message = "Cliente atualizado com sucesso." });
        }

        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteCliente(int id)
        {
            var deletedCliente = await _clienteService.DeleteAsync(id);
            return Ok(new { message = "Cliente excluído com sucesso." });
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetClienteById(int id)
        {
            var cliente = await _clienteService.GetByIdAsync(id);
            return Ok(cliente);
        }

        [HttpGet]
        public async Task<IActionResult> GetAllClientes()
        {
            var clientes = await _clienteService.GetAllAsync();
            return Ok(clientes);
        }
    }
}

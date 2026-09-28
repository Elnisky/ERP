using Financeiro.Application.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Threading.Tasks;

namespace Financeiro.API.Controllers
{
    [ApiController]
    [Route("api/vendas")]
    public class ReportsController : ControllerBase
    {
        private readonly IVendaService _vendaService;
        private readonly IPdfGenerator _pdfGenerator;

        public ReportsController(IVendaService vendaService, IPdfGenerator pdfGenerator)
        {
            _vendaService = vendaService;
            _pdfGenerator = pdfGenerator;
        }

        [HttpGet("{id}/confirmacao-pdf")]
        public async Task<IActionResult> GetOrderConfirmationPdf(int id)
        {
            var venda = await _vendaService.GetByIdAsync(id);
            if (venda == null)
                return NotFound();

            var pdf = await _pdfGenerator.GenerateOrderConfirmationAsync(venda);
            return File(pdf, "application/pdf", $"pedido_{id}.pdf");
        }
    }
}

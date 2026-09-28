using Financeiro.Application.DTOs.Venda;
using Financeiro.Application.Exceptions;
using Financeiro.Application.Interfaces;
using Financeiro.Domain.Entities;
using Financeiro.Domain.Interfaces;
using Financeiro.Application.DTOs.Cliente;
using Financeiro.Application.DTOs.VendaItem;
using Financeiro.Application.DTOs.Pagamento;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Financeiro.Application.Services
{
    public class VendaService : IVendaService
    {
        private readonly IVendaRepository _vendaRepository;
        private readonly IPagamentoService _pagamentoService;
        private readonly IPdfGenerator _pdfGenerator;
        private readonly IEmailSender _emailSender;

        public VendaService(IVendaRepository vendaRepository, IPagamentoService pagamentoService, IPdfGenerator pdfGenerator, IEmailSender emailSender)
        {
            _vendaRepository = vendaRepository;
            _pagamentoService = pagamentoService;
            _pdfGenerator = pdfGenerator;
            _emailSender = emailSender;
        }

        public async Task<VendaGetDTO> AddAsync(VendaPostDTO vendaPostDTO)
        {
            var venda = new Venda
            {
                ClienteId = vendaPostDTO.ClienteId,
                CriadoEm = DateTime.Now,
                Status = vendaPostDTO.Status,
                VendaItens = vendaPostDTO.Itens?.Select(i => new VendaItem
                {
                    ProdutoId = i.ProdutoId,
                    Quantidade = i.Quantidade,
                    ValorUnitario = i.ValorUnitario,
                    ValorTotal = i.Quantidade * i.ValorUnitario
                }).ToList()
            };

            venda.Total = venda.VendaItens?.Sum(i => i.ValorTotal) ?? 0;

            var created = await _vendaRepository.AddAsync(venda);
            return new VendaGetDTO
            {
                Id = created.Id,
                ClienteId = created.ClienteId,
                CriadoEm = created.CriadoEm,
                PagoEm = created.PagoEm,
                Status = created.Status,
                Total = created.Total
            };
        }

        public async Task<VendaGetDTO> DeleteAsync(int id)
        {
            var venda = await _vendaRepository.GetByIdAsync(id);
            if (venda == null)
                throw new NotFoundException("Venda não encontrada");

            var pagamentos = await _pagamentoService.GetAllAsync();
            var pagamentosVenda = pagamentos.Where(p => p.VendaId == id).ToList();
            if (pagamentosVenda.Any(p => p.Status != PagamentoStatus.Pendente))
                throw new BadRequestException("Não é permitido excluir a venda pois existem pagamentos já processados.");

            var deleted = await _vendaRepository.DeleteAsync(venda.Id);
            return new VendaGetDTO
            {
                Id = deleted.Id,
                ClienteId = deleted.ClienteId,
                CriadoEm = deleted.CriadoEm,
                PagoEm = deleted.PagoEm,
                Status = deleted.Status,
                Total = deleted.Total
            };
        }

        public async Task<List<VendaGetDTO>> GetAllAsync()
        {
            var vendas = await _vendaRepository.GetAllAsync();
            return vendas.Select(v => new VendaGetDTO
            {
                Id = v.Id,
                ClienteId = v.ClienteId,
                CriadoEm = v.CriadoEm,
                PagoEm = v.PagoEm,
                Status = v.Status,
                Total = v.Total
            }).ToList();
        }

        public async Task<VendaGetDTO> GetByIdAsync(int id)
        {
            var venda = await _vendaRepository.GetByIdAsync(id);
            if (venda == null)
                throw new NotFoundException("Venda não encontrada");

            return new VendaGetDTO
            {
                Id = venda.Id,
                ClienteId = venda.ClienteId,
                CriadoEm = venda.CriadoEm,
                PagoEm = venda.PagoEm,
                Status = venda.Status,
                Total = venda.Total,
                Cliente = venda.Cliente == null ? null : new ClienteGetDTO
                {
                    Id = venda.Cliente.Id,
                    Nome = venda.Cliente.Nome,
                    Cpf = venda.Cliente.Cpf,
                    Email = venda.Cliente.Email,
                    Telefone = venda.Cliente.Telefone,
                    DataCadastro = venda.Cliente.DataCadastro,
                    Vendas = null
                },
                Itens = venda.VendaItens?.Select(i => new VendaItemGetDTO
                {
                    Id = i.Id,
                    VendaId = i.VendaId,
                    ProdutoId = i.ProdutoId,
                    Quantidade = i.Quantidade,
                    ValorUnitario = i.ValorUnitario,
                    ValorTotal = i.ValorTotal
                }).ToList(),
                Pagamentos = venda.Pagamentos?.Select(p => new PagamentoGetDTO
                {
                    Id = p.Id,
                    VendaId = p.VendaId,
                    CriadoEm = p.CriadoEm,
                    CompletedAt = p.CompletedAt,
                    Valor = p.Valor,
                    Type = p.Type,
                    Status = p.Status
                }).ToList()
            };
        }

        public async Task<VendaGetDTO> UpdateAsync(VendaPutDTO vendaPutDTO)
        {
            var venda = await _vendaRepository.GetByIdAsync(vendaPutDTO.Id);
            if (venda == null)
                throw new NotFoundException("Venda não encontrada");

            var pagamentos = await _pagamentoService.GetAllAsync();
            var pagamentosVenda = pagamentos.Where(p => p.VendaId == vendaPutDTO.Id).ToList();
            if (pagamentosVenda.Any(p => p.Status != PagamentoStatus.Pendente))
                throw new BadRequestException("Não é permitido alterar a venda pois existem pagamentos já processados.");

            if (vendaPutDTO.Status < venda.Status)
                throw new BadRequestException("Não é possível retroceder o status da venda.");

            venda.Status = vendaPutDTO.Status;
            if (venda.Status == StatusVenda.Pago)
            {
                venda.PagoEm = DateTime.Now;

                var rnd = new Random();
                var tipos = Enum.GetValues(typeof(TipoPagamento));
                var tipoAleatorio = (TipoPagamento)tipos.GetValue(rnd.Next(tipos.Length));

                var pagamentoPost = new PagamentoPostDTO
                {
                    VendaId = venda.Id,
                    Valor = venda.Total,
                    Type = tipoAleatorio
                };

                var pagamentoCriado = await _pagamentoService.AddAsync(pagamentoPost);

                var pagamentoPut = new PagamentoPutDTO
                {
                    Id = pagamentoCriado.Id,
                    Status = PagamentoStatus.Pago,
                    CompletedAt = DateTime.Now
                };

                var pagamentoAtualizado = await _pagamentoService.UpdateAsync(pagamentoPut);

                try
                {
                    var pdf = await _pdfGenerator.GeneratePaymentReceiptAsync(pagamentoAtualizado);
                    var clienteEmail = venda.Cliente?.Email;
                    if (!string.IsNullOrWhiteSpace(clienteEmail))
                    {
                        var subject = "Comprovante de pagamento";
                        var body = $"<p>Olá {venda.Cliente?.Nome ?? "Cliente"},</p><p>Em anexo está o comprovante do pagamento (ID {pagamentoAtualizado.Id}) referente à venda {venda.Id} no valor de R$ {pagamentoAtualizado.Valor:0.00}.</p><p>Atenciosamente,<br/>Financeiro API</p>";
                        var attachments = new[] { ($"comprovante-{pagamentoAtualizado.Id}.pdf", pdf) };
                        await _emailSender.SendEmailAsync(clienteEmail, subject, body, attachments);
                    }
                }
                catch
                {
                    // Não propagar exceção de email/pdf para não impedir atualização da venda.
                }
            }
            
            var updated = await _vendaRepository.UpdateAsync(venda);
            return new VendaGetDTO
            {
                Id = updated.Id,
                ClienteId = updated.ClienteId,
                CriadoEm = updated.CriadoEm,
                PagoEm = updated.PagoEm,
                Status = updated.Status,
                Total = updated.Total
            };
        }
    }
}

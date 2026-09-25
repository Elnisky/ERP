using Financeiro.Application.DTOs.Pagamento;
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
    public class PagamentoService : IPagamentoService
    {
        private readonly IPagamentoRepository _pagamentoRepository;

        public PagamentoService(IPagamentoRepository pagamentoRepository)
        {
            _pagamentoRepository = pagamentoRepository;
        }

        public async Task<PagamentoGetDTO> AddAsync(PagamentoPostDTO pagamentoPostDTO)
        {
            var pagamento = new Pagamento
            {
                VendaId = pagamentoPostDTO.VendaId,
                CriadoEm = DateTime.UtcNow,
                Valor = pagamentoPostDTO.Valor,
                Type = pagamentoPostDTO.Type,
                Status = PagamentoStatus.Pendente
            };

            var created = await _pagamentoRepository.AddAsync(pagamento);
            return new PagamentoGetDTO
            {
                Id = created.Id,
                VendaId = created.VendaId,
                CriadoEm = created.CriadoEm,
                CompletedAt = created.CompletedAt,
                Valor = created.Valor,
                Type = created.Type,
                Status = created.Status
            };
        }

        public async Task<PagamentoGetDTO> DeleteAsync(int id)
        {
            var pagamento = await _pagamentoRepository.GetByIdAsync(id);
            if (pagamento == null)
                throw new NotFoundException("Pagamento não encontrado");

            var deleted = await _pagamentoRepository.DeleteAsync(id);
            return new PagamentoGetDTO
            {
                Id = deleted.Id,
                VendaId = deleted.VendaId,
                CriadoEm = deleted.CriadoEm,
                CompletedAt = deleted.CompletedAt,
                Valor = deleted.Valor,
                Type = deleted.Type,
                Status = deleted.Status
            };
        }

        public async Task<List<PagamentoGetDTO>> GetAllAsync()
        {
            var pagamentos = await _pagamentoRepository.GetAllAsync();
            return pagamentos.Select(p => new PagamentoGetDTO
            {
                Id = p.Id,
                VendaId = p.VendaId,
                CriadoEm = p.CriadoEm,
                CompletedAt = p.CompletedAt,
                Valor = p.Valor,
                Type = p.Type,
                Status = p.Status
            }).ToList();
        }

        public async Task<PagamentoGetDTO> GetByIdAsync(int id)
        {
            var pagamento = await _pagamentoRepository.GetByIdAsync(id);
            if (pagamento == null)
                throw new NotFoundException("Pagamento não encontrado");

            return new PagamentoGetDTO
            {
                Id = pagamento.Id,
                VendaId = pagamento.VendaId,
                CriadoEm = pagamento.CriadoEm,
                CompletedAt = pagamento.CompletedAt,
                Valor = pagamento.Valor,
                Type = pagamento.Type,
                Status = pagamento.Status
            };
        }

        public async Task<PagamentoGetDTO> UpdateAsync(PagamentoPutDTO pagamentoPutDTO)
        {
            var pagamento = await _pagamentoRepository.GetByIdAsync(pagamentoPutDTO.Id);
            if (pagamento == null)
                throw new NotFoundException("Pagamento não encontrado");

            pagamento.Status = pagamentoPutDTO.Status;
            if ((pagamentoPutDTO.Status == PagamentoStatus.Pago || pagamentoPutDTO.Status == PagamentoStatus.Cancelado))
            {
                pagamento.CompletedAt = pagamentoPutDTO.CompletedAt ?? DateTime.UtcNow;
            }
            else
            {
                pagamento.CompletedAt = pagamentoPutDTO.CompletedAt;
            }
            if (!string.IsNullOrWhiteSpace(pagamentoPutDTO.TransacaoId))
                pagamento.TransacaoId = pagamentoPutDTO.TransacaoId;

            var updated = await _pagamentoRepository.UpdateAsync(pagamento);
            return new PagamentoGetDTO
            {
                Id = updated.Id,
                VendaId = updated.VendaId,
                CriadoEm = updated.CriadoEm,
                CompletedAt = updated.CompletedAt,
                Valor = updated.Valor,
                Type = updated.Type,
                Status = updated.Status
            };
        }
    }
}

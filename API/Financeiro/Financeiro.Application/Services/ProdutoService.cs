using Financeiro.Application.DTOs.Produto;
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
    public class ProdutoService : IProdutoService
    {
        private readonly IProdutoRepository _produtoRepository;

        public ProdutoService(IProdutoRepository produtoRepository)
        {
            _produtoRepository = produtoRepository;
        }

        public async Task<ProdutoGetDTO> AddAsync(ProdutoPostDTO produtoPostDTO)
        {
            var produto = new Produto
            {
                Nome = produtoPostDTO.Nome,
                Preco = produtoPostDTO.Preco,
                QuantidadeEstoque = produtoPostDTO.QuantidadeEstoque
            };

            var created = await _produtoRepository.AddAsync(produto);
            return new ProdutoGetDTO
            {
                Id = created.Id,
                Nome = created.Nome,
                Preco = created.Preco,
                QuantidadeEstoque = created.QuantidadeEstoque
            };
        }

        public async Task<ProdutoGetDTO> DeleteAsync(int id)
        {
            var produto = await _produtoRepository.GetByIdAsync(id);
            if (produto == null)
                throw new NotFoundException("Produto não encontrado");

            var deleted = await _produtoRepository.DeleteAsync(id);
            return new ProdutoGetDTO
            {
                Id = deleted.Id,
                Nome = deleted.Nome,
                Preco = deleted.Preco,
                QuantidadeEstoque = deleted.QuantidadeEstoque
            };
        }

        public async Task<List<ProdutoGetDTO>> GetAllAsync()
        {
            var produtos = await _produtoRepository.GetAllAsync();
            return produtos.Select(p => new ProdutoGetDTO
            {
                Id = p.Id,
                Nome = p.Nome,
                Preco = p.Preco,
                QuantidadeEstoque = p.QuantidadeEstoque
            }).ToList();
        }

        public async Task<ProdutoGetDTO> GetByIdAsync(int id)
        {
            var produto = await _produtoRepository.GetByIdAsync(id);
            if (produto == null)
                throw new NotFoundException("Produto não encontrado");

            return new ProdutoGetDTO
            {
                Id = produto.Id,
                Nome = produto.Nome,
                Preco = produto.Preco,
                QuantidadeEstoque = produto.QuantidadeEstoque
            };
        }

        public async Task<ProdutoGetDTO> UpdateAsync(ProdutoPutDTO produtoPutDTO)
        {
            var produto = await _produtoRepository.GetByIdAsync(produtoPutDTO.Id);
            if (produto == null)
                throw new NotFoundException("Produto não encontrado");

            produto.Nome = produtoPutDTO.Nome;
            produto.Preco = produtoPutDTO.Preco;
            produto.QuantidadeEstoque = produtoPutDTO.QuantidadeEstoque;

            var updated = await _produtoRepository.UpdateAsync(produto);
            return new ProdutoGetDTO
            {
                Id = updated.Id,
                Nome = updated.Nome,
                Preco = updated.Preco,
                QuantidadeEstoque = updated.QuantidadeEstoque
            };
        }
    }
}

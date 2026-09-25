using Financeiro.Application.DTOs.Produto;
using System.Collections.Generic;

namespace Financeiro.Application.Interfaces
{
    public interface IProdutoService
    {
        Task<ProdutoGetDTO> GetByIdAsync(int id);
        Task<List<ProdutoGetDTO>> GetAllAsync();
        Task<ProdutoGetDTO> AddAsync(ProdutoPostDTO produtoPostDTO);
        Task<ProdutoGetDTO> UpdateAsync(ProdutoPutDTO produtoPutDTO);
        Task<ProdutoGetDTO> DeleteAsync(int id);
    }
}
